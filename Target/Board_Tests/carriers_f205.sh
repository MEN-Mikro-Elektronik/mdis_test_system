#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# board F205 template description function
#
# parameters:
# $1    Module name
# $2    Module No
# $3    Print dependent m-module test description flag
function carrier_f205_TPL_description {
    local Module="${1}"
    local ModuleNo="${2}"
    local LongDescription="${3}"

    echo "--------------------------------F205 ${ModuleName}_${ModuleNo} Test Case---------------"
    echo "PREREQUISITES:"
    echo "    M-module ${ModuleName}_${ModuleNo} is plugged into F205"
    echo "DESCRIPTION:"
    echo "    M-module ${Module}_${ModuleNo} test on F205 carrier"
    echo "PURPOSE:"
    echo "    Check if M-module on F205 is working correctly"
    echo "REQUIREMENT_ID:"
    print_env_requirements
    echo "    MEN_13MD05-90_SA_1720"
    print_requirements "${Module}_description"
    echo "RESULTS"
    echo "    SUCCESS if m-modules tests are passed."
    echo "    FAIL otherwise"
    echo ""

    if [ ! -z "${LongDescription}" ]
    then
        "${Module}_description"
    fi
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
