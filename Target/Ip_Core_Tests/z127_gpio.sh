#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z127_gpio_description
#
# parameters:
# $1    Module number
# $2    Module log path
function z127_gpio_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "-------------------------Ip Core 16Z127_GPIO Test Case---------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "DESCRIPTION:"
    echo "    1.Read chameleon table from board"
    echo "    2.Load m-module drivers: modprobe men_ll_z17_z127"
    echo "    3.Find GPIO devices on board"
    echo "    4.Check if there is 16Z127_GPIO"
    echo "    5.Run z127_out <device> -s=0"
    echo "    6.Run z127_out <device> -r"
    echo "    7.Run z127_out <device> -s=1"
    echo "    8.Run z127_out <device> -r"
    echo "    9.Check results - driver shall be loaded successfully,"
    echo "      values have been changed while running example program"
    echo "PURPOSE:"
    echo "    Check if ip core z127 with men_ll_z17_z127 driver is loaded correctly,"
    echo "    and z17_simp can be run on withouth errors on device"
    echo "REQUIREMENT_ID:"
    echo "    MEN_13MD05-90_SA_1480"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# IP core have to be tested on certain carrier, user has to specify
# exact location of ip core in the system
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    Board vendor id
# $4    Board device id
# $5    Board subvendor id
# $6    Board number in system
# $7    Optional parameter - test type (optional)
function z127_gpio_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}
    local RelayOutput=${IN_0_ENABLE}

    MezzChamDevName="MezzChamDevName.txt"
    obtain_device_list_chameleon_device "${VenID}" "${DevID}" "${SubVenID}" "${MezzChamDevName}" "${BoardInSystem}" "${LogFile}" "${LogPrefix}"

    if ! run_as_root modprobe men_ll_z17_z127
    then
        debug_print "${LogPrefix} ERR_MODPROBE :could not modprobe men_ll_z17_z127" "${LogFile}"
        return "${ERR_MODPROBE}"
    else
        GpioNumber=$(grep -c "^gpio" "${MezzChamDevName}")
        debug_print "${LogPrefix} There are ${GpioNumber} GPIO interfaces on ${MezzChamDevName}" "${LogFile}"

        # Find 16Z127_GPIO, check only first available device on mezzaine and exit!
        for i in $(seq 1 ${GpioNumber})
        do
            Gpio=$(grep "^gpio" "${MezzChamDevName}" | awk NR==${i}'{print $1}')
            GpioWizModel=$(obtain_device_wiz_model "${Gpio}")
            debug_print "${LogPrefix} Gpio ${Gpio} is type: ${GpioWizModel}" "${LogFile}"
            if [ "${GpioWizModel}" = "16Z127_GPIO" ]
            then
                # Test GPIO write/read  (leds)
                gpio_led_z127 "${LogFile}" "${LogPrefix}" "${Gpio}"
                Result=$?
                debug_print "${LogPrefix} gpio_led ${Gpio} test result: ${Result}" "${LogFile}"
                return "${Result}"
            fi
        done
    fi
    return "${ERR_VALUE}"
}


############################################################################
# Function checks if GPIO is working correctly - write / read 
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    DeviceName
function gpio_led_z127 {
    local LogFile=${1}
    local LogPrefix=${2}
    local DeviceName=${3}

    debug_print "${LogPrefix} change LED(s)" "${LogFile}"

    if ! run_as_root z127_out "${DeviceName}" -s=0 > z127_out_set_0.log
    then
        debug_print "${LogPrefix} could not run z127_out ${DeviceName} -s=0 " "${LogFile}"
        return "${ERR_VALUE}"
    fi
    if ! run_as_root z127_out "${DeviceName}" -r > z127_out_read_0.log
    then
        debug_print "${LogPrefix} could not run z127_out ${DeviceName} -r " "${LogFile}"
        return "${ERR_VALUE}"
    fi
    if ! run_as_root z127_out "${DeviceName}" -s=1 > z127_out_set_1.log
    then
        debug_print "${LogPrefix} could not run z127_out ${DeviceName} -s=1 " "${LogFile}"
        return "${ERR_VALUE}"
    fi
    if ! run_as_root z127_out "${DeviceName}" -r > z127_out_read_1.log
    then
        debug_print "${LogPrefix} could not run z127_out ${DeviceName} -r " "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Compare gpio read values, example output:
    # -s=0
    #Port 15...0: 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
    #State      :  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
    # -s=1
    #Port 15...0: 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
    #State      :  0  0  0  0  0  0  1  1  1  1  1  1  1  1  1  1
    State0=$(grep "State" z127_out_read_0.log | awk NR==1'{print $9 $10 $11 $12 $13 $14 $15 $16 $17 $18}')
    State1=$(grep "State" z127_out_read_1.log | awk NR==1'{print $9 $10 $11 $12 $13 $14 $15 $16 $17 $18}')
    debug_print "${LogPrefix} State0: ${State0}" "${LogFile}"
    debug_print "${LogPrefix} State1: ${State1}" "${LogFile}"
    if [ "${State0}" = "0000000000" ] && [ "${State1}" = "1111111111" ]
    then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
