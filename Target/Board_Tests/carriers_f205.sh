#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# board f205 with m-module(s) description template
#
# parameters:
# $1    Module name 0
# $2    Module name 1
# $3    Module Log Path 0
# $4    Module Log Path 1
function carrier_f205_TMP_description {
    local ModuleName0=${1}
    local ModuleLogPath0=${2}
    local ModuleName1=${3}
    local ModuleLogPath1=${4}
    echo "--------F205 ${ModuleName0} ${ModuleName1} Test Case---"
    echo "PREREQUISITES:"
    echo "    M-module(s) ${ModuleName0}, ${ModuleName1} are(is) plugged into F205"
    echo "DESCRIPTION:"
    echo "    Run m-module(s) test"
    echo "RESULTS"
    echo "    SUCCESS if all m-modules(s) tests are passed."
    echo "    FAIL otherwise"
}

############################################################################
# board f205_m47 description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_f205_m47_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_f205_TMP_description "m47_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board f205_m47 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_f205_m47_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m47"\
                                     -dno "1"
    return $?
}

############################################################################
# board f205_m57 description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_f205_m57_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_f205_TMP_description "m57_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board f205_m57 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_f205_m57_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m57"\
                                     -dno "1"
    return $?
}



