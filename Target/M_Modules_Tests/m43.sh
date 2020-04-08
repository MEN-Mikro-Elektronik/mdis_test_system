#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m66 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m43_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "------------------------------M43 Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m43"
    echo "    2.Run example/verification program:"
    echo "      m43_ex1 m43_${ModuleNo} and save the command output"
    echo "    3.Verify if m43_ex1 command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m43 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run 43 test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
# $3    Test Case name
function m43_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    debug_print "${LogPrefix} Step1:" "${LogFile}"
    m_module_x_test "${LogFile}" "${TestCaseName}" "${RelayOutput}" "m43" "${ModuleNo}" "" "${LogPrefix}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        Step1="${CmdResult}"
    fi

    if [ "${Step1}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

############################################################################
# compare_m43_simp_values
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function compare_m43_simp_values {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    local DeviceOpened
    local DeviceClosed
    local EndLine
    DeviceOpened=$(grep -ic "Device m43_${ModuleNo} opened" m43_"${ModuleNo}"_simp_output_connected.txt)
    DeviceClosed=$(grep -ic "Device m43_${ModuleNo} closed" m43_"${ModuleNo}"_simp_output_connected.txt)
    EndLine=$(tail -1 m43_"${ModuleNo}"_simp_output_connected.txt)
    debug_print "${LogPrefix} DeviceOpened: ${DeviceOpened}, DeviceClosed: ${DeviceClosed}, EndLine: ${EndLine}" "${LogFile}"
    if [ "${DeviceOpened}" -eq 1 ] && [ "${DeviceClosed}" -eq 1 ] && [ "${EndLine}" == "=> OK" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

