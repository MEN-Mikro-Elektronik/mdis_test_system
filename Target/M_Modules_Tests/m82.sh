#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m82 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m82_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "------------------------------M82 Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    m82_${ModuleNo}"
    echo "PURPOSE:"
    echo "    Check if M-module m82 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run 82 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
# $4    Test Case name
function m82_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    echo "${LogPrefix} Step1:" | tee -a "${TestCaseLogName}" 2>&1
    m_module_x_test "${TestCaseLogName}" "${TestCaseName}" "${RelayOutput}" "m82" "${ModuleNo}" "" "${LogPrefix}"
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
# compare_m82_simp_values,
# 
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function compare_m82_simp_values {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} compare_m82_simp_values"
    local ValueChannelConnected_0
    local ValueChannelDisconnected_0
    ValueChannelConnected_0=$(grep "channel  1 : " m82_"${ModuleNo}"_simp_output_connected.txt | awk NR==1'{print $4}')
    ValueChannelDisconnected_0=$(grep "channel  1 : " m82_"${ModuleNo}"_simp_output_disconnected.txt | awk NR==1'{print $4}')
    if [ "${ValueChannelConnected_0}" == "" ] || [ "${ValueChannelDisconnected_0}" == "" ] || \
       [ "${ValueChannelConnected_0}" -eq "${ValueChannelDisconnected_0}" ]; then
        echo "${LogPrefix} ValueChannelConnected_1 equal with ValueChannelDisconnected_1"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    local ValueChannelStateConnected
    local ValueChannelStateDisconnected
    ValueChannelStateConnected=$(grep "state: " m82_"${ModuleNo}"_simp_output_connected.txt | awk NR==1'{print $2 $3}')
    ValueChannelStateDisconnected=$(grep "state: " m82_"${ModuleNo}"_simp_output_disconnected.txt | awk NR==1'{print $2 $3}')
    if [ "${ValueChannelStateConnected}" == "" ] || [ "${ValueChannelStateDisconnected}" == "" ] || \
       [ "${ValueChannelStateConnected}" -eq "${ValueChannelStateDisconnected}" ]; then
        echo "${LogPrefix} ValueChannelStateConnected equal with ValueChannelStateDisconnected"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
