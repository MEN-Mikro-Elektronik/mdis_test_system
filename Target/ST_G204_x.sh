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
TestSetup="${3}"
TestOs="${4}"
TestDescription="${5}"
TestFunc="${6}"
ModuleNr="${7}"

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

# All steps are performed by function m65n_test
MachineState="Step1"
MachineRun=true

if ! run_test_case_dir_create "${TestCaseLogName}" "${TestCaseName}"
then
    echo "${TestCaseLogPrefix} run_test_case_dir_create: Failed, exit Test Case ${TestCaseId}"
    exit "${CmdResult}"
else
    echo "run_test_case_dir_create: Success"
fi

while ${MachineRun}; do
    case "${MachineState}" in
        Step1);&
            echo "${LogPrefix} Test Case started..." | tee -a "${TestCaseLogName}" 2>&1
            "${TestFunc}" "${TestCaseLogName}" "${LogPrefix}" "${TestCaseName}" "${ModuleNr}"
            CmdResult=$?
            if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                TestCaseResult="${CmdResult}"
            else
                TestCaseResult=0
            fi
            MachineState="Break"
            ;;
        Break) # Clean after Test Case
            echo "${LogPrefix} Break State" | tee -a "${TestCaseLogName}" 2>&1
            run_test_case_common_end_actions "${TestCaseLogName}" "${TestCaseName}"
            MachineRun=false
            ;;
        *)
            echo "${LogPrefix} State is not set, start with Step1" | tee -a "${TestCaseLogName}" 2>&1
            MachineState="Step1"
            ;;
    esac
done

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
