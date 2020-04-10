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
    echo "    M-module(s) ${ModuleName0}, ${ModuleName1} is(are) plugged into F205"
    echo "DESCRIPTION:"
    echo "    F205 ${ModuleName0}, ${ModuleName1} Interface Test"
    echo "PURPOSE:"
    echo "    Check if M-modules(s) on F205 is(are) working correctly"
    echo "RESULTS"
    echo "    SUCCESS if all m-modules(s) tests are passed."
    echo "    FAIL otherwise"
}

############################################################################
# board f205_m47_m33 description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_f205_m47_m33_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_f205_TMP_description "m47_${ModuleNo}" "${ModuleLogPath}" "m33_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board f205_m47_m33 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_f205_m47_m33_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m47"\
                                     -dno "1"
    local MResult0=$?

    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m33"\
                                     -dno "1"
    local MResult1=$?

    if [ "${MResult0}" = "${ERR_OK}" ] && [ "${MResult1}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

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

############################################################################
# board f205_m32_m58 description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_f205_m32_m58_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_f205_TMP_description "m32_${ModuleNo}" "${ModuleLogPath}" "m58_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board f205_m32_m58 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_f205_m32_m58_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m32"\
                                     -dno "1"
    MResult0=$?

    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m58"\
                                     -dno "1"
    MResult1=$?

    if [ "${MResult0}" = "${ERR_OK}" ] && [ "${MResult1}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

    return $?
}

############################################################################
# board f205_m37_m62 description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_f205_m37_m62_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_f205_TMP_description "m37_${ModuleNo}" "${ModuleLogPath}" "m62_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board f205_m37_m62 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_f205_m37_m62_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m37"\
                                     -dno "1"
    MResult0=$?

    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m62"\
                                     -dno "1"
    MResult1=$?

    if [ "${MResult0}" = "${ERR_OK}" ] && [ "${MResult1}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

############################################################################
# board f205_m66_m31 description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_f205_m66_m31_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_f205_TMP_description "m66_${ModuleNo}" "${ModuleLogPath}" "m31_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board f205_m66_m31 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_f205_m66_m31_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m66"\
                                     -dno "1"
    MResult0=$?

    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m31"\
                                     -dno "1"
    MResult1=$?

    if [ "${MResult0}" = "${ERR_OK}" ] && [ "${MResult1}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

############################################################################
# board f205_m43_m11 description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_f205_m43_m11_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_f205_TMP_description "m43_${ModuleNo}" "${ModuleLogPath}" "m11_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board f205_m43_m11 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_f205_m43_m11_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m43"\
                                     -dno "1"
    MResult0=$?

    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m11"\
                                     -dno "1"
    MResult1=$?

    if [ "${MResult0}" = "${ERR_OK}" ] && [ "${MResult1}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

############################################################################
# board f205_m36_m72 description
#
# parameters:
# $1    Module number
# $2    Module log path
function carrier_f205_m36_m72_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    carrier_f205_TMP_description "m36_${ModuleNo}" "${ModuleLogPath}" "m72_${ModuleNo}" "${ModuleLogPath}"
}

############################################################################
# run board f205_m36_m72 test
#
# parameters:
# $1    Test case id
# $2    Test summary directory
# $3    Os name kernel
function carrier_f205_m36_m72_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    local TestCaseResult="${ERR_VALUE}"
    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m36"\
                                     -dno "1"
    MResult0=$?

    run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                     -id "${TestCaseId}"\
                                     -os "${OsNameKernel}"\
                                     -dname "m72"\
                                     -dno "1"
    MResult1=$?

    if [ "${MResult0}" = "${ERR_OK}" ] && [ "${MResult1}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}
