#!/usr/bin/env bash

MyDir="$(dirname "${0}")"
source "${MyDir}/St_Functions.sh"

# This script performs tests with SMB2 driver
# Test is described in details in 13MD05-90_xx_xx-JPE
CurrDir="$(pwd)"
cd "${MainTestDirectoryPath}/${MainTestDirectoryName}" || exit "${ERR_DIR_NOT_EXISTS}"

ScriptName=${0##*/}
TestCaseName="${ScriptName%.*}_Test_Case"
TestCaseLogName="${ScriptName%.*}_log.txt"

# Move to correct Test_Summary directory
cd "${1}" || exit "${ERR_DIR_NOT_EXISTS}"

###############################################################################
###############################################################################
######################## Start of Test Case ###################################
###############################################################################
###############################################################################

# 0 means success
TestCaseStep1=${ERR_UNDEFINED}
TestCaseStep2=${ERR_UNDEFINED}
TestCaseStep3=${ERR_UNDEFINED}

CmdResult=${ERR_UNDEFINED}

DevName=$2 # smb device name (e.g. smb2_1)
BoardName=$3 # board name (e.g. G025A03)

# State machine runs all steps described in Test Case
# Step1
# .....
# Step3
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
        case ${MachineState} in
        Step1)
                echo "Run step @1" | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' modprobe men_mdis_kernel
                if [ $? -ne 0 ]; then
                        echo "${LogPrefix}  ERR_MODPROBE: could not modprobe men_mdis_kernel" | tee -a ${LogFileName}
                        TestCaseStep1=${ERR_MODPROBE}
                        MachineState="Break"
                else
                        TestCaseStep1=${ERR_OK}
                        MachineState="Step2"
                fi
                ;;
        Step2)
                echo "Run step @2" | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' modprobe i2c_i801
                if [ $? -ne 0 ]; then
                        echo "${LogPrefix}  ERR_MODPROBE: could not modprobe i2c_i801" | tee -a ${LogFileName}
                        TestCaseStep2=${ERR_MODPROBE}
                        MachineState="Break"
                else
                        TestCaseStep2=${ERR_OK}
                        MachineState="Step3"
                fi
                ;;
        Step3)
                echo "Run step @3" | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' smb2_boardident "${DevName}" > "smb2_boardident.log"
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' grep "HW-Name[[:space:]]\+=[[:space:]]\+${BoardName}" "smb2_boardident.log"
                CmdResult=$?
                if [ ${CmdResult} -ne 0 ]; then
                        echo "${LogPrefix}  ERR_VALUE: \"${BoardName}\" not found with smb2_boardident" | tee -a ${LogFileName}
                        TestCaseStep3=${ERR_VALUE}
                        MachineState="Break"
                else
                        TestCaseStep3=${ERR_OK}
                        MachineState="Break"
                fi
                ;;
        Break) # Clean after Test Case
                echo "Break State"  | tee --append "${TestCaseLogName}"
                run_test_case_common_end_actions "${TestCaseLogName}" "${TestCaseName}"
                MachineRun=false
                ;;
        *)
                echo "State is not set, start with Step1" | tee --append "${TestCaseLogName}"
                MachineState="Step1"
                ;;
        esac
done

ResultsSummaryTmp="${ResultsFileLogName}.tmp"
echo "${TestCaseName}" | tee --append "${TestCaseLogName}" "${ResultsSummaryTmp}"
echo "@1 - ${TestCaseStep1}" | tee --append "${TestCaseLogName}" "${ResultsSummaryTmp}"
echo "@2 - ${TestCaseStep2}" | tee --append "${TestCaseLogName}" "${ResultsSummaryTmp}"
echo "@3 - ${TestCaseStep3}" | tee --append "${TestCaseLogName}" "${ResultsSummaryTmp}"

# move to previous directory
cd "${CurrDir}" || exit "${ERR_DIR_NOT_EXISTS}"

exit "${CmdResult}"
