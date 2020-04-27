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
    echo "    1.Load m-module drivers: modprobe men_ll_m82"
    echo "    2.Run example/verification program:"
    echo "      m82_simp m82_${ModuleNo} and save the command output"
    echo "    3.Change relay output"
    echo "    4.Run example/verification program:"
    echo "      m82_simp m82_${ModuleNo} and save the command output"
    echo "    5.Output values of m82_simp commands should differ"
    echo "PURPOSE:"
    echo "    Check if M-module m82 is working correctly"
    echo "REQUIREMENT_ID:"
    echo "    MEN_13MD05-90_SA_1940"
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
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
# $4    Test Case name
function m82_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    debug_print "${LogPrefix} Step1:" "${LogFile}"
    m_module_x_test "${LogFile}" "${TestCaseName}" "${RelayOutput}" "m82" "${ModuleNo}" "" "${LogPrefix}"
    CmdResult=$?

    if [ "${CmdResult}" == "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

############################################################################
# compare_m82_simp_values,
# 
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function compare_m82_simp_values {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} compare_m82_simp_values" "${LogFile}"
    local ValueChannelConnected_0
    local ValueChannelDisconnected_0
    ValueChannelConnected_0=$(grep "channel  1 : " m82_"${ModuleNo}"_simp_output_connected.txt | awk NR==1'{print $4}')
    ValueChannelDisconnected_0=$(grep "channel  1 : " m82_"${ModuleNo}"_simp_output_disconnected.txt | awk NR==1'{print $4}')
    if [ "${ValueChannelConnected_0}" == "" ] || [ "${ValueChannelDisconnected_0}" == "" ] || \
       [ "${ValueChannelConnected_0}" -eq "${ValueChannelDisconnected_0}" ]; then
        debug_print "${LogPrefix} ValueChannelConnected_1 equal with ValueChannelDisconnected_1" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    local ValueChannelStateConnected
    local ValueChannelStateDisconnected
    ValueChannelStateConnected=$(grep "state: " m82_"${ModuleNo}"_simp_output_connected.txt | awk NR==1'{print $2 $3}')
    ValueChannelStateDisconnected=$(grep "state: " m82_"${ModuleNo}"_simp_output_disconnected.txt | awk NR==1'{print $2 $3}')
    if [ "${ValueChannelStateConnected}" == "" ] || [ "${ValueChannelStateDisconnected}" == "" ] || \
       [ "${ValueChannelStateConnected}" -eq "${ValueChannelStateDisconnected}" ]; then
        debug_print "${LogPrefix} ValueChannelStateConnected equal with ValueChannelStateDisconnected" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
