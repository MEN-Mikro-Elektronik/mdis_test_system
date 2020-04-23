#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m99 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m99_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------M99 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m99"
    echo "    2.Run example/verification program:"
    echo "      m99_latency m99_${moduleNo} and save the command output"
    echo "    3.Verify if m99_latency command output is valid - does not contain errors"
    echo "PURPOSE:"
    echo "    Check if M-module m99 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m99 test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m99_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local m99_latency_PID

    debug_print "${LogPrefix} Step1: modprobe men_ll_m99" "${LogFile}"
    if ! run_as_root modprobe men_ll_m99
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m99" "${LogFile}" 
        return "${ERR_VALUE}"
    fi

    # Run m99_latency
    debug_print "${LogPrefix} Step2: run m99_latency m99_${ModuleNo}" "${LogFile}"
    if ! run_as_root bash -c 'm99_latency m99_1 < <(sleep 10; echo "") > m99_latency.log)'
    then
        debug_print "${LogPrefix} Could not run m99_latency " "${LogFile}"
    fi

#    # Kill bacground processess m99_latency
#    m99_latency_PID=$(pgrep m99_latency)
#    sleep 10
#    if ! run_as_root kill -9 "${m99_latency_PID}" > /dev/null 2>&1
#    then
#        if pgrep m99_latency
#        then
#            debug_print "${LogPrefix} Could not kill m99_latency PID: ${m99_latency_PID}" "${LogFile}"
#        fi
#    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^generating interrupts: timerval=250" m99_latency.log > /dev/null && \
    grep "^[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+\([[:space:]]+[0-9]+[[:space:]]+\)[[:space:]]+\|[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+\([[:space:]]+[0-9]+[[:space:]]+" m99_latency.log > /dev/null
    if [ $? -ne 0 ]; then 
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi 

    return "${ERR_OK}"
}
