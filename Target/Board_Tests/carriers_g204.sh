#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# board g204 with m-module description template function
#
# parameters:
# $1    Module name
# $2    Module No
# $3    Print dependent m-module test description flag
function carrier_g204_TPL_description {
    local Module="${1}"
    local ModuleNo="${2}"
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"

    echo "--------------------------------G204 ${Module}_${ModuleNo} Test Case-------------------"
    echo "PREREQUISITES:"
    echo "    M-module ${Module}_${ModuleNo} is plugged into G204"
    echo "DESCRIPTION:"
    echo "    M-module ${Module}_${ModuleNo} test on G204 carrier"
    echo "PURPOSE:"
    echo "    Check if M-module on G204 is working correctly"
    echo "REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    echo "    MEN_13MD05-90_SA_1730"
    print_requirements "${Module}_description"
    echo "RESULTS"
    echo "    SUCCESS if all m-modules(s) tests are passed."
    echo "    FAIL otherwise"
    echo ""

    if [ ! -z "${LongDescription}" ]
    then
        "${Module}_description"
    fi
}

############################################################################
# board g204 with M-Module template test function
#
# parameters:
# $1    Module
# $2    ModuleNo
# $3    Test case id
# $4    Test summary directory
# $5    Os name kernel
function carrier_g204_TPL_test {
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
