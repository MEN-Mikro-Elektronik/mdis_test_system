#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m72 test description
#
# parameters:
# $1    Module number
# $2    Module log path
function z034_z037_gpio_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "-------------------------Ip Core z034/z037 CAN Test Case----------------------"
}


function z034_z037_gpio_test {
    echo "z034_z037_gpio_test is empty"
}

############################################################################
# Function checks if GPIO is working correctly
#
# parameters:
# $1    Test case log file name
# $2    Test case name
# $3    GPIO number
# $4    Command Code
#
function gpio_test {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    local GpioNr=${3}
    local CommandCode=${4}
    local LogPrefix="[Gpio_Test]"
    echo "${LogPrefix} function gpio_test"

    # Make sure that input is disabled
    change_input "${TestCaseLogName}" "${TestCaseName}" $((CommandCode+100)) "${InputSwitchTimeout}" "${LogPrefix}"
    # Test GPIO, banana plugs are not connected to power source
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' z17_simp ${GPIO2} >> z17_simp_${GPIO2}_banana_plug_disconnected.txt 2>&1
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} ERR_RUN :could not run z17_simp ${GPIO2}" | tee -a "${TestCaseLogName}" 2>&1
        return "${CmdResult}"
    fi

    # Enable input
    change_input "${TestCaseLogName}" "${TestCaseName}" "${CommandCode}" "${InputSwitchTimeout}" "${LogPrefix}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} Error: ${CmdResult} in function change_input" | tee -a "${TestCaseLogName}" 2>&1
        return "${CmdResult}"
    fi

    # Test GPIO, banana plugs are connected to power source
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' z17_simp ${GPIO2} >> z17_simp_${GPIO2}_banana_plug_connected.txt 2>&1
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} ERR_RUN :could not run z17_simp ${GPIO1}" | tee -a "${TestCaseLogName}" 2>&1
        return "${CmdResult}"
    fi

    # Disable input
    change_input "${TestCaseLogName}" "${TestCaseName}" $((CommandCode+100)) "${InputSwitchTimeout}" "${LogPrefix}"

    # Compare bit settings for read(s), shall be different
    local Index=4 #to 35
    local CheckValueDisconnected=$(cat z17_simp_"${GPIO2}"_banana_plug_disconnected.txt | awk NR==${Index}'{print $18}') 
    local CheckValueConnected=$(cat z17_simp_"${GPIO2}"_banana_plug_connected.txt | awk NR==${Index}'{print $18}')
    for i in $(seq ${Index} 35)
    do
        if [ "${CheckValueDisconnected}" == "${CheckValueConnected}" ]; then
            echo "${LogPrefix} ERR GPIO - read values are the same"
            return ${ERR_VALUE}
        fi
        CheckValueDisconnected=$(cat z17_simp_"${GPIO2}"_banana_plug_disconnected.txt | awk NR==${Index}'{print $18}') 
        CheckValueConnected=$(cat z17_simp_"${GPIO2}"_banana_plug_connected.txt | awk NR==${Index}'{print $18}')
    done

    return "${ERR_OK}"
}
