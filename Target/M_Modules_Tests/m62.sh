#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m62 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m62_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "------------------------------M62 Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m62"
    echo "    2.Run example/verification program:"
    echo "      m62_simp m62_${ModuleNo} and save the command output"
    echo "    3.Verify if m62_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m62 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run 62 test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m62_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_m62" "${LogFile}"
    if ! run_as_root modprobe men_ll_m62
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m62" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    debug_print "${LogPrefix} Step2: run m62_simp m62n_${ModuleNo}" "${LogFile}"
    if ! run_as_root m62_simp m62n_"${ModuleNo}" > m62_simp.log 
    then
        debug_print "${LogPrefix} Could not run m62_simp " "${LogFile}"
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^channel 0: produce lowest to highest ramp..." m62_simp.log && \
    grep "^all channels: output range 0..10V.." m62_simp.log
    if [ $? -ne 0 ]; then 
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi 

    return "${ERR_OK}"
}
