#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z037_gpio_description
#
# parameters:
# $1    Module number
# $2    Module log path
function z037_gpio_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "-------------------------Ip Core 16Z037_GPIO Test Case---------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "DESCRIPTION:"
    echo "    1.Read chameleon table from board"
    echo "    2.Load m-module drivers: modprobe men_ll_z17"
    echo "    3.Find GPIO devices on board"
    echo "    4.Check if there is 16Z037_GPIO"
    echo "    5.Run z17_simp on device 16Z037_GPIO"
    echo "    6.Check the results - result log shall contain no errors or warnings"
    echo "      Device was opened and closed succesfully"
    echo "      -To confirm that GPIO is working correctly z17_simp is running twice"
    echo "        First run - input 0V"
    echo "        Second run - input 12V"
    echo "        Relay is changing input automatically and return values are validated"
    echo "PURPOSE:"
    echo "    Check if ip core z037 with men_ll_z17 driver is working"
    echo "    correctly"
    echo "REQUIREMENT_ID:"
    echo "    MEN_13MD05-90_SA_1440"
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
function z037_gpio_test {
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

        # Find 16Z037_GPIO, check only first available device on mezzaine and exit!
        for i in $(seq 1 ${GpioNumber})
        do
            Gpio=$(grep "^gpio" "${MezzChamDevName}" | awk NR==${i}'{print $1}')
            GpioWizModel=$(obtain_device_wiz_model "${Gpio}")
            debug_print "${LogPrefix} Gpio ${Gpio} is type: ${GpioWizModel}" "${LogFile}"
            if [ "${GpioWizModel}" = "16Z037_GPIO" ]
            then
                # Test GPIO read
                if ! gpio_read "${LogFile}" "${LogPrefix}" "${Gpio}" "${RelayOutput}"
                then
                    debug_print "${LogPrefix} gpio_test on ${Gpio} error" "${LogFile}"
                    return "${ERR_VALUE}"
                else
                    debug_print "${LogPrefix} gpio_test on ${Gpio} success" "${LogFile}"
                    return "${ERR_OK}"
                fi
            fi
        done
    fi
    return "${ERR_VALUE}"
}

############################################################################
# Function checks if GPIO is working correctly - read
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    DeviceName
# $4    CommandCode - relay output
function gpio_read {
    local LogFile=${1}
    local LogPrefix=${2}
    local DeviceName=${3}
    local CommandCode=${4}

    debug_print "${LogPrefix} function gpio_test" "${LogPrefix}"

    # Make sure that input is disabled
    change_input "${LogFile}" "${LogPrefix}" $((CommandCode+100)) "${LogPrefix}"
    # Test GPIO, banana plugs are not connected to power source

    if ! run_as_root z17_simp "${DeviceName}" >> "z17_simp_${DeviceName}_banana_plug_disconnected.txt" 2>&1
    then
        debug_print "${LogPrefix} ERR_RUN :could not run z17_simp ${DeviceName}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Enable input
    change_input "${LogFile}" "${LogPrefix}" "${CommandCode}" "${LogPrefix}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        debug_print "${LogPrefix} Error: ${CmdResult} in function change_input" "${LogFile}"
        return "${CmdResult}"
    fi

    # Test GPIO, banana plugs are connected to power source
    run_as_root z17_simp "${DeviceName}" >> "z17_simp_${DeviceName}_banana_plug_connected.txt" 2>&1
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        debug_print "${LogPrefix} ERR_RUN :could not run z17_simp ${DeviceName}" "${LogFile}"
        return "${CmdResult}"
    fi

    # Disable input
    change_input "${LogFile}" "${LogPrefix}" $((CommandCode+100)) "${LogPrefix}"

    # Compare bit settings for read(s), shall be different
    local Index=4 #to 35
    local CheckValueDisconnected
    local CheckValueConnected
    CheckValueDisconnected=$(< "z17_simp_${DeviceName}_banana_plug_disconnected.txt" awk NR==${Index}'{print $18}')
    CheckValueConnected=$(< "z17_simp_${DeviceName}_banana_plug_connected.txt" awk NR==${Index}'{print $18}')
    for i in $(seq ${Index} 35)
    do
        if [ "${CheckValueDisconnected}" == "${CheckValueConnected}" ]; then
            debug_print "${LogPrefix} ERR GPIO - read values are the same" "${LogFile}"
            return "${ERR_VALUE}"
        fi
        CheckValueDisconnected=$(< "z17_simp_${DeviceName}_banana_plug_disconnected.txt" awk NR==${Index}'{print $18}') 
        CheckValueConnected=$(< "z17_simp_${DeviceName}_banana_plug_connected.txt" awk NR==${Index}'{print $18}')
    done

    return "${ERR_OK}"
}
