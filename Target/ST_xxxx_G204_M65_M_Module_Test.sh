#! /bin/bash
MyDir="$(dirname "$0")"
source "${MyDir}"/St_Functions.sh
CurrDir=$(pwd)

############################################################################
# parameters $1 test case main directory
#            $2 M65 m-module number
#
TestCaseMainDir=${1}
M65NNr=${2}

# Test description:
m65n_test_description(){
    echo "-----------------------M65N Test Case-------------------------------"
    echo "Prerequisites:"
    echo " - It is assumed that at this point all necessary drivers have been"
    echo "   build and are available in the system"
    echo " - M65N adapter is plugged into M65N m-module"
    echo "Steps:"
    echo " 1. Load m-module drivers: modprobe men_ll_icanl2"
    echo " 2. Run example/verification program:"
    echo "    icanl2_veri m65_1a m65_1b -n=2 and save the command output"
    echo " 3. Verify if icanl2_veri command output is valid - does not contain"
    echo "    errors (find line 'TEST RESULT: 0 errors)"
    echo "Results:"
    echo " - SUCCESS / FAIL"
    echo " - in case of \"FAIL\", please check test case log file:"
    echo "   ${MainTestDirectoryPath}/${MainTestDirectoryName}/${TestCaseLogName}"
    echo "   For more detailed information please see corresponding log files"
    echo "   In test case repository"
    echo " - to see definition of all error codes please check Conf.sh"
}


cd "${MainTestDirectoryPath}/${MainTestDirectoryName}" || exit "${ERR_NOEXIST}"

ScriptName=${0##*/}
TestCaseName="${ScriptName%.*}_Test_Case"
TestCaseLogName="${ScriptName%.*}_log.txt"
TestCaseLogPrefix="[m65_test]"
ResultsSummaryTmp="${ResultsFileLogName}.tmp"
TestCaseId="3000" #How to generate?
TestSetup="get test setup nr.."
TestOs="unique OS number/ OS id"

# Move to correct Test_Summary directory
cd "${TestCaseMainDir}" || exit "${ERR_NOEXIST}"

###############################################################################
###############################################################################
######################## Start of Test Case ###################################
###############################################################################
###############################################################################
TestCaseResult=${ERR_UNDEFINED}
CmdResult=${ERR_UNDEFINED}

# All steps are performed by function m_module_m65_test
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
        Step2);&
        Step3)
            echo "${TestCaseLogPrefix} Test Case started..." | tee -a "${TestCaseLogName}" 2>&1
            echo "${TestCaseLogPrefix} Run step @1, @2, @3" | tee -a "${TestCaseLogName}" 2>&1
            m_module_m65_test "${TestCaseLogName}" "${TestCaseLogPrefix}" "${TestCaseName}" "${M65NNr}"
            CmdResult=$?
            if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                TestCaseResult="${CmdResult}"
            else
                TestCaseResult=0
            fi
            MachineState="Break"
            ;;
        Break) # Clean after Test Case
            echo "${TestCaseLogPrefix} Break State" | tee -a "${TestCaseLogName}" 2>&1
            run_test_case_common_end_actions "${TestCaseLogName}" "${TestCaseName}"
            MachineRun=false
            ;;
        *)
            echo "${TestCaseLogPrefix} State is not set, start with Step1" | tee -a "${TestCaseLogName}" 2>&1
            MachineState="Step1"
            ;;
    esac
done

if [ "${TestCaseResult}" -eq "${ERR_OK}" ]; then
    TestCaseResult="SUCCESS"
else
    TestCaseResult="FAIL"
fi

m65n_test_description >> "${ResultsSummaryTmp}"
echo "" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${TestCaseLogPrefix} Test_Result:${TestCaseResult}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${TestCaseLogPrefix} Test_ID: ${TestCaseId}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${TestCaseLogPrefix} Test_Setup: ${TestSetup}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${TestCaseLogPrefix} Test_Os: ${TestOs}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1

# move to previous directory
cd "${CurrDir}" || exit "${ERR_NOEXIST}"

exit "${CmdResult}"
