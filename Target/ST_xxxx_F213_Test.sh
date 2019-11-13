#! /bin/bash
MyDir="$(dirname "$0")"
source $MyDir/St_Functions.sh

# This script performs tests on F213 board.
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

CmdResult=${ERR_UNDEFINED}

# State machine runs all steps described in Test Case
# Step1
# .....
# Step4
# Additional Break state is added to handle/finish TestCase properly
MachineState="Step1"
MachineRun=true

run_test_case_dir_create ${TestCaseLogName} ${TestCaseName}
CmdResult=$?
if [ ${CmdResult} -ne ${ERR_OK} ]; then
        echo "run_test_case_dir_create: Failed, exit Test Case"
        exit ${CmdResult}
else
        echo "run_test_case_dir_create: Success"
fi

while ${MachineRun}; do
        case $(echo "${MachineState}") in
          Step1)
                echo "Run step @1" | tee -a ${TestCaseLogName} 2>&1

                echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cdetect -y -l > "i2c_bus_list_before.log" 2>&1

                TestCaseStep1=0
                MachineState="Step2"
                ;;
          Step2)
                echo "Run step @2" | tee -a ${TestCaseLogName} 2>&1

                echo ${MenPcPassword} | sudo -S --prompt=$'\r' modprobe men_lx_z001
                if [ $? -ne 0 ]; then
                        echo "ERR_MODPROBE: could not modprobe men_lx_z001" | tee -a ${TestCaseLogName} 2>&1a
                        MachineState="Break"
                        TestCaseStep2=${ERR_MODPROBE}
                else
                        TestCaseStep2=0
                        MachineState="Step3"
                fi
                ;;
          Step3)
                echo "Run step @3" | tee -a ${TestCaseLogName} 2>&1

                echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cdetect -y -l > "i2c_bus_list_after.log" 2>&1

                TestCaseStep3=0
                MachineState="Step4"
                ;;
          Step4)
                echo "Run step @4" | tee -a ${TestCaseLogName} 2>&1

                echo ${MenPcPassword} | sudo -S --prompt=$'\r' cat "i2c_bus_list_before.log" "i2c_bus_list_after.log" | sort | uniq --unique > "i2c_bus_list_test.log" 2>&1
                SMBUS_ID="$(echo ${MenPcPassword} | sudo -S --prompt=$'\r' grep --only-matching "16Z001-[0-1]\+ BAR[0-9]\+ offs 0x[0-9]\+" "i2c_bus_list_test.log")"
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cdump -y "${SMBUS_ID}" 0x57 | grep "P511"
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        echo "ERR_VALUE: i2cdump failed for ${SMBUS_ID}" | tee -a ${TestCaseLogName} 2>&1
                        MachineState="Break"
                        TestCaseStep4=${ERR_VALUE}
                else
                        TestCaseStep4=0
                        MachineState="Break"
                fi
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' rmmod men_lx_z001
                if [ $? -ne 0 ]; then
                        echo "ERR_RMMOD: could not rmmod men_lx_z001" | tee -a ${TestCaseLogName} 2>&1a
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

# move to previous directory
cd "${CurrDir}"

exit ${CmdResult}


