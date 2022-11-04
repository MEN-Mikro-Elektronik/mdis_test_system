#! /bin/bash

############################################################################
# echo result so that can be easly found in log 
# 
# parameters:
# $1    command
#
function make_visible_in_log {
    echo -e "\n############################################################################"
    echo "############################################################################"
    echo "$1"
    echo "############################################################################"
    echo "############################################################################"
}

############################################################################
# Run commands on remote tested device
# 
# parameters:
# $1    command
#
function run_cmd_on_remote_pc {
    sshpass -p "${MenPcPassword}" ssh -o StrictHostKeyChecking=no "${MenPcLogin}"@"${MenPcIpAddr}" "${1}"
}

############################################################################
# Run commands on remote input switch device
# 
# parameters:
# $1    command
#
function run_cmd_on_remote_input_switch {
    sshpass -p "${MenPcPassword}" ssh -o StrictHostKeyChecking=no "${MenPcLogin}"@"${MenBoxPcIpAddr}" "${1}"
}

############################################################################
# Run scritps from this machine on remote device, since there is no 
# 
# parameters:
# $1    script
#
function run_script_on_remote_pc {
    sshpass -p "${MenPcPassword}" ssh -o StrictHostKeyChecking=no "${MenPcLogin}"@"${MenPcIpAddr}" \
    bash -s < "${1}"
}

############################################################################
# Check if file exists on UAT. Function return true/false
# 
# parameters:
# $1    file name with full path
#
function check_file_exists_on_UAT {
    local FilePath=${1}
    local CheckFileExistsCmd
    local FileExist
    CheckFileExistsCmd="[ -f ${FilePath} ] && echo \"true\" || echo \"false\""
    FileExist=$(run_cmd_on_remote_pc "${CheckFileExistsCmd}")
    echo "${FileExist}"
}

############################################################################
# Write result of input change into lock file
#
# parameters:
# $1      Command code 
# $2      Log prefix - optional
#
function write_command_code_lock_file_result {
    local CommandCodeResult=${1}
    local LogPrefix=${2}
    local FileExist
    FileExist=$(check_file_exists_on_UAT "${LockFileName}")

    if [ "${FileExist}" = "false" ]; then
        echo "${LogPrefix} ERR_LOCK_NO_EXISTS"
        return "${ERR_LOCK_NO_EXISTS}"
    fi

    # Check if there is no result written yet
    local ResultExists
    ResultExists=$(check_command_code_result_exist)
    echo "${ResultExists}"

    if [ -z "${ResultExists}" ]; then
        debug_print_host "${LogPrefix} No result in lock file" 
    else
        debug_print_host "${LogPrefix} Result is written into lock file" 
        return "${ERR_OK}"
    fi

    local WriteSuccessCmd="echo \"${MenPcPassword}\" | sudo -S --prompt=$'\r' echo -n \" : ${LockFileSuccess}\" >> ${LockFileName}"
    local WriteFailedCmd="echo \"${MenPcPassword}\" | sudo -S --prompt=$'\r' echo -n \" : ${LockFileFailed}\" >> ${LockFileName}"

    if [ "${CommandCodeResult}" = "${LockFileSuccess}" ]; then
        if ! run_cmd_on_remote_pc "${WriteSuccessCmd}"
        then
            debug_print_host "${LogPrefix} Error while write_command_code_lock_file_result success"
        fi
        debug_print_host "${LogPrefix} write_command_code_lock_file_result: success"
    elif [ "${CommandCodeResult}" = "${LockFileFailed}" ];then
        if ! run_cmd_on_remote_pc "${WriteFailedCmd}"
        then
            debug_print_host "${LogPrefix} Error while write_command_code_lock_file_result failed"
        fi
        debug_print_host "${LogPrefix} write_command_code_lock_file_result: failed"
    else
        echo "${LogPrefix} Write_command_code_status: Unknown status code"
        return "${ERR_LOCK_INVALID}"
    fi
}

############################################################################
# Read which input should be changed 
#
# parameters:
# $1      Command code 
#
function read_command_code_lock_file {
    local FileExist
    local ReadCommandCodeCmd
    local CommandCode

    FileExist=$(check_file_exists_on_UAT "${LockFileName}")

    if [ "${FileExist}" = "false" ]; then
        echo "ERR_LOCK_NO_EXISTS"
        return "${ERR_LOCK_NO_EXISTS}"
    fi

    ReadCommandCodeCmd="cat ${LockFileName} | awk '{print \$3}'"
    CommandCode=$(run_cmd_on_remote_pc "${ReadCommandCodeCmd}")
    echo "${CommandCode}"
}

############################################################################
# Check if input change result was written into file
#
# parameters:
# $1      Command code 
#
function check_command_code_result_exist {
    local FileExist
    local ReadCommandCodeCmd
    local CommandCode

    FileExist=$(check_file_exists_on_UAT "${LockFileName}")

    if [ "${FileExist}" = "false" ]; then
        echo "ERR_LOCK_NO_EXISTS"
        return "${ERR_LOCK_NO_EXISTS}"
    fi


    ReadCommandCodeCmd="cat ${LockFileName} | awk '{print \$5}'"
    CommandCode=$(run_cmd_on_remote_pc "${ReadCommandCodeCmd}")
    echo "${CommandCode}"
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
    local CommandCode=${1}
    local LogPrefix=${2}

    debug_print_host "${LogPrefix} Function change_input_BL51E: ${CommandCode}"

    local I801Loaded
    I801Loaded=$(run_cmd_on_remote_input_switch "lsmod | grep i2c_i801 | wc -l")

    if [ "${I801Loaded}" -eq "0" ]; then
        echo "${LogPrefix} Error: i2c_i801 is not loaded"
        echo "${LogPrefix} Modprobe i2c_i801 ... "

        if ! run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' modprobe i2c_i801"
        then
            echo "${LogPrefix} Modprobe i2c_i801 error"
            return "${ERR_MODPROBE}"
        else
            debug_print_host "${LogPrefix} Modprobe i2c_i801 success"
        fi
    fi

    # now find smbus in i2cdetect dump 
    local I2CNR
    local RegisterData
    I2CNR=$(run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cdetect -y -l | grep smbus | awk '{print \$1}' | sed 's/i2c-//'" )
    RegisterData=$(run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cget -y ${I2CNR} 0x22 | sed 's/0x//' ")

    check_input_state_is_set "${CommandCode}" "${RegisterData}" "${LogPrefix}"
    if [ $? -eq "1" ]; then
        #echo "${LogPrefix} Nothing to do, Input: ${CommandCode} is set"
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
            echo "${LogPrefix} invalid input switch value ${CommandCode}"
        ;;
    esac

    RegisterDataToWrite=$(echo "obase=16; $((16#${RegisterData}^2#${RegisterDataMask}))" | bc )
    debug_print_host "${LogPrefix} RegisterDataToWrite : 0x${RegisterDataToWrite}"

    run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cset -y ${I2CNR} 0x22 0x${RegisterDataToWrite}"

    # Check if value is set
    RegisterData=$(run_cmd_on_remote_input_switch "echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cget -y ${I2CNR} 0x22 | sed 's/0x//' ")
    check_input_state_is_set "${CommandCode}" "${RegisterData}" "${LogPrefix}"
    if [ $? -eq "1" ]; then
        return "${ERR_OK}"
    else
        debug_print_host "${LogPrefix}  ERR_SWITCH: ${CommandCode} is set"
        return "${ERR_SWITCH}"
    fi
}

############################################################################
# Add padding at the beginning of a variable 
# example:
# pad value             1110
# output:           00001110
#
# parameters:
# $1      Binary value 
#
function add_byte_padding {
    # padding to 8 characters, add 0-s at the beginning 
    local ByteToPad=${1}
    local Lenght
    local PaddWithCharacters
    Lenght="${#ByteToPad}"
    PaddWithCharacters=$((8-Lenght))
    if [ ${PaddWithCharacters} -ne "0" ]; then
        for i in $(seq 0 $((PaddWithCharacters-1)))
        do
            ByteToPad=$(echo "${ByteToPad}" | sed 's/^/0/')
        done
    fi
    echo "${ByteToPad}"
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
    local CommandCode=${1}
    local RegValue=${2}
    local LogPrefix=${3}
    local ReturnValue="0"

    #echo "${LogPrefix} function check_input_state"
    # To enable input - value bit should be set to 0, 1 otherwise
    case "${CommandCode}" in
        ${IN_0_ENABLE})
            local Index="6"
            local BitValue
            BitValue=$(echo "obase=2; $((16#${RegValue}))" | bc | head -c ${Index} | tail -c 1)
            #echo "${LogPrefix} BitValue: ${BitValue}"
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
            echo "${LogPrefix} invalid input switch value: ${CommandCode}"
        ;;
    esac

    return "${ReturnValue}"
}

function grub_get_os {
    echo "$(run_cmd_on_remote_pc "grep --perl-regexp --only-matching \"\\s*set default=.*\" ${GrubConfFile} | sed \"s/\\s*set default=\\s*//g\" | sed \"s/\\\"//g\"")"
}

function grub_set_os {
    local ExpOs
    ExpOs="$(echo "${1}" | sed "s/\//\\\\\\\\\//g")"
    run_cmd_on_remote_pc "GrubCfg=\"\$(cat ${GrubConfFile})\" && echo \"\$GrubCfg\" | sed \"s/\\s*set default=.*/set default=\\\"${ExpOs}\\\"/g\" > ${GrubConfFile}"
}

function reboot_and_wait {
    local TryCount=0
    local Return=1
    local ExpOs="$(grub_get_os)"
    local ManualBoot=0
    local Setup

    for Setup in "${ManualOsBootSetups[@]}"; do
        if [ "${Setup}" == "${TEST_SETUP}" ]; then
            ManualBoot=1
            break
        fi
    done

    run_cmd_on_remote_pc "echo \"${MenPcPassword}\" | sudo --stdin --prompt=$'\r' shutdown -r +1"
    if [ "${ManualBoot}" -ne 0 ]; then
        echo
        echo "Please, boot the following OS on target computer:"
        echo "${ExpOs}"
        echo
        echo "Press <ENTER> to continue..."
        read -r -s
    fi
    echo "Waiting for ${MenPcIpAddr}..."
    if [ "${ManualBoot}" -eq 0 ]; then
        sleep 120
    fi
    while true; do
        if ping -c 1 -W 2 "${MenPcIpAddr}"
        then
            echo "Waiting for ${MenPcIpAddr} to fully start..."
            sleep 60
            Return=0
            break
        else
            TryCount=$((TryCount + 1))
            if [ "${TryCount}" -ge 30 ]; then
                Return=1
                break
            fi
            echo "Waiting for ${MenPcIpAddr}..."
            sleep 10
        fi
    done

    return "${Return}"
}

function debug_print_host {
    local Msg="${1}"
    if [ "${VERBOSE_LEVEL}" -ge 2 ]; then
        echo "${Msg}"
    fi
}

############################################################################
# Download the test results from the Target PC.
#
#
# parameters:
# $1      target test result directory
# $2      host test directory
# $3      testSetup id
# $4      date
# $5      log prefix
#

function downloadTestResults {
    local TargetPath=${1}
    local HostPath=${2}
    local TestSetupFolder="St_Test_Setup_${3}"
    local Date=${4}
    local LogPrefix=${5}

    local TargetFullPath=${TargetPath}"/${TestSetupFolder}/${Date}"
    local HostFullPath="${HostPath}/${TestSetupFolder}"

    echo "${LogPrefix} Creating Results/ log in the host device..."
    mkdir -p ${HostFullPath}

    if [ ! -d ${TestSetupDir} ]; then
        echo "${LogPrefix} Error. Unable to create the folder"
        return "${ERR_DIR_NOT_EXISTS}"
    fi

    echo "${LogPrefix} Retrieving the logs from the Target... folder date: "${Date}
    sshpass -p "${MenPcPassword}" scp -r men@${MenPcIpAddr}:${TargetFullPath} ${HostFullPath}

    if [ $? -eq 0 ]; then
        return "${ERR_OK}"
    else
        return "${ERR_DOWNLOAD}"
    fi
}

############################################################################
# Process the test results.
#
#
# parameters:
# $1      host test directory
# $2      testSetup id
# $3      date
# $4      log prefix
#

function processTestResults {
    local HostPath=${1}
    local TestSetupFolder="St_Test_Setup_${2}"
    local Date=${3}
    local LogPrefix=${4}

    local HostFullPath="${HostPath}/${TestSetupFolder}/${Date}"

    echo "${LogPrefix} Searching for Results_Summary.log files of each OS."
    resultFileList=$(find ${HostFullPath} -type f -name ${ResultsFileLogName})

    for resultFile in $resultFileList
    do
        echo -n "${LogPrefix} Processing file: "$resultFile "... "
        python3 ${MyDir}/../../Common/test_report_formatter.py -s -i mdis -f $resultFile

        if [ $? -eq 0 ]; then
            echo "[OK]"
        else
            echo "[FAIL]"
        fi
    done
}
