#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z034_z037_gpio_description
#
# parameters:
# $1    Module number
# $2    Module log path
function z034_z037_gpio_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "-------------------------Ip Core z034/z037 GPIO Test Case----------------------"
}

############################################################################
# IP core have to be tested on certain carrier, so user has to specify
# exact location of ip core in the system
#
# parameters:
# $1    Test case log name
# $2    Log prefix
# $3    Board vendor id
# $4    Board device id
# $5    Board subvendor id
# $6    Board number in system
# $7    Optional parameter - test type (optional)
function z034_z037_gpio_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}
    local RelayOutput=${IN_0_ENABLE}

    MezzChamDevName="MezzChamDevName.txt"
    obtain_device_list_chameleon_device "${VenID}" "${DevID}" "${SubVenID}" "${MezzChamDevName}" "${BoardInSystem}" "${TestCaseLogName}" "${LogPrefix}"

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_z17
    ResultModprobeZ17=$?
    if [ "${ResultModprobeZ17}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} ERR_MODPROBE :could not modprobe men_ll_z17" | tee -a "${TestCaseLogName}" 2>&1
        return "${ResultModprobeZ17}"
    else
        GpioNumber=$(grep "^gpio" "${MezzChamDevName}" | wc -l)
        if [ "${GpioNumber}" -ne "2" ]; then
            echo "${LogPrefix} There are ${GpioNumber} GPIO interfaces" \
              | tee -a "${TestCaseLogName}" 2>&1
        else
            GPIO1=$(grep "^gpio" "${MezzChamDevName}" | awk NR==1'{print $1}')
            GPIO2=$(grep "^gpio" "${MezzChamDevName}" | awk NR==2'{print $1}')
        fi

        # Test GPIO write (leds) - result not checked
        gpio_led "${TestCaseLogName}" "${LogPrefix}" "${GPIO1}" "${RelayOutput}"
        # Test GPIO read
        gpio_read "${TestCaseLogName}" "${LogPrefix}" "${GPIO2}" "${RelayOutput}"
        CmdResult=$?
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
            echo "${LogPrefix} gpio_test on ${GPIO2} err: ${CmdResult} "\
              | tee -a "${TestCaseLogName}" 2>&1
        else
            echo "${LogPrefix} gpio_test on ${GPIO2} success "\
              | tee -a "${TestCaseLogName}" 2>&1
        fi
    fi
    return "${CmdResult}"
}

############################################################################
# Function checks if GPIO is working correctly - read
#
# parameters:
# $1    Test case log file name
# $2    LogPrefix
# $3    DeviceName
# $4    CommandCode
function gpio_read {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local DeviceName=${3}
    local CommandCode=${4}

    echo "${LogPrefix} function gpio_test"

    # Make sure that input is disabled
    change_input "${TestCaseLogName}" "${LogPrefix}" $((CommandCode+100)) "${InputSwitchTimeout}" "${LogPrefix}"
    # Test GPIO, banana plugs are not connected to power source
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' z17_simp "${DeviceName}" >> z17_simp_${DeviceName}_banana_plug_disconnected.txt 2>&1
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} ERR_RUN :could not run z17_simp ${DeviceName}" | tee -a "${TestCaseLogName}" 2>&1
        return "${CmdResult}"
    fi

    # Enable input
    change_input "${TestCaseLogName}" "${LogPrefix}" "${CommandCode}" "${InputSwitchTimeout}" "${LogPrefix}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} Error: ${CmdResult} in function change_input" | tee -a "${TestCaseLogName}" 2>&1
        return "${CmdResult}"
    fi

    # Test GPIO, banana plugs are connected to power source
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' z17_simp ${DeviceName} >> z17_simp_${DeviceName}_banana_plug_connected.txt 2>&1
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} ERR_RUN :could not run z17_simp ${GPIO1}" | tee -a "${TestCaseLogName}" 2>&1
        return "${CmdResult}"
    fi

    # Disable input
    change_input "${TestCaseLogName}" "${LogPrefix}" $((CommandCode+100)) "${InputSwitchTimeout}" "${LogPrefix}"

    # Compare bit settings for read(s), shall be different
    local Index=4 #to 35
    local CheckValueDisconnected=$(cat z17_simp_"${DeviceName}"_banana_plug_disconnected.txt | awk NR==${Index}'{print $18}') 
    local CheckValueConnected=$(cat z17_simp_"${DeviceName}"_banana_plug_connected.txt | awk NR==${Index}'{print $18}')
    for i in $(seq ${Index} 35)
    do
        if [ "${CheckValueDisconnected}" == "${CheckValueConnected}" ]; then
            echo "${LogPrefix} ERR GPIO - read values are the same"
            return ${ERR_VALUE}
        fi
        CheckValueDisconnected=$(cat z17_simp_"${DeviceName}"_banana_plug_disconnected.txt | awk NR==${Index}'{print $18}') 
        CheckValueConnected=$(cat z17_simp_"${DeviceName}"_banana_plug_connected.txt | awk NR==${Index}'{print $18}')
    done

    return "${ERR_OK}"
}

############################################################################
# Function checks if GPIO is working correctly - read
#
# parameters:
# $1    Test case log file name
# $2    LogPrefix
# $3    DeviceName
function gpio_led {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local DeviceName=${3}
    echo "${LogPrefix} change LED(s)" | tee -a "${TestCaseLogName}" 2>&1

    # Test LEDS -- This cannot be checked automatically yet
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' z17_simp "${DeviceName}" >> z17_simp_"${DeviceName}".txt 2>&1
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} ERR_RUN :could not run z17_simp ${DeviceName}" | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi
    return "${ERR_OK}"
}

