#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m33 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m33_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M33 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "    M33 adapter is plugged into M33 m-module"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_m33"
    echo "    2.Run example/verification program:"
    echo "      m33_demo m33_${ModuleNo} and save the command output"
    echo "    3.Verify if m33_demo command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m33 is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1460"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1830"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m33 test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function m33_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_m33" "${LogFile}"
    if ! run_as_root modprobe men_ll_m33
    then
        debug_print "${LogPrefix} ERR_VALUE: could not modprobe men_ll_m33" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    debug_print "${LogPrefix} Step2: run m33_demo m33_${ModuleNo}" "${LogFile}"
    if ! run_as_root m33_demo m33_"${ModuleNo}" > m33_demo.log
    then
        debug_print "${LogPrefix} Could not run m33_demo " "${LogFile}"
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^Device m33_${ModuleNo}" m33_demo.log > /dev/null && \
    grep "^channel 0: produce ramps" m33_demo.log > /dev/null && \
    grep "^ lowest..highest ramp" m33_demo.log > /dev/null && \
    grep "^ highest..lowest ramp" m33_demo.log > /dev/null && \
    grep "^channel 0: toggle lowest/highest" m33_demo.log > /dev/null && \
    grep "^Device m33_1 closed" m33_demo.log > /dev/null
    if [ $? -ne 0 ]; then
            debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
            return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
