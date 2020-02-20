#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m33 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m33_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "-----------------------M33 Test Case-------------------------------"
    echo "Prerequisites:"
    echo " - It is assumed that at this point all necessary drivers have been"
    echo "   build and are available in the system"
    echo " - M33 adapter is plugged into M33 m-module"
    echo "Steps:"
    echo " 1. Load m-module drivers: modprobe men_ll_m33"
    echo " 2. Run example/verification program:"
    echo "     m33_demo m33_${moduleNo} and save the command output"
    echo " 3. Verify if m33_demo command output is valid - does not contain"
    echo "    errors, and was opened, and closed succesfully"
    echo "Results:"
    echo " - SUCCESS / FAIL"
    echo " - in case of \"FAIL\", please check test case log file:"
    echo "   ${moduleLogPath}"
    echo "   For more detailed information please see corresponding log files"
    echo "   In test case repository"
    echo " - to see definition of all error codes please check Conf.sh"
}

############################################################################
# run m33 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m33_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_m33" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_m33
    then
        echo "${LogPrefix} ERR_VALUE: could not modprobe men_ll_m33" | tee -a "${TestCaseLogName}"
        return "${ERR_VALUE}"
    fi

    echo "${LogPrefix} Step2: run m33_demo m33_${ModuleNo}" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' m33_demo m33_"${ModuleNo}" > m33_demo.log
    then
        echo "${LogPrefix} Could not run m33_demo " \
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    grep "^Device m33_${ModuleNo}" m33_demo.log > /dev/null && \
    grep "^channel 0: produce ramps" m33_demo.log > /dev/null && \
    grep "^ lowest..highest ramp" m33_demo.log > /dev/null && \
    grep "^ highest..lowest ramp" m33_demo.log > /dev/null && \
    grep "^channel 0: toggle lowest/highest" m33_demo.log > /dev/null && \
    grep "^Device m33_1 closed" m33_demo.log > /dev/null
    if [ $? -ne 0 ]; then
            echo "${LogPrefix} Invalid log output, ERROR" \
              | tee -a "${TestCaseLogName}" 2>&1
            return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
