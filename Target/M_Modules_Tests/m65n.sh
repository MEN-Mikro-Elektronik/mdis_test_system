#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m65n test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m65n_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------M65N Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "    M65N adapter is plugged into M65N m-module"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_icanl2"
    echo "    2.Run example/verification program:"
    echo "      icanl2_veri m65_${moduleNo}a m65_${moduleNo}b -n=2 and save the command"
    echo "      output"
    echo "    3.Verify if icanl2_veri command output is valid - does not contain"
    echo "      errors (find line 'TEST RESULT: 0 errors)"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# m65n_test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m65n_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_icanl2" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_icanl2
    then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_icanl2" | tee -a "${TestCaseLogName}"
        return "${ERR_VALUE}"
    fi

    # Run icanl2_veri tests twice
    echo "${LogPrefix} Step2: run icanl2_veri m65_${ModuleNo}a m65_${ModuleNo}b -n=2" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' icanl2_veri m65_"${ModuleNo}"a m65_"${ModuleNo}"b -n=2 > icanl2_veri.log
    then
        echo "${LogPrefix} Could not run icanl2_veri "\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    if ! grep "TEST RESULT: 0 errors" icanl2_veri.log > /dev/null
    then
        echo "${LogPrefix} Invalid log output, ERROR"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
