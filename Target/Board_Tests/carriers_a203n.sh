#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# board A203N template description function
#
# parameters:
# $1    Module name
# $2    Module No
# $3    Print dependent m-module test description flag
function carrier_a203n_TPL_description {
    local Module="${1}"
    local ModuleNo="${2}"
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "--------------------------------A203N ${ModuleName}_${ModuleNo} Test Case---------------"
    echo "PREREQUISITES:"
    echo "    M-module ${ModuleName}_${ModuleNo} is plugged into A203N"
    echo "DESCRIPTION:"
    echo "    M-module ${Module}_${ModuleNo} test on A203N carrier"
    echo "PURPOSE:"
    echo "    Check if M-module on A203N is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    arch_requirement "pci"
    echo "    MEN_13MD0590_SWR_0930"
    print_requirements "${Module}_description"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1720"
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
function carrier_a203n_TPL_test {
    local Module="${1}"
    local ModuleNo="${2}"
    local TestCaseId="${3}"
    local TestSummaryDirectory="${4}"
    local OsNameKernel="${5}"

    local TestCaseResult="${ERR_VALUE}"
    "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "${Module}"\
                                     -dno "${ModuleNo}"
    return $?
}
