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
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------M72 Test Case---------------------------------"
}

############################################################################
# run m72 test 
# 
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m_module_m72_test {
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
