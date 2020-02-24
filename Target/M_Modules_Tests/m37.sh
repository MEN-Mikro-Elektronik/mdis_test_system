#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m37 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m37_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------M37 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m37"
    echo "    2.Run example/verification program:"
    echo "      m37_simp m37_${moduleNo} and save the command output"
    echo "    3.Verify if profidp_simp command output is valid - does not contain errors"
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
# run m32 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m37_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_m37" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_m37
    then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m37"\
         | tee -a "${TestCaseLogName}" 
        return "${ERR_VALUE}"
    fi

    # Run m37_simp
    echo "${LogPrefix} Step2: run m37_simp m37_${ModuleNo}" | tee -a "${TestCaseLogName}" 2>&1
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' m37_simp m37_"${ModuleNo}" 0 > m37_simp.log
    if [ $? -ne 0 ]; then
      echo "${LogPrefix} Could not run m37_simp "\
        | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    grep "^M_open(\" m37_${ModuleNo} \")" m37_simp.log && \
    grep "^channel number      : 0" m37_simp.log && \
    grep "^number of channels  : 4" m37_simp.log && \
    grep "^set channel 0 to -10.0V" m37_simp.log && \
    grep "^set channel 0 to +9.99..V" m37_simp.log && \
    grep "^M_close" m37_simp.log
    if [ $? -ne 0 ]; then 
        echo "${LogPrefix} Invalid log output, ERROR"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi 

    return "${ERR_OK}"
}
