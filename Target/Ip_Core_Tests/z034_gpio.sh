#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z034_gpio_description
#
# parameters:
# $1    Module number
# $2    Module log path
function z034_gpio_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "-------------------------Ip Core 16Z034_GPIO Test Case---------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "DESCRIPTION:"
    echo "    1.Read chameleon table from board"
    echo "    2.Load m-module drivers: modprobe men_ll_z17"
    echo "    3.Find GPIO devices on board"
    echo "    4.Check if there is 16Z034_GPIO"
    echo "    5.Run z17_simp on device 16Z034_GPIO"
    echo "      -LED(s) blinking is not verified"
    echo "    6.Check the results - result log shall contain no errors or warnings"
    echo "      Device shall be opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if ip core 16Z034_GPIO with men_ll_z17 driver is working"
    echo "    correctly"
    echo "REQUIREMENT_ID:"
    echo "    MEN_13MD05-90_SA_1430"
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
function z034_gpio_test {
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

    if ! run_as_root modprobe men_ll_z17
    then
        debug_print "${LogPrefix} ERR_MODPROBE :could not modprobe men_ll_z17" "${LogFile}"
        return "${ERR_MODPROBE}"
    else
        GpioNumber=$(grep -c "^gpio" "${MezzChamDevName}")
        debug_print "${LogPrefix} There are ${GpioNumber} GPIO interfaces on ${MezzChamDevName}" "${LogFile}"

        # Find 16Z034_GPIO, check only first available device on mezzaine and exit!
        for i in $(seq 1 ${GpioNumber})
        do
            Gpio=$(grep "^gpio" "${MezzChamDevName}" | awk NR==${i}'{print $1}')
            GpioWizModel=$(obtain_device_wiz_model "${Gpio}")
            debug_print "${LogPrefix} Gpio ${Gpio} is type: ${GpioWizModel}" "${LogFile}"
            if [ "${GpioWizModel}" = "16Z034_GPIO" ]
            then
                # Test GPIO write (leds)
                gpio_led "${LogFile}" "${LogPrefix}" "${Gpio}"
                Result=$?
                debug_print "${LogPrefix} gpio_led ${Gpio} test result: ${Result}" "${LogFile}"
                return "${Result}"
            fi
        done
    fi

    return "${ERR_VALUE}"
}

############################################################################
# Function checks if GPIO is working correctly - write
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    DeviceName
function gpio_led {
    local LogFile=${1}
    local LogPrefix=${2}
    local DeviceName=${3}

    debug_print "${LogPrefix} change LED(s)" "${LogFile}"

    # Test LEDS -- check if device was opened, and closed successfully
    if ! run_as_root z17_simp "${DeviceName}" >> "z17_simp_${DeviceName}.txt" 2>&1
    then
        debug_print "${LogPrefix} ERR_RUN :could not run z17_simp ${DeviceName}" "${LogFile}"
        return "${ERR_VALUE}"
    fi
    return "${ERR_OK}"
}

