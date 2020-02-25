#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m36 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m36_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "------------------------------M36 Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    "
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m36 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m36_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    echo "${LogPrefix} Step1:" | tee -a "${TestCaseLogName}" 2>&1
    m_module_x_test "${TestCaseLogName}" "${TestCaseName}" "${RelayOutput}" "m36" "${ModuleNo}" "" "${LogPrefix}"
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
# compare_m36_simp_values,
# 
# parameters:
# $1    Test case log file name
# $2    Test case name
# $3    M36 board number
function compare_m36_simp_values {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    local ModuleNo=${3}
    local LogPrefix="[compare_m36]"

    echo "${LogPrefix} compare_m36_simp_values"

    local ValueChannelStateConnected
    local ValueChannelStateDisconnected
    ValueChannelStateConnected=$(cat m36n_${ModuleNo}_simp_output_connected.txt | awk NR==6'{print $4}')
    ValueChannelStateDisconnected=$(cat m36n_${ModuleNo}_simp_output_disconnected.txt | awk NR==6'{print $4}')

    echo "${LogPrefix} ValueChannelStateConnected: ${ValueChannelStateConnected}"
    echo "${LogPrefix} ValueChannelStateDisconnected: ${ValueChannelStateDisconnected}"

    # replace '.' with ','
    #ValueChannelStateConnected=$(echo ${ValueChannelStateConnected} | sed 's/\./,/')
    #ValueChannelStateDisconnected=$(echo ${ValueChannelStateDisconnected} | sed 's/\./,/')

    echo "${LogPrefix} ValueChannelStateConnected: ${ValueChannelStateConnected} V"
    echo "${LogPrefix} ValueChannelStateDisconnected: ${ValueChannelStateDisconnected} V"

    local ValueLow="0.2"
    local ValueHigh="9.8"

    if (( $(echo "${ValueChannelStateDisconnected} > ${ValueLow}" |bc -l) )); then
        echo "${LogPrefix} ValueChannelStateConnected is not ~ 0 "\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    if (( $(echo "${ValueChannelStateConnected} < ${ValueHigh}" |bc -l) )); then
        echo "${LogPrefix} ValueChannelStateConnected is not ~ 10 Volts "\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}