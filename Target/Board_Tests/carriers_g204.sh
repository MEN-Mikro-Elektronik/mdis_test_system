#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# board g204 with m-module description template
#
# parameters:
# $1    Module name
# $2    Module log path
function carrier_g204_TMP_description {
    local ModuleName=${1}
    local ModuleLogPath=${2}
    echo "---------G204 ${ModuleName} Test Case-------------------"
    echo "PREREQUISITES:"
    echo "    M-module ${ModuleName} is plugged into G204"
    echo "DESCRIPTION:"
    echo "    Run ${ModuleName} m-module test(s)"
    echo "RESULTS"
    echo "    SUCCESS if all m-modules(s) tests are passed."
    echo "    FAIL otherwise"
}

############################################################################
# board g204_m65n test description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_g204_m65n_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_g204_TMP_description "m65n_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board g204_m65n test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_g204_m65n_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m65n"\
                                     -dno "1"
    return $?
}

############################################################################
# board g204_m33 test description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_g204_m33_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_g204_TMP_description "m33_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board g204_m33 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_g204_m33_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m33"\
                                     -dno "1"
    return $?
}

############################################################################
# board g204_m35n test description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_g204_m35n_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_g204_TMP_description "m35n_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board g204_m35n test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_g204_m35n_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m35n"\
                                     -dno "1"
    return $?
}
