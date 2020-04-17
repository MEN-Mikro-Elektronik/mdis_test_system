#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m37 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m37_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M37 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m37"
    echo "    2.Run example/verification program:"
    echo "      m37_simp m37_${ModuleNo} and save the command output"
    echo "    3.Verify if m37_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m37 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m37 test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m37_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_m37" "${LogFile}"
    if ! run_as_root modprobe men_ll_m37
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m37" "${LogFile}" 
        return "${ERR_VALUE}"
    fi

    # Run m37_simp
    debug_print "${LogPrefix} Step2: run m37_simp m37_${ModuleNo}" "${LogFile}"
    if ! run_as_root m37_simp m37_"${ModuleNo}" 0 > m37_simp.log
    then
      debug_print "${LogPrefix} Could not run m37_simp " "${LogFile}"
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^M_open(\" m37_${ModuleNo} \")" m37_simp.log > /dev/null && \
    grep "^channel number      : 0" m37_simp.log > /dev/null && \
    grep "^number of channels  : 4" m37_simp.log > /dev/null && \
    grep "^set channel 0 to -10.0V" m37_simp.log > /dev/null && \
    grep "^set channel 0 to +9.99..V" m37_simp.log > /dev/null && \
    grep "^M_close" m37_simp.log > /dev/null
    if [ $? -ne 0 ]; then 
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi 

    return "${ERR_OK}"
}
