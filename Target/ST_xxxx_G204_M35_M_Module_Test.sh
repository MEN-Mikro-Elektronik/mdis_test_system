#! /bin/bash
MyDir="$(dirname "$0")"
source $MyDir/St_Functions.sh

# This script performs tests on G204 with M35 M-Module.
# Test is described in details in 13MD05-90_xx_xx-JPE
CurrDir="$pwd"
cd "$MainTestDirectoryPath/$MainTestDirectoryName"

ScriptName=${0##*/}
TestCaseName="${ScriptName%.*}_Test_Case"
TestCaseLogName="${ScriptName%.*}_log.txt"

# Move to correct Test_Summary directory
cd "$1"

###############################################################################
###############################################################################
######################## Start of Test Case ###################################
###############################################################################
###############################################################################

# 0 means success
TestCaseStep1=0 # Cable test
TestCaseStep2=${ERR_UNDEFINED}
TestCaseStep3=${ERR_UNDEFINED}
TestCaseStep4=${ERR_UNDEFINED}
TestCaseStep5=${ERR_UNDEFINED}
TestCaseStep6=${ERR_UNDEFINED}

CmdResult=${ERR_UNDEFINED}

# State machine runs all steps described in Test Case
# Step1 
# .....
# Step6
# Additional Break state is added to handle/finish TestCase properly
MachineState="Step1" 
MachineRun=true 

while ${MachineRun}; do
        case $(echo "${MachineState}") in
          Step1);&
          Step2);&
          Step3);&
          Step4)
                echo "Run steps @2, @3, @4"
                echo "Test case ${ScriptName} started"
                run_test_case_common_actions ${TestCaseLogName} ${TestCaseName}
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        echo "run_test_case_common_actions: Failed, force exit Test Case" | tee -a ${TestCaseLogName} 2>&1
                        MachineState="Break"
                else
                        echo "Run steps @2, @3, @4" > ${TestCaseLogName} 2>&1
                        echo "Test case ${ScriptName} started" > ${TestCaseLogName} 2>&1
                        TestCaseStep2=0;
                        TestCaseStep3=0;
                        TestCaseStep4=0;
                        MachineState="Step5"
                fi
                ;;
          Step5) 
                echo "Run step @5" | tee -a ${TestCaseLogName} 2>&1
                m_module_x_test ${TestCaseLogName} ${TestCaseName} ${IN_0_ENABLE} "m35" "1"
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        TestCaseStep5=${CmdResult}
                else
                        TestCaseStep5=0
                fi
                MachineState="Step6"
                ;;
          Step6) 
                echo "Run step @6" | tee -a ${TestCaseLogName} 2>&1
                m_module_x_test ${TestCaseLogName} ${TestCaseName} ${IN_0_ENABLE} "m35" "1" "blkread"
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        TestCaseStep6=${CmdResult}
                else
                        TestCaseStep6=0
                fi
                MachineState="Break"
                ;;
          Break) # Clean after Test Case
                echo "Break State"  | tee -a ${TestCaseLogName} 2>&1
                run_test_case_common_end_actions ${TestCaseLogName} ${TestCaseName}                
                MachineRun=false
                ;;
        *)
          echo "State is not set, start with Step1" | tee -a ${TestCaseLogName} 2>&1
          MachineState="Step1"
          ;;
        esac
done

ResultsSummaryTmp="${ResultsFileLogName}.tmp"
echo "${TestCaseName}    " | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 
echo "@1 - ${TestCaseStep1}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1
echo "@2 - ${TestCaseStep2}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1
echo "@3 - ${TestCaseStep3}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1
echo "@4 - ${TestCaseStep4}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1
echo "@5 - ${TestCaseStep5}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1
echo "@6 - ${TestCaseStep6}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1

# move to previous directory
cd "${CurrDir}"

exit ${CmdResult}

