#!/usr/bin/env bash

MyDir="$(dirname "${0}")"
source "${MyDir}/St_Functions.sh"
source "${MyDir}"/Ip_Core_Tests/z001.sh

# This script performs tests on G229 side board
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
TestCaseStep1=0
TestCaseStep2=${ERR_UNDEFINED}
TestCaseStep3=${ERR_UNDEFINED}

CmdResult=${ERR_UNDEFINED}

# Board in this Test Case always have
VenID="0x1a88"
DevID="0x4d45"
SubVenID="0x00d1"

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
        Step1);&
        Step2)
                echo "Run step @2" | tee -a ${TestCaseLogName} 2>&1
                smb_test_lx_z001 "${TestCaseLogName}" "DBZIB" "0x51"
                CmdResult=$?
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                         echo "smb_test_lx_z001 err: ${CmdResult} "\
                           | tee -a ${TestCaseLogName} 2>&1
                else
                         echo "smb_test_lx_z001 success "\
                           | tee -a ${TestCaseLogName} 2>&1
                fi
                TestCaseStep2=${CmdResult}
                MachineState="Step3"
                ;;
        Step3)
                # Can test
                echo "Run step @3" | tee -a ${TestCaseLogName} 2>&1
                # Run step @4 Test CAN interface, there should be 1 CAN available
                MezzChamDevName="MezzChamDevName.txt"
                obtain_device_list_chameleon_device ${VenID} ${DevID} ${SubVenID} ${MezzChamDevName}

                can_test_ll_z15_loopback ${TestCaseLogName} ${MezzChamDevName}
                CmdResult=$?
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                         echo "can_test_ll_z15_loopback err: ${CmdResult} "\
                           | tee -a ${TestCaseLogName} 2>&1
                else
                         echo "can_test_ll_z15_loopback success "\
                           | tee -a ${TestCaseLogName} 2>&1
                fi
                TestCaseStep3=${CmdResult}
                MachineState="Break"
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
