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
    echo "    1.Load m-module drivers: modprobe men_ll_m72"
    echo "    2.Run example/verification program:"
    echo "      m72_out m72_${ModuleNo} and allow it to run couple second; save the command output"
    echo "    3.Run example/verification program:"
    echo "      m72_single m72_"${ModuleNo}" and save the command output"
    echo "    4.Verify if m72_single command output is valid - does not contain errors"
    echo "      The last line of counter should be != 000000"
    echo "PURPOSE:"
    echo "    Check if M-module m72 is working correctly"
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
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m72_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_m72
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m72" | tee -a "${TestCaseLogName}"
        return "${ERR_VALUE}"
    fi

    # Run m72_out in background. 
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' stdbuf -oL m72_out m72_"${ModuleNo}" 0 < /dev/null > m72_out.log &
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Could not run m72_out "\
          | tee -a "${TestCaseLogName}" 2>&1

    fi
    # Save background process PID 
    M72_Out_PID=$!

    # Here output from m72_out should be 0
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' stdbuf -oL m72_single m72_"${ModuleNo}" 1 < /dev/null > m72_single_run.log &
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Could not run m72_out "\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    M72_Single_PID=$!

    # Count changes for a while ...
    sleep 10
    echo "${LogPrefix} Processes to kill: "
    echo "${LogPrefix} M72_Out_PID: ${M72_Out_PID}"
    echo "${LogPrefix} M72_Single_PID: ${M72_Single_PID}"

    # Kill background processes  sudo stdbuf 
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' kill -9 "${M72_Out_PID}"
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Could not kill m72_out"\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' kill -9 "${M72_Single_PID}"
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Could not kill m72_single"\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    # Kill bacground processess m72_single, m72_out
    M72_Out_PID=$(ps aux | grep m72_single | awk 'NR==1 {print $2}')
    M72_Single_PID=$(ps aux | grep m72_out | awk 'NR==1 {print $2}')

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' kill -9 "${M72_Out_PID}"
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Could not kill m72_out"\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' kill -9 "${M72_Single_PID}"
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} Could not kill m72_single"\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    # Here output from m72_out should != 0 
    # It should be enough just to check the last line of counter, 
    # counter should be != 000000

    # to get last line
    # tac FILE | egrep -m 1 .
    # awk '/./{line=$0} END{print line}' FILE

    echo "${LogPrefix} Counter value is $(awk '/./{line=$0} END{print line}' m72_single_run.log)"\
      | tee -a "${TestCaseLogName}" 2>&1

    local CounterValue=$(( 16#$( awk '/./{line=$0} END{print line}' m72_single_run.log | sed 's/counter=//' | awk -F'x' '{print $2}')))
    echo "${LogPrefix} Counter value is ${CounterValue}"\
      | tee -a "${TestCaseLogName}" 2>&1

    if [ ${CounterValue} -eq "0" ]; then 
        echo "${LogPrefix} Counter value is ${CounterValue} = 0, ERROR"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
