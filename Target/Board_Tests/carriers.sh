#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# board g215 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function g204_m65n_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------G204 m65n Test Case---------------------------"
    echo "PREREQUISITES:"
    echo "    M-module m65n is plugged into G204"
    echo "DESCRIPTION:"
    echo "    Run m-module test(s)"
    echo "RESULTS"
    echo "    SUCCESS if all m-modules(s) tests are passed."
    echo "    FAIL otherwise"
}

############################################################################
# run board g215 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function g204_m65n_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local BoardInSystem=${3}

    #local TestCaseId="${1}"
    #local TestSummaryDirectory="${2}"
    #local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "m65n" -dno "1"
    return $?
}
