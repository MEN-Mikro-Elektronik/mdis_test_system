#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m199 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m199_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------M199 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Load module driver and run M-Module example programs"
    echo "    1.Load m-module drivers: modprobe men_ll_m199"
    echo "    2.Run example/verification program:"
    echo "      m199_simp m199_${moduleNo} and save the command output"
    echo "    3.Verify if m199_simp command output is valid - does not contain errors"
    echo "PURPOSE:"
    echo "    Check if M-module m199 is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1870"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1960"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m199 test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m199_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_m199" "${LogFile}"
    if ! run_as_root modprobe men_ll_m199
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m199" "${LogFile}" 
        return "${ERR_VALUE}"
    fi

    # Run m199_simp
    debug_print "${LogPrefix} Step2: run m199_simp m199_${ModuleNo}" "${LogFile}"
    if ! run_as_root m199_simp m199_"${ModuleNo}" > m199_simp.log
    then
        debug_print "${LogPrefix} Could not run m199_simp " "${LogFile}"
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^LEDs are switched" m199_simp.log > /dev/null && \
    grep "^  D1  D2  D3  D4  D5  D6  D7" m199_simp.log > /dev/null && \
    grep "^ OFF OFF OFF OFF OFF OFF OFF" m199_simp.log > /dev/null && \
    grep "^  ON OFF  ON OFF OFF  ON OFF" m199_simp.log > /dev/null
    if [ $? -ne 0 ]; then 
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi 

    return "${ERR_OK}"
}
