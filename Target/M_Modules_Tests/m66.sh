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
function m66_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "------------------------------M66 Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    m66_${ModuleNo}"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run 66 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
# $4    Test Case Name
function m66_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    echo "${LogPrefix} Step1:" | tee -a "${TestCaseLogName}" 2>&1
    m_module_x_test "${TestCaseLogName}" "${TestCaseName}" "${RelayOutput}" "m66" "${ModuleNo}" "" "${LogPrefix}"
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
# compare_m66_simp_values
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function compare_m66_simp_values {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    # Compare results
    # Write and Read values should be the same when connected,
    local IndexCnt
    local IndexOffset
    IndexCnt=$(grep -c "M_write" m66_"${ModuleNo}"_simp_output_connected.txt)
    IndexOffset=$(grep -n "M_write" m66_"${ModuleNo}"_simp_output_connected.txt | cut -f1 -d: | awk NR==1)

    if [ "${IndexCnt}" -ne 0 ]; then
        for i in $(seq $((IndexOffset)) $((IndexCnt+IndexOffset-1)))
        do
            CheckValueConnectedWrite=$(cat m66_"${ModuleNo}"_simp_output_connected.txt | awk NR==${i}'{print $4}') 
            CheckValueConnectedRead=$(cat m66_"${ModuleNo}"_simp_output_connected.txt | awk NR==${i}'{print $9}')
            if [ "${CheckValueConnectedWrite}" != "${CheckValueConnectedRead}" ]; then
                echo "${LogPrefix} read values are not equal line: ${i}" | tee -a "${TestCaseLogName}" 2>&1
                return "${ERR_VALUE}"
            fi
        done
    fi
    # Write and Read values should be different when disconnected
    if [ "${IndexCnt}" -ne 0 ]; then
        for i in $(seq $((IndexOffset)) $((IndexCnt+IndexOffset-1)))
        do
            CheckValueConnectedRead=$(cat m66_"${ModuleNo}"_simp_output_disconnected.txt | awk NR==${i}'{print $9}')
            if [ "${CheckValueConnectedRead}" != "1" ]; then
                echo "${LogPrefix} read values are not equal to 1 line: ${i}" | tee -a "${TestCaseLogName}" 2>&1
                return "${ERR_VALUE}"
            fi
        done
    fi

    return "${ERR_OK}"
}
