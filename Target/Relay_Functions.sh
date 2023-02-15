#!/bin/bash

MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/../Common/Mdis_Common_Functions.sh

############################################################################
# Function requests change on input. To specify which input should be changed,
# special Command Code has to be provided (Conf.sh). As a result function returns
# ERR_OK in case of success, otherwise ERR_SWITCH code is returned.
#
# parameters:
# $1    Log file
# $2    Test case name
# $3    Command Code
# $4    Log prefix
function change_input {
    local LogFile=${1}
    local TestCaseName=${2}
    local CommandCode=${3}
    local LogPrefix=${4}
    local Result=${ERR_SWITCH}

    debug_print "${LogPrefix} Changing input... TestCase: ${TestCase} command code: ${CommandCode}" "${LogFile}"

    change_input_BL51E "${LogFile}" "${CommandCode}" "${LogPrefix}"
    Result=$?

    if [ "${Result}" -eq "${ERR_OK}" ]; then
        debug_print "${LogPrefix} Input changed successfully" "${LogFile}"
        return "${ERR_OK}"
    else
        debug_print "${LogPrefix} Unable to change the input" "${LogFile}"
        return "${ERR_SWITCH}"
    fi
}

############################################################################
# Run commands on remote input switch device
#
# parameters:
# $1    command
#
function run_cmd_on_remote_input_switch {
    sshpass -p "${MenPcPassword}" ssh -o StrictHostKeyChecking=no mdis-aux "${1}"
}

############################################################################
# Check input on remote switch device.
# This function is valid only for BL51E !!
#
# parameters:
# $1      Command code
# $2      Log Prefix - optional
#
function change_input_BL51E {
    local LogFile=${1}
    local CommandCode=${2}
    local LogPrefix=${3}

    debug_print "${LogPrefix} Function change_input_BL51E: ${CommandCode}" ${LogFile}

    local I801Loaded
    I801Loaded=$(run_cmd_on_remote_input_switch "lsmod | grep i2c_i801 | wc -l")

    if [ "${I801Loaded}" -eq "0" ]; then
        debug_print "${LogPrefix} Error: i2c_i801 is not loaded" ${LogFile}
        debug_print "${LogPrefix} Modprobe i2c_i801 ... " ${LogFile}

        if ! run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' modprobe i2c_i801"
        then
            debug_print "${LogPrefix} Modprobe i2c_i801 error" ${LogFile}
            return "${ERR_MODPROBE}"
        else
            debug_print "${LogPrefix} Modprobe i2c_i801 success" ${LogFile}
        fi
    fi

    # now find smbus in i2cdetect dump
    local I2CNR
    local RegisterData
    I2CNR=$(run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cdetect -y -l | grep smbus | awk '{print \$1}' | sed 's/i2c-//'" )
    RegisterData=$(run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cget -y ${I2CNR} 0x22 | sed 's/0x//' ")

    check_input_state_is_set "${LogFile}" "${CommandCode}" "${RegisterData}" "${LogPrefix}"
    if [ $? -eq "1" ]; then
        debug_print "${LogPrefix} Nothing to do, Input: ${CommandCode} is set" ${LogFile}
        return "${ERR_OK}"
    fi

    local RegisterDataMask="00000000"
    local FillWith=1

    case "${CommandCode}" in
        ${IN_0_ENABLE});&
        ${IN_0_DISABLE})
            local Index=6
            RegisterDataMask="${RegisterDataMask:0:Index-1}${FillWith}${RegisterDataMask:Index}"
            ;;
        ${IN_1_ENABLE});&
        ${IN_1_DISABLE})
            local Index=5
            RegisterDataMask="${RegisterDataMask:0:Index-1}${FillWith}${RegisterDataMask:Index}"
            ;;
        *)
            debug_print "${LogPrefix} invalid input switch value ${CommandCode}" ${LogFile}
        ;;
    esac

    RegisterDataToWrite=$(echo "obase=16; $((16#${RegisterData}^2#${RegisterDataMask}))" | bc )
    debug_print "${LogPrefix} RegisterDataToWrite : 0x${RegisterDataToWrite}" ${LogFile}

    run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cset -y ${I2CNR} 0x22 0x${RegisterDataToWrite}"

    # Check if value is set
    RegisterData=$(run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cget -y ${I2CNR} 0x22 | sed 's/0x//' ")
    check_input_state_is_set "${LogFile}" "${CommandCode}" "${RegisterData}" "${LogPrefix}"
    if [ $? -eq "1" ]; then
        return "${ERR_OK}"
    else
        debug_print "${LogPrefix}  ERR_SWITCH: ${CommandCode} is set" ${LogFile}
        return "${ERR_SWITCH}"
    fi
}

############################################################################
# Check if output is currently set as enable / disable
# Returns true if input state has been already set
#
#
# parameters:
# $1      Command Code
# $2      i2c current register value
# $3      log prefix - optional
#
function check_input_state_is_set {
    local LogFile=${1}
    local CommandCode=${2}
    local RegValue=${3}
    local LogPrefix=${4}
    local ReturnValue="0"

    #echo "${LogPrefix} function check_input_state"
    # To enable input - value bit should be set to 0, 1 otherwise
    case "${CommandCode}" in
        ${IN_0_ENABLE})
            local Index="6"
            local BitValue
            BitValue=$(echo "obase=2; $((16#${RegValue}))" | bc | head -c ${Index} | tail -c 1)
            if [ "${BitValue}" = "0" ]; then
                    ReturnValue="1"
            fi
            ;;
        ${IN_1_ENABLE})
            local Index="5"
            local BitValue
            BitValue=$(echo "obase=2; $((16#${RegValue}))" | bc | head -c ${Index} | tail -c 1)
            if [ "${BitValue}" = "0" ]; then
                    ReturnValue="1"
            fi
            ;;
        ${IN_0_DISABLE})
            local Index="6"
            local BitValue
            BitValue=$(echo "obase=2; $((16#${RegValue}))" | bc | head -c ${Index} | tail -c 1)
            if [ "${BitValue}" = "1" ]; then
                    ReturnValue="1"
            fi
            ;;
        ${IN_1_DISABLE})
            local Index="5"
            local BitValue
            BitValue=$(echo "obase=2; $((16#${RegValue}))" | bc | head -c ${Index} | tail -c 1)
            if [ "${BitValue}" = "1" ]; then
                    ReturnValue="1"
            fi
            ;;
        *)
            debug_print "${LogPrefix} invalid input switch value: ${CommandCode}" ${LogFile}
        ;;
    esac

    return "${ReturnValue}"
}
