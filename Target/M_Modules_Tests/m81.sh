#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m81 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m81_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M81 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe driver"
    echo "    2."
    echo "PURPOSE:"
    echo "    Check if M-module m81 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m81 test 
# 
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m81_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    return "${ERR_VALUE}"

    #echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_m81
    #if [ $? -ne 0 ]; then
    #    echo "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m81" | tee -a "${TestCaseLogName}"
    #    return "${ERR_VALUE}"
    #fi
}
