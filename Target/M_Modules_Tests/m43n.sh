#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m66 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m43n_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "------------------------------M43n Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "    For this test relay is required"
    echo "DESCRIPTION:"
    echo "    Load module driver and run M-Module example programs"
    echo "    1.Load m-module drivers: modprobe men_ll_m43"
    echo "    2.Run example/verification program:"
    echo "      m43_ex1 m43_${ModuleNo} and save the command output"
    echo "    3.Verify if m43_ex1 command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m43 is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1530"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1860"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run 43 test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
# $3    Test Case name
function m43n_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}

    debug_print "${LogPrefix} Step1: modprobe men_ll_m43" "${LogFile}"
    if ! run_as_root modprobe men_ll_m43
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m43" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    debug_print "${LogPrefix} Step2: run m43_ex1 m43_${ModuleNo}" "${LogFile}"
    if ! run_as_root m43_ex1 m43_"${ModuleNo}" > m43_ex1_output.txt
    then
      debug_print "${LogPrefix} Could not run m43_ex1 " "${LogFile}"
    fi

    local DeviceOpened
    local DeviceClosed
    local EndLine
    DeviceOpened=$(grep -ic "Device m43_${ModuleNo} opened" m43_ex1_output.txt)
    DeviceClosed=$(grep -ic "Device m43_${ModuleNo} closed" m43_ex1_output.txt)
    EndLine=$(tail -1 m43_ex1_output.txt)
    debug_print "${LogPrefix} DeviceOpened: ${DeviceOpened}, DeviceClosed: ${DeviceClosed}, EndLine: ${EndLine}" "${LogFile}"
    if [ "${DeviceOpened}" -eq 1 ] && [ "${DeviceClosed}" -eq 1 ] && [ "${EndLine}" == "=> OK" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}
