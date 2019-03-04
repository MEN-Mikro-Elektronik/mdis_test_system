#! /bin/bash
MyDir="$(dirname "$0")"
source $MyDir/St_Functions.sh

# This script performs tests on F223 board.
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
TestCaseStep1=${ERR_UNDEFINED}
TestCaseStep2=${ERR_UNDEFINED}
TestCaseStep3=${ERR_UNDEFINED}
TestCaseStep4=${ERR_UNDEFINED}
TestCaseStep5=${ERR_UNDEFINED}
TestCaseStep6=${ERR_UNDEFINED}
TestCaseStep7=${ERR_UNDEFINED}
TestCaseStep8=${ERR_UNDEFINED}

CmdResult=${ERR_UNDEFINED}

# State machine runs all steps described in Test Case
# Step1 
# .....
# Step8
# Additional Break state is added to handle/finish TestCase properly
MachineState="Step1" 
MachineRun=true 

while ${MachineRun}; do
        case $(echo "${MachineState}") in
                
          Step1)
                echo "Run steps @1, @2, @3"
                echo "Test case ${ScriptName} started" 
                ;&
          Step2);&
          Step3) 
                run_test_case_common_actions ${TestCaseLogName} ${TestCaseName}
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        echo "run_test_case_common_actions: Failed, force exit Test Case" | tee -a ${TestCaseLogName} 2>&1
                        MachineState="Break"
                else
                        echo "Run steps @1, @2, @3" > ${TestCaseLogName} 2>&1
                        echo "Test case ${ScriptName} started" > ${TestCaseLogName} 2>&1
                        TestCaseStep1=0;
                        TestCaseStep2=0;
                        TestCaseStep3=0;
                        MachineState="Step4"
                fi
                ;;
          Step4) 
                echo "Run step @4" | tee -a ${TestCaseLogName} 2>&1
                ;;
          Step5) 
                echo "Run step @5" | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt= pi7c9_gpio_simp -g pi7c9_gpio_1 > pi7c9_gpio_simp_output.txt 2>&1
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        echo "ERR pi7c9_gpio_simp -s=1 -p=0x01 pi7c9_gpio_1" | tee -a ${TestCaseLogName} 2>&1
                        MachineState="Break"
                        TestCaseStep5=${ERR_SIMP_ERROR}
                else
                        TestCaseStep5=0
                        BinaryStateBegin="$(cat ./pi7c9_gpio_simp_output.txt\
                          | awk NR==2'{print $2 $3 $4 $5 $6 $7 $8 $9}')"
                        MachineState="Step6"
                fi
                ;;
          Step6) 
                echo "Run step @6" | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt= pi7c9_gpio_simp -s=1 -p=0x01 pi7c9_gpio_1
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        echo "ERR pi7c9_gpio_simp -s=1 -p=0x01 pi7c9_gpio_1" | tee -a ${TestCaseLogName} 2>&1
                        TestCaseStep5=${ERR_SIMP_ERROR}
                        MachineState="Break"
                else
                        TestCaseStep6=0
                        MachineState="Step7"
                fi 
                echo "PORT 0 should be 1: $(awk NR==2'{print $9}')" | tee -a ${TestCaseLogName} 2>&1
                ;;
          Step7)
                echo "Run step @7" | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt= pi7c9_gpio_simp -s=0 -p=0x01 pi7c9_gpio_1
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        echo "ERR pi7c9_gpio_simp -s=0 -p=0x01 pi7c9_gpio_1" | tee -a ${TestCaseLogName} 2>&1
                        MachineState="Break"
                else
                        TestCaseStep7=0
                        MachineState="Step8"
                fi
                echo "PORT 0 should be 0: $(awk NR==2'{print $9}')" | tee -a ${TestCaseLogName} 2>&1
                ;;
          Step8)
                echo "Run step @8" | tee -a ${TestCaseLogName} 2>&1
                echo "Go to beginning state of F223"            | tee -a ${TestCaseLogName} 2>&1
                echo "Beginning state: ${BinaryStateBegin}"       | tee -a ${TestCaseLogName} 2>&1
                echo "Disable all port first"                   | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt= pi7c9_gpio_simp -s=0 -p=0xFF pi7c9_gpio_1
                echo "Set previous value"                       | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt= pi7c9_gpio_simp -s=1 -p=0x$((2#${BinaryStateBegin})) pi7c9_gpio_1

                echo ${MenPcPassword} | sudo -S --prompt= pi7c9_gpio_simp -g pi7c9_gpio_1 > pi7c9_gpio_simp_output_end.txt 2>&1
                # Check if value at the end of the Test Case is equal to the value from 
                # the beginning
                BinaryStateEnd="$(cat ./pi7c9_gpio_simp_output_end.txt\
                                | awk NR==2'{print $2 $3 $4 $5 $6 $7 $8 $9}')"
                echo "End state: ${BinaryStateBegin}"             | tee -a ${TestCaseLogName} 2>&1

                if [ $((${BinaryStateBegin})) -ne $((${BinaryStateEnd})) ]; then
                        echo "ERR ${ERR_VALUE} :could not set up previous state" | tee -a ${TestCaseLogName} 2>&1
                else
                        TestCaseStep8=0
                        MachineState="Break"
                fi
                ;;
          Break) # Clean after Test Case
                echo "Run Break" | tee -a ${TestCaseLogName} 2>&1
                run_test_case_common_end_actions ${TestCaseLogName} ${TestCaseName}                
                MachineRun=false
                ;;
        *)
          echo "State is not set, start with Step1"
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
echo "@7 - ${TestCaseStep7}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1
echo "@8 - ${TestCaseStep8}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1

# move to previous directory
cd "${CurrDir}"

exit ${CmdResult}


