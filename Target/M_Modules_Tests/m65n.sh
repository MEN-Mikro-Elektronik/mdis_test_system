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
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M65N Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "    M65N adapter is plugged into M65N m-module"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_icanl2"
    echo "    2.Run example/verification program:"
    echo "      icanl2_veri m65_${ModuleNo}a m65_${ModuleNo}b -n=2 and save the command"
    echo "      output"
    echo "    3.Verify if icanl2_veri command output is valid - does not contain"
    echo "      errors (find line 'TEST RESULT: 0 errors)"
    echo "PURPOSE:"
    echo "    Check if M-module m65n is working correctly"
    echo "REQUIREMENT_ID:"
    echo "    MEN_13MD05-90_SA_1910"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# m65n_test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m65n_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_icanl2" "${LogFile}"
    if ! run_as_root modprobe men_ll_icanl2
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_icanl2" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Run icanl2_veri tests twice
    debug_print "${LogPrefix} Step2: run icanl2_veri m65_${ModuleNo}a m65_${ModuleNo}b -n=2" "${LogFile}"
    if ! run_as_root icanl2_veri m65_"${ModuleNo}"a m65_"${ModuleNo}"b -n=2 > icanl2_veri.log
    then
        debug_print "${LogPrefix} Could not run icanl2_veri "\
          | tee -a "${LogFile}" 2>&1
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    if ! grep "TEST RESULT: 0 errors" icanl2_veri.log > /dev/null
    then
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
