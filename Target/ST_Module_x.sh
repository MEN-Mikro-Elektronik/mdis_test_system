#! /bin/bash
MyDir="$(dirname "$0")"
source "${MyDir}"/St_Functions.sh
source "${MyDir}"/M_Module_Tests.sh
CurrDir=$(pwd)

############################################################################
# This script might be used to run simple m-module test,
# User has to define m_module description and test function. 
# example: m65n_description (), m65n_test (), and pass parameter "m65n" with 
# m-module number into this script
# 
# parameters $1 test case main directory
#            $2 unique test case ID
#            $3 OS name
#            $4 Module name
#            $5 Module num
#
TestCaseMainDir="${1}"
TestCaseId="${2}"
LogPrefix="[${2}]"
TestOs="${3}"
ModuleName="${4}"
ModuleNr="${5}"

TestDescription="${ModuleName}_description"
TestFunc="${ModuleName}_test"

if [ -z "${TestCaseMainDir}" ] || [ -z "${TestCaseId}" ] || [ -z "${LogPrefix}" ] || [ -z "${TestOs}" ] || [ -z "${ModuleName}" ] || [ -z "${ModuleNr}" ] 
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
TestCaseName="${ScriptName%.*}_${TestCaseId}_Test_Case"
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

echo "${LogPrefix} Run function:" | tee -a "${TestCaseLogName}" 2>&1
echo "${LogPrefix} \"${TestFunc} ${TestCaseLogName} ${LogPrefix} ${ModuleNr}\""  | tee -a "${TestCaseLogName}" 2>&1
"${TestFunc}" "${TestCaseLogName}" "${LogPrefix}" "${ModuleNr}"
CmdResult=$?
if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
    TestCaseResult="${CmdResult}"
else
    TestCaseResult=0
fi

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
