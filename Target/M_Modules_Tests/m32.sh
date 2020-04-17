#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m32 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m32_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M32 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m31"
    echo "    2.Run example/verification program:"
    echo "      m31_simp m32_${ModuleNo} and save the command output"
    echo "    3.Verify if m31_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m32 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run 31 test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function m32_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_m31" "${LogFile}"
    if ! run_as_root modprobe men_ll_m31
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m31" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Run m31_simp
    debug_print "${LogPrefix} Step2: run m31_simp m32_${ModuleNo}" "${LogFile}"
    if ! run_as_root m31_simp m32_"${ModuleNo}" > m31_simp.log
    then
        debug_print "${LogPrefix} Could not run m31_simp " "${LogFile}"
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^ device m32_${ModuleNo} opened" m31_simp.log > /dev/null && \
    grep "^ number of channels:      16" m31_simp.log > /dev/null && \
    grep "^ channel  0 : 1" m31_simp.log > /dev/null && \
    grep "^ channel  1 : 1" m31_simp.log > /dev/null && \
    grep "^ channel  2 : 1" m31_simp.log > /dev/null && \
    grep "^ channel  3 : 1" m31_simp.log > /dev/null && \
    grep "^ channel  4 : 1" m31_simp.log > /dev/null && \
    grep "^ channel  5 : 1" m31_simp.log > /dev/null && \
    grep "^ channel  6 : 1" m31_simp.log > /dev/null && \
    grep "^ channel  7 : 1" m31_simp.log > /dev/null && \
    grep "^ channel  8 : 1" m31_simp.log > /dev/null && \
    grep "^ channel  9 : 1" m31_simp.log > /dev/null && \
    grep "^ channel 10 : 1" m31_simp.log > /dev/null && \
    grep "^ channel 11 : 1" m31_simp.log > /dev/null && \
    grep "^ channel 12 : 1" m31_simp.log > /dev/null && \
    grep "^ channel 13 : 1" m31_simp.log > /dev/null && \
    grep "^ channel 14 : 1" m31_simp.log > /dev/null && \
    grep "^ channel 15 : 1" m31_simp.log > /dev/null && \
    grep "^ channel:   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15" m31_simp.log > /dev/null && \
    grep "^ state:     1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1" m31_simp.log > /dev/null && \
    grep "^ device m32_${ModuleNo} closed" m31_simp.log > /dev/null
    if [ $? -ne 0 ]; then
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
