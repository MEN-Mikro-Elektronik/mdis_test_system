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
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "------------------------------M43 Test Case-----------------------------------"
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
# run 43 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m43_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    echo "${LogPrefix} Step1:" | tee -a "${TestCaseLogName}" 2>&1
    m_module_x_test "${TestCaseLogName}" "${TestCaseName}" "${RelayOutput}" "m43" "${ModuleNo}" "" "${LogPrefix}"
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
# $1    Test case log file name
# $2    Test case name
# $3    M43 board number
#
function compare_m43_simp_values {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    local M43Nr=${3}
    local LogPrefix="[compare_m43]"

    local DeviceOpened
    local DeviceClosed
    local EndLine
    DeviceOpened=$(grep -i "Device m43_${M43Nr} opened" m43_${M43Nr}_simp_output_connected.txt | wc -l)
    DeviceClosed=$(grep -i "Device m43_${M43Nr} closed" m43_${M43Nr}_simp_output_connected.txt | wc -l)
    EndLine=$(tail -1 m43_${M43Nr}_simp_output_connected.txt)
    echo "${LogPrefix} DeviceOpened: ${DeviceOpened}, DeviceClosed: ${DeviceClosed}, EndLine: ${EndLine}"  | tee -a "${TestCaseLogName}" 2>&1
    if [ ${DeviceOpened} -eq 1 ] && [ ${DeviceClosed} -eq 1 ] && [ "${EndLine}" == "=> OK" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

