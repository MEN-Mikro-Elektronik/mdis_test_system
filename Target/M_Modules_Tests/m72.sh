#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m72 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m72_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M72 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Load module driver and run M-Module example programs"
    echo "    1.Load m-module drivers: modprobe men_ll_m72"
    echo "    2.Run example/verification program:"
    echo "      m72_out m72_${ModuleNo} and allow it to run couple second; save the command output"
    echo "    3.Run example/verification program:"
    echo "      m72_single m72_${ModuleNo} and save the command output"
    echo "    4.Verify if m72_single command output is valid - does not contain errors"
    echo "      The last line of counter should be != 000000"
    echo "PURPOSE:"
    echo "    Check if M-module m72 is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1760"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1924"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m72 test 
# 
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m72_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    if ! run_as_root modprobe men_ll_m72
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m72" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Run m72_out in background.
    if ! run_as_root $(stdbuf -oL m72_out m72_"${ModuleNo}" 0 < /dev/null > m72_out.log &)
    then
        debug_print "${LogPrefix} Could not run m72_out" "${LogFile}"
    fi

    # Here output from m72_out should be 0
    if ! run_as_root $(stdbuf -oL m72_single m72_"${ModuleNo}" 1 < /dev/null > m72_single_run.log &)
    then
        debug_print "${LogPrefix} Could not run m72_single" "${LogFile}"
    fi

    # Count changes for a while
    sleep 10

    M72_Out_PID=$(pgrep m72_single)
    M72_Single_PID=$(pgrep m72_out)

    # Kill background processes
    if ! run_as_root kill -9 "${M72_Out_PID}" > /dev/null 2>&1
    then
        debug_print "${LogPrefix} Could not kill m72_out" "${LogFile}"
    fi

    if ! run_as_root kill -9 "${M72_Single_PID}" > /dev/null 2>&1
    then
        debug_print "${LogPrefix} Could not kill m72_single" "${LogFile}"
    fi

    # Here output from m72_out should != 0 
    # It should be enough just to check the last line of counter, 
    # counter should be != 000000

    # to get last line
    # tac FILE | egrep -m 1 .
    # awk '/./{line=$0} END{print line}' FILE

    debug_print "${LogPrefix} Counter value is $(awk '/./{line=$0} END{print line}' m72_single_run.log)" "${LogFile}"

    local CounterValue=$(( 16#$( awk '/./{line=$0} END{print line}' m72_single_run.log | sed 's/counter=//' | awk -F'x' '{print $2}')))
    debug_print "${LogPrefix} Counter value is ${CounterValue}" "${LogFile}"

    if [ ${CounterValue} -eq "0" ]; then 
        debug_print "${LogPrefix} Counter value is ${CounterValue} = 0, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
