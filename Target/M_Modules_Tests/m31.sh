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
function m31_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "------------------------------M31 Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    m31_${ModuleNo}"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run 31 test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function m31_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    m_module_x_test "${LogFile}" "${TestCaseName}" "${RelayOutput}" "m31" "${ModuleNo}" "" "${LogPrefix}"
    MResult=$?
    if [ "${MResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

############################################################################
# compare_m31_simp_values
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function compare_m31_simp_values {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    print "${LogPrefix} compare_m31_simp_values" "${LogFile}"
    local ValueChannelConnected_0
    local ValueChannelDisconnected_0
    ValueChannelConnected_0=$(grep "channel  0 : " m31_"${ModuleNo}"_simp_output_connected.txt | awk NR==1'{print $4}')
    ValueChannelDisconnected_0=$(grep "channel  0 : " m31_"${ModuleNo}"_simp_output_disconnected.txt | awk NR==1'{print $4}')
    if [ "${ValueChannelConnected_0}" == "" ] || [ "${ValueChannelDisconnected_0}" == "" ] || \
       [ "${ValueChannelConnected_0}" -eq "${ValueChannelDisconnected_0}" ]; then
        debug_print "${LogPrefix} ValueChannelConnected_0 equal with ValueChannelDisconnected_0" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    local ValueChannelConnected_1
    local ValueChannelDisconnected_1
    ValueChannelConnected_1=$(grep "channel  0 : " m31_"${ModuleNo}"_simp_output_connected.txt | awk NR==1'{print $4}')
    ValueChannelDisconnected_1=$(grep "channel  0 : " m31_"${ModuleNo}"_simp_output_disconnected.txt | awk NR==1'{print $4}')
    if [ "${ValueChannelConnected_1}" == "" ] || [ "${ValueChannelDisconnected_1}" == "" ] || \
       [ "${ValueChannelConnected_1}" -eq "${ValueChannelDisconnected_1}" ]; then
        debug_print "${LogPrefix} ValueChannelConnected_1 equal with ValueChannelDisconnected_1" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    local ValueChannelStateConnected
    local ValueChannelStateDisconnected
    ValueChannelStateConnected=$(grep "state: " m31_"${ModuleNo}"_simp_output_connected.txt | awk NR==1'{print $2 $3}')
    ValueChannelStateDisconnected=$(grep "state: " m31_"${ModuleNo}"_simp_output_disconnected.txt | awk NR==1'{print $2 $3}')
    if [ "${ValueChannelStateConnected}" == "" ] || [ "${ValueChannelStateDisconnected}" == "" ] || \
       [ "${ValueChannelStateConnected}" -eq "${ValueChannelStateDisconnected}" ]; then
        debug_print "${LogPrefix} ValueChannelStateConnected equal with ValueChannelStateDisconnected" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
