#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m58 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m58_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M58 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m58"
    echo "    2.Run example/verification program:"
    echo "      m58_simp m58_${ModuleNo} and save the command output"
    echo "    3.Verify if m58_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m58 is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1640"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1890"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m58 test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m58_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_m58" "${LogFile}"
    if ! run_as_root modprobe men_ll_m58
    then
        debug_print "${LogPrefix} ERR_VALUE: could not modprobe men_ll_m58" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Run m58_simp
    debug_print "${LogPrefix} Step2: run m58_simp m58_${ModuleNo}" "${LogFile}"
    if ! run_as_root m58_simp m58_"${ModuleNo}" < <(echo -ne '\n') > m58_simp.log
    then
        debug_print "${LogPrefix} Could not run m58_simp " "${LogFile}"
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^open m58_${ModuleNo}" m58_simp.log > /dev/null && \
    grep "^channel 2: write 0x22 = 0010 0010" m58_simp.log > /dev/null && \
    grep "^channel 3: write 0x44 = 0100 0100" m58_simp.log > /dev/null && \
    grep "^success." m58_simp.log > /dev/null && \
    grep "^close device" m58_simp.log > /dev/null
    if [ $? -ne 0 ]; then 
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi 

    return "${ERR_OK}"
}

