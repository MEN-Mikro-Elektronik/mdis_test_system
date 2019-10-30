#! /bin/bash
MyDir="$(dirname "$0")"
source $MyDir/St_Functions.sh

# This script performs tests on F215 with 2xSA01, 2xSA08, 2xSA15
# Test is described in details in 13MD05-90_xx_xx-JPE
CurrDir="$pwd"
cd "${MainTestDirectoryPath}/${MainTestDirectoryName}"

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
TestCaseStep2=0 # Cable test
TestCaseStep3=0 # Cable test
TestCaseStep4=${ERR_UNDEFINED}
TestCaseStep5=${ERR_UNDEFINED}

CmdResult=${ERR_UNDEFINED}

# Board in this Test Case always have
VenID="0x1a88"   
DevID="0x4d45"
SubVenID="0x006a"
BoardInSystem="1" # Depends on the test case
InputToChange=${IN_0_ENABLE}

# State machine runs all steps described in Test Case
# Step1 
# .....
# Step5
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
        Step2);&
        Step3)
                # Check if mcb_pci is already in blacklist, UART loopback test
                echo "Run step @3" | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt= grep "blacklist mcb_pci" /etc/modprobe.d/blacklist.conf > /dev/null
                if [ $? -ne 0 ]; then
                        # Add mcb_pci into blacklist
                        echo ${MenPcPassword} | sudo -S --prompt= echo "# Add mcb_pci into blacklist" >> /etc/modprobe.d/blacklist.conf
                        echo ${MenPcPassword} | sudo -S --prompt= echo "blacklist mcb_pci" >> /etc/modprobe.d/blacklist.conf
                else
                        echo "blacklist mcb_pci found"
                fi
                uart_loopback_test ${TestCaseLogName} ${VenID} ${DevID} ${SubVenID} ${BoardInSystem}
                CmdResult=$?
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                         echo "uart_test_board err: ${CmdResult} "\
                           | tee -a ${TestCaseLogName} 2>&1
                else
                         echo "uart_test_board success "\
                           | tee -a ${TestCaseLogName} 2>&1
                fi
                TestCaseStep3=${CmdResult}
                MachineState="Step4"
                ;;
        Step4)
                # Can test
                echo "Run step @4" | tee -a ${TestCaseLogName} 2>&1
                # Run step @8 Test CAN interfaces, there should be 2 cans available
                MezzChamDevName="MezzChamDevName.txt"
                obtain_device_list_chameleon_device ${VenID} ${DevID} ${SubVenID} ${MezzChamDevName}

                can_test_ll_z15 ${TestCaseLogName} ${MezzChamDevName}
                CmdResult=$?
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                         echo "can_test_ll_z15 err: ${CmdResult} "\
                           | tee -a ${TestCaseLogName} 2>&1
                else
                         echo "can_test_ll_z15 success "\
                           | tee -a ${TestCaseLogName} 2>&1
                fi
                TestCaseStep4=${CmdResult}
                MachineState="Step5"
                ;;
        Step5)
                # Test GPIO / LEDS 
                echo "Run step @5" | tee -a ${TestCaseLogName} 2>&1
                echo ${MenPcPassword} | sudo -S --prompt= modprobe men_ll_z17
                ResultModprobeZ17=$?
                if [ ${ResultModprobeZ17} -ne ${ERR_OK} ]; then
                        echo "ERR_MODPROBE :could not modprobe men_ll_z17" | tee -a ${TestCaseLogName} 2>&1
                        CmdResult=${ResultModprobeZ17}
                else
                        GpioNumber=$(grep "^gpio" ${MezzChamDevName} | wc -l)
                        if [ "${GpioNumber}" -ne "2" ]; then
                                echo "There are ${GpioNumber} GPIO interfaces" \
                                  | tee error_log.txt 2>&1
                        else
                                GPIO1=$(grep "^gpio" ${MezzChamDevName} | awk NR==1'{print $1}')
                                GPIO2=$(grep "^gpio" ${MezzChamDevName} | awk NR==2'{print $1}')
                        fi

                        # Test LEDS -- This cannot be checked automatically yet ... 
                        echo ${MenPcPassword} | sudo -S --prompt= z17_simp ${GPIO1} >> z17_simp_${GPIO1}.txt 2>&1
                        if [ $? -ne 0 ]; then
                                echo "ERR_RUN :could not run z17_simp ${GPIO1}" | tee -a ${TestCaseLogName} 2>&1     
                        fi

                        # Test GPIO
                        gpio_test ${TestCaseLogName} ${TestCaseName} ${GPIO2} ${InputToChange}
                        CmdResult=$?
                        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                                 echo "gpio_test on ${GPIO2} err: ${CmdResult} "\
                                   | tee -a ${TestCaseLogName} 2>&1
                        else
                                 echo "gpio_test on ${GPIO2} success "\
                                   | tee -a ${TestCaseLogName} 2>&1
                        fi
                fi
                TestCaseStep5=${CmdResult}
                MachineState="Break"
                ;;
        Break) 
                # Clean after Test Case
                echo "Break State"  | tee --a ${TestCaseLogName}
                run_test_case_common_end_actions ${TestCaseLogName} ${TestCaseName}
                MachineRun=false
                ;;
        *)
                echo "State is not set, start with Step1" | tee --append ${TestCaseLogName}
                MachineState="Step1"
                ;;
        esac
done

# Remove mcb_pci from blacklist
#echo ${MenPcPassword} | sudo -S --prompt= sed -i '/# Add mcb_pci into blacklist/d' /etc/modprobe.d/blacklist.conf
#echo ${MenPcPassword} | sudo -S --prompt= sed -i '/blacklist mcb_pci/d' /etc/modprobe.d/blacklist.conf

ResultsSummaryTmp="${ResultsFileLogName}.tmp"
echo "${TestCaseName}    " | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 
echo "@1 - ${TestCaseStep1}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 
echo "@2 - ${TestCaseStep2}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 
echo "@3 - ${TestCaseStep3}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 
echo "@4 - ${TestCaseStep4}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 
echo "@5 - ${TestCaseStep5}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 

# Clean after Test Case
run_test_case_common_end_actions ${TestCaseLogName} ${TestCaseName}

# move to previous directory
cd "$CurrDir"

exit ${CmdResult}
