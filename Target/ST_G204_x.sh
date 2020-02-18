#! /bin/bash
MyDir="$(dirname "$0")"
source "${MyDir}"/St_Functions.sh
CurrDir=$(pwd)

############################################################################
# parameters $1 test case main directory
#            $2 M65 m-module number
#
TestCaseMainDir="${1}"
TestCaseId="${2}"
LogPrefix="[${2}]"
TestOs="${3}"
ModuleName="${4}"
ModuleNr="${5}"

TestDescription="${ModuleName}_description"
TestFunc="${ModuleName}_test"

if [ -z "${TestCaseMainDir}" ] || [ -z "${TestCaseId}" ] || [ -z "${LogPrefix}" ]
then
    echo "Lack of params - exit"
    exit "${ERR_NOEXIST}"
fi

FunctionExists=$(type -t "${TestDescription}")
if [ "${FunctionExists}" != "function" ] 
then
    echo "${LogPrefix} Function ${TestDescription} does not exists - exit"
    exit "${ERR_NOEXIST}"
fi

FunctionExists=$(type -t "${TestFunc}")
if [ "${FunctionExists}" != "function" ] 
then
    echo "${LogPrefix} Function ${TestDescription} does not exists - exit"
    exit "${ERR_NOEXIST}"
fi

cd "${MainTestDirectoryPath}/${MainTestDirectoryName}" || exit "${ERR_NOEXIST}"
ScriptName=${0##*/}
TestCaseName="${ScriptName%.*}_Test_Case"
TestCaseLogName="${ScriptName%.*}_log.txt"
ResultsSummaryTmp="${TestCaseId}.tmp"

# Move to correct Test_Summary directory
cd "${TestCaseMainDir}" || exit "${ERR_NOEXIST}"

###############################################################################
###############################################################################
######################## Start of Test Case ###################################
###############################################################################
###############################################################################
TestCaseResult=${ERR_UNDEFINED}
CmdResult=${ERR_UNDEFINED}

if ! run_test_case_dir_create "${TestCaseLogName}" "${TestCaseName}"
then
    echo "${LogPrefix} run_test_case_dir_create: Failed, exit Test Case ${TestCaseId}"
    exit "${CmdResult}"
else
    echo "${LogPrefix} run_test_case_dir_create: Success"
fi

echo "${LogPrefix} Test Case started..." | tee -a "${TestCaseLogName}" 2>&1
echo "${LogPrefix} Run function:" | tee -a "${TestCaseLogName}" 2>&1
echo "${LogPrefix} ${TestFunc} ${TestCaseLogName} ${LogPrefix} ${TestCaseName} ${ModuleNr}"  | tee -a "${TestCaseLogName}" 2>&1
"${TestFunc}" "${TestCaseLogName}" "${LogPrefix}" "${TestCaseName}" "${ModuleNr}"
CmdResult=$?
if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
    TestCaseResult="${CmdResult}"
else
    TestCaseResult=0
fi

echo "${LogPrefix} run test case end actions" | tee -a "${TestCaseLogName}" 2>&1
run_test_case_common_end_actions "${TestCaseLogName}" "${TestCaseName}"

if [ "${TestCaseResult}" -eq "${ERR_OK}" ]; then
    TestCaseResult="SUCCESS"
else
    TestCaseResult="FAIL"
fi

"${TestDescription}" >> "${ResultsSummaryTmp}"
echo "${LogPrefix} Test_Result:${TestCaseResult}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${LogPrefix} Test_ID: ${TestCaseId}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${LogPrefix} Test_Setup: ${TestSetup}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${LogPrefix} Test_Os: ${TestOs}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1

# move to previous directory
cd "${CurrDir}" || exit "${ERR_NOEXIST}"

exit "${CmdResult}"
