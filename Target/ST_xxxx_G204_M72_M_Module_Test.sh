#! /bin/bash
MyDir="$(dirname "$0")"
source $MyDir/St_Functions.sh

# This script performs tests on G204 with M72 M-Module.
# Test is described in details in 13MD05-90_xx_xx-JPE
CurrDir="$pwd"
cd "$MainTestDirectoryPath/$MainTestDirectoryName"

ScriptName=${0##*/}
TestCaseName="${ScriptName%.*}_Test_Case"
TestCaseLogName="${ScriptName%.*}_log.txt"

# Move to correct Test_Summary directory
cd "$1"

DeviceInstance="1"
 
if [ -z "$2" ]; then
    echo "Use first device as default"
else
    DeviceInstance="${2}"
    echo "Use m72_${DeviceInstance} device"
fi

###############################################################################
###############################################################################
######################## Start of Test Case ###################################
###############################################################################
###############################################################################

# 0 means success
TestCaseStep1=0 # Cable test
TestCaseStep2=0 
TestCaseStep3=${ERR_UNDEFINED}

CmdResult=${ERR_UNDEFINED}

# State machine runs all steps described in Test Case
# Step1 
# .....
# Step3
# Additional Break state is added to handle/finish TestCase properly
MachineState="Step1" 
MachineRun=true 

run_test_case_dir_create "${TestCaseLogName}_${DeviceInstance}" "${TestCaseName}_${DeviceInstance}"
CmdResult=$?
if [ ${CmdResult} -ne ${ERR_OK} ]; then
        echo "run_test_case_dir_create: Failed, exit Test Case"
        exit ${CmdResult}
else
        echo "run_test_case_dir_create: Success"
fi

while ${MachineRun}; do
        case $(echo "${MachineState}") in
          Step1);&
          Step2);&
          Step3)
                echo "Run step @3" | tee -a ${TestCaseLogName} 2>&1
                m_module_m72_test ${TestCaseLogName} ${TestCaseName} "${DeviceInstance}"
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        TestCaseStep4=${CmdResult}
                else
                        TestCaseStep4=0
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

# move to previous directory
cd "${CurrDir}"

exit ${CmdResult}
