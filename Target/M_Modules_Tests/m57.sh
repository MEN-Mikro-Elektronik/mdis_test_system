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
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m57_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_profidp" "${LogFile}"
    if ! run_as_root modprobe men_ll_profidp
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_profidp" "${LogFile}" 
        return "${ERR_VALUE}"
    fi

    # Run profidp_simp
    debug_print "${LogPrefix} Step2: run profidp_simp m57_${ModuleNo}" "${LogFile}"
    sudo -S --prompt=$'\r' profidp_simp m57_"${ModuleNo}" < <(echo "${MenPcPassword}"; sleep 2; echo -ne '\n') > profidp_simp.log
    if [ $? -ne 0 ]
    then
        debug_print "${LogPrefix} Could not run profidp_simp " "${LogFile}"
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^M_open" profidp_simp.log > /dev/null && \
    grep "^Start Profibus protocol stack" profidp_simp.log > /dev/null && \
    grep "^Get FMB_FM2_EVENT reason" profidp_simp.log > /dev/null && \
    grep "^FMB_FM2_EVENT reason" profidp_simp.log > /dev/null && \
    grep "^Get Slave Diag" profidp_simp.log > /dev/null && \
    grep "station_status_1 = 01" profidp_simp.log > /dev/null && \
    grep "station_status_2 = 00" profidp_simp.log > /dev/null && \
    grep "station_status_3 = 00" profidp_simp.log > /dev/null && \
    grep "master_add = ff" profidp_simp.log > /dev/null && \
    grep "ident_number = 0000" profidp_simp.log > /dev/null && \
    grep "Stop Profibus protocol stack" profidp_simp.log > /dev/null && \
    grep "^M_close" profidp_simp.log > /dev/null
    if [ $? -ne 0 ]; then 
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi 

    return "${ERR_OK}"
}
