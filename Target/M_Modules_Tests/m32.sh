#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m32 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m32_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M32 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m31"
    echo "    2.Run example/verification program:"
    echo "      m31_simp m32_${ModuleNo} and save the command output"
    echo "    3.Verify if profidp_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m32 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m32_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_m31" | tee -a "${TestCaseLogName}" 2>&1
    if echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_m31
    then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m31"\
         | tee -a "${TestCaseLogName}"
        return "${ERR_VALUE}"
    fi

    # Run m31_simp
    echo "${LogPrefix} Step2: run m31_simp m32_${ModuleNo}" | tee -a "${TestCaseLogName}" 2>&1
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' m31_simp m32_"${ModuleNo}" > m31_simp.log
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Could not run m31_simp "\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    grep "^ device m32_${ModuleNo} opened" m31_simp.log && \
    grep "^ number of channels:      16" m31_simp.log && \
    grep "^ channel  0 : 1" m31_simp.log && \
    grep "^ channel  1 : 1" m31_simp.log && \
    grep "^ channel  2 : 1" m31_simp.log && \
    grep "^ channel  3 : 1" m31_simp.log && \
    grep "^ channel  4 : 1" m31_simp.log && \
    grep "^ channel  5 : 1" m31_simp.log && \
    grep "^ channel  6 : 1" m31_simp.log && \
    grep "^ channel  7 : 1" m31_simp.log && \
    grep "^ channel  8 : 1" m31_simp.log && \
    grep "^ channel  9 : 1" m31_simp.log && \
    grep "^ channel 10 : 1" m31_simp.log && \
    grep "^ channel 11 : 1" m31_simp.log && \
    grep "^ channel 12 : 1" m31_simp.log && \
    grep "^ channel 13 : 1" m31_simp.log && \
    grep "^ channel 14 : 1" m31_simp.log && \
    grep "^ channel 15 : 1" m31_simp.log && \
    grep "^ channel:   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15" m31_simp.log && \
    grep "^ state:     1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1" m31_simp.log && \
    grep "^ device m32_${ModuleNo} closed" m31_simp.log
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Invalid log output, ERROR"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
