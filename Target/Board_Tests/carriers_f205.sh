#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# board F205 template description function
#
# parameters:
# $1    Module name
# $2    Module number
# $3    Module log path
function carrier_f205_TPL_description {
    local ModuleName=${1}
    local ModuleNo=${2}
    local ModuleLogPath=${3}
    echo "--------F205 ${ModuleName}_${ModuleNo} Test Case---"
    echo "PREREQUISITES:"
    echo "    M-module ${ModuleName}_${ModuleNo} is plugged into F205"
    echo "DESCRIPTION:"
    echo "    F205 ${ModuleName}_${ModuleNo} Interface Test"
    echo "PURPOSE:"
    echo "    Check if M-modules on F205 is working correctly"
    echo "REQUIREMENT_ID:"
    echo "    MEN_13MD05-90_SA_1720"
    echo "RESULTS"
    echo "    SUCCESS if m-modules tests are passed."
    echo "    FAIL otherwise"
}

############################################################################
# board F205 template test function
#
# parameters:
# $1    Module
# $2    ModuleNo
# $3    Test case id
# $4    Test summary directory
# $5    Os name kernel
function carrier_f205_TPL_test {
    local Module="${1}"
    local ModuleNo="${2}"
    local TestCaseId="${3}"
    local TestSummaryDirectory="${4}"
    local OsNameKernel="${5}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "${Module}"\
                                     -dno "${ModuleNo}"
    return $?
}
