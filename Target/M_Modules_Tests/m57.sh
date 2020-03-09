#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m57 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m57_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------M57 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_profidp"
    echo "    2.Run example/verification program:"
    echo "      profidp_simp m57_${moduleNo} and save the command output"
    echo "    3.Verify if profidp_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m57 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m57 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m57_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_profidp" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_profidp
    then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_profidp"\
          | tee -a "${TestCaseLogName}" 
        return "${ERR_VALUE}"
    fi

    # Run profidp_simp
    echo "${LogPrefix} Step2: run profidp_simp m57_${ModuleNo}" | tee -a "${TestCaseLogName}" 2>&1
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' profidp_simp m57_"${ModuleNo}" < <(sleep 2; echo -ne '\n') > profidp_simp.log
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Could not run profidp_simp "\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    grep "^M_open" profidp_simp.log && \
    grep "^Start Profibus protocol stack" profidp_simp.log && \
    grep "^Get FMB_FM2_EVENT reason" profidp_simp.log && \
    grep "^FMB_FM2_EVENT reason" profidp_simp.log && \
    grep "^Get Slave Diag" profidp_simp.log && \
    grep "station_status_1 = 01" profidp_simp.log && \
    grep "station_status_2 = 00" profidp_simp.log && \
    grep "station_status_3 = 00" profidp_simp.log && \
    grep "master_add = ff" profidp_simp.log && \
    grep "ident_number = 0000" profidp_simp.log && \
    grep "Stop Profibus protocol stack" profidp_simp.log && \
    grep "^M_close" profidp_simp.log
    if [ $? -ne 0 ]; then 
        echo "${LogPrefix} Invalid log output, ERROR"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi 

    return "${ERR_OK}"
}
