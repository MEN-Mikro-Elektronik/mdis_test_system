#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m47 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m47_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M47 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m47"
    echo "    2.Run example/verification program:"
    echo "      m47_simp m47_${ModuleNo} and save the command output"
    echo "    3.Verify if m47_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m47 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m47 test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m47_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_m47" "${LogFile}"
    if ! run_as_root modprobe men_ll_m47
    then
        debug_print "${LogPrefix} ERR_VALUE: could not modprobe men_ll_m47" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Run m47_simp
    debug_print "${LogPrefix} Step2: run m47_simp m47_${ModuleNo}" "${LogFile}"

    if ! run_as_root m47_simp m47_"${ModuleNo}" > m47_simp.log
    then
        debug_print "${LogPrefix} Could not run m47_simp " "${LogFile}"
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^ Device name: m47_${ModuleNo}" m47_simp.log > /dev/null && \
    grep "^ Channel: 0" m47_simp.log > /dev/null && \
    grep "^M_open" m47_simp.log > /dev/null && \
    grep "^Read value = 00000000" m47_simp.log > /dev/null && \
    grep "^M_close" m47_simp.log > /dev/null
    if [ $? -ne 0 ]; then
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
