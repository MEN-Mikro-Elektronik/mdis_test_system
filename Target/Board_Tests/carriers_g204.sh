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
    echo "   G204 ${ModuleName} test(s)"
    echo "PURPOSE:"
    echo "    Check if M-module on G204 is working correctly"
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
    local ModuleNo="1"
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
    local ModuleNo="1"
    local ModuleLogPath
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
    local ModuleNo="1"
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

############################################################################
# board g204_m36 test description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_g204_m36n_description {
    local ModuleNo="1"
    local ModuleLogPath=${2}
    carrier_g204_TMP_description "m36_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board g204_m36n test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_g204_m36n_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m36"\
                                     -dno "1"
    return $?
}

############################################################################
# board g204_m72 test description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_g204_m72_description {
    local ModuleNo="1"
    local ModuleLogPath=${2}
    carrier_g204_TMP_description "m72_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board g204_m72 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_g204_m72_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m72"\
                                     -dno "1"
    return $?
}

############################################################################
# board g204_m77 test description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_g204_m77n_description {
    local ModuleNo="1"
    local ModuleLogPath=${2}
    carrier_g204_TMP_description "m77_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board g204_m77 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_g204_m77n_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m77"\
                                     -dno "1"
    return $?
}

############################################################################
# board g204_m81 test description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_g204_m81_description {
    local ModuleNo="1"
    local ModuleLogPath=${2}
    carrier_g204_TMP_description "m81_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board g204_m81 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_g204_m81_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m81"\
                                     -dno "1"
    return $?
}

############################################################################
# board g204_m82 test description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_g204_m82_description {
    local ModuleNo="1"
    local ModuleLogPath=${2}
    carrier_g204_TMP_description "m82_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board g204_m82 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_g204_m82_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m82"\
                                     -dno "1"
    return $?
}
