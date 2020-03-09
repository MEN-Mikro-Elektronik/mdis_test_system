#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m58 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m58_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M58 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m58"
    echo "    2.Run example/verification program:"
    echo "      m58_simp m58_${ModuleNo} and save the command output"
    echo "    3.Verify if m58_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m58 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m58 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m58_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_m58" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_m58
    then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m58"\
         | tee -a "${TestCaseLogName}" 
        return "${ERR_VALUE}"
    fi

    # Run m58_simp
    echo "${LogPrefix} Step2: run m58_simp m58_${ModuleNo}" | tee -a "${TestCaseLogName}" 2>&1
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' m58_simp m58_"${ModuleNo}" < <(echo -ne '\n') > m58_simp.log
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Could not run m58_simp "\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    grep "^open m58_${ModuleNo}" m58_simp.log && \
    grep "^channel 2: write 0x22 = 0010 0010" m58_simp.log && \
    grep "^channel 3: write 0x44 = 0100 0100" m58_simp.log && \
    grep "^success." m58_simp.log && \
    grep "^close device" m58_simp.log
    if [ $? -ne 0 ]; then 
        echo "${LogPrefix} Invalid log output, ERROR"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi 

    return "${ERR_OK}"
}

