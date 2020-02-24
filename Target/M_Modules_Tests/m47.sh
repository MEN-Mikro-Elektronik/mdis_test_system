#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m47 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m47_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------M47 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m47"
    echo "    2.Run example/verification program:"
    echo "      m47_simp m47_${moduleNo} and save the command output"
    echo "    3.Verify if m47_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m47 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m47_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_m47" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_m47
    then
        echo "${LogPrefix} ERR_VALUE: could not modprobe men_ll_m47"\
         | tee -a "${TestCaseLogName}"
        return "${ERR_VALUE}"
    fi

    # Run m47_simp
    echo "${LogPrefix} Step2: run m47_simp m47_${ModuleNo}"\
     | tee -a "${TestCaseLogName}" 2>&1

    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' m47_simp m47_"${ModuleNo}" > m47_simp.log
    then
        echo "${LogPrefix} Could not run m47_simp "\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    grep "^ Device name: m47_${ModuleNo}" m47_simp.log > /dev/null && \
    grep "^ Channel: 0" m47_simp.log > /dev/null && \
    grep "^M_open" m47_simp.log > /dev/null && \
    grep "^Read value = 00000000" m47_simp.log > /dev/null && \
    grep "^M_close" m47_simp.log > /dev/null
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Invalid log output, ERROR"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
