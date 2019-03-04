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
TestCaseStep6=${ERR_UNDEFINED}
TestCaseStep7=${ERR_UNDEFINED}
TestCaseStep8=${ERR_UNDEFINED}
TestCaseStep9=${ERR_UNDEFINED}

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
# Step9
# Additional Break state is added to handle/finish TestCase properly
MachineState="Step1" 
MachineRun=true 

echo "Test case ${ScriptName} started"    

while ${MachineRun}; do
        case ${MachineState} in
        Step1);&
        Step2);&
        Step3);&
        Step4);&
        Step5);&
        Step6)  
                # Run step @4, @5, @6
                run_test_case_common_actions ${TestCaseLogName} ${TestCaseName}
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        echo "run_test_case_common_actions: Failed, force exit Test Case" | tee -a ${TestCaseLogName} 2>&1
                        MachineState="Break"
                else
                        echo "Run steps @4, @5, @6" > ${TestCaseLogName} 2>&1
                        echo "Test case ${ScriptName} started" > ${TestCaseLogName} 2>&1
                        TestCaseStep4=0;
                        TestCaseStep5=0;
                        TestCaseStep6=0;
                        MachineState="Step7"
                fi
                ;;
        Step7)
                # Check if mcv_pci is already in blacklist, UART loopback test
                echo "Run step @7" | tee -a ${TestCaseLogName} 2>&1
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
                TestCaseStep7=${CmdResult}
                MachineState="Step8"
                ;;
        Step8)
                # Can test
                echo "Run step @8" | tee -a ${TestCaseLogName} 2>&1
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
                TestCaseStep8=${CmdResult}
                MachineState="Step9"
                ;;
        Step9)
                # Test GPIO / LEDS 
                echo "Run step @9" | tee -a ${TestCaseLogName} 2>&1
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
                TestCaseStep9=${CmdResult}
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
echo "@6 - ${TestCaseStep6}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 
echo "@7 - ${TestCaseStep7}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 
echo "@8 - ${TestCaseStep8}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 
echo "@9 - ${TestCaseStep9}" | tee -a ${TestCaseLogName} ${ResultsSummaryTmp} 2>&1 

# Clean after Test Case
run_test_case_common_end_actions ${TestCaseLogName} ${TestCaseName}

# move to previous directory
cd "$CurrDir"

exit ${CmdResult}
