#!/usr/bin/env bash

MyDir="$(dirname "${0}")"
source ${MyDir}/St_Functions.sh

# This script performs tests on F614 side board
# Test is described in details in 13MD05-90_xx_xx-JPE
CurrDir="${pwd}"
cd ${MainTestDirectoryPath}/${MainTestDirectoryName}/

ScriptName=${0##*/}
TestCaseName="${ScriptName%.*}_Test_Case"
TestCaseLogName="${ScriptName%.*}_log.txt"

###############################################################################
###############################################################################
######################## Functions of Test Case ###############################
###############################################################################
###############################################################################

eth_test() {
        local GwDefault=`ip route list | grep "^default" | head --lines=1`
        echo "Default gateway: ${GwDefault}" | tee --append ${TestCaseLogName}
        local GwCurrent=${GwDefault}
        local GwIp=`echo "${GwDefault}" | grep --perl-regexp --only-matching "via\s+[\d\.]+" | grep --perl-regexp --only-matching "[\d\.]+"`
        echo "Default gateway IP address: ${GwIp}" | tee --append ${TestCaseLogName}

        local EthListBefore=`ifconfig -a | grep --perl-regexp --only-matching "^[\w\d]+"`
        echo -e "ETH interfaces before driver was loaded:\n${EthListBefore}" | tee --append ${TestCaseLogName}

        echo ${MenPcPassword} | sudo --stdin --prompt="" modprobe men_lx_z77 phyadr=1,0
        if [ ${?} -ne 0 ]; then
                echo "ERR ${ERR_MODPROBE}:could not modprobe men_lx_z77" | tee --append ${TestCaseLogName}
                return ${ERR_MODPROBE}
        fi

        local EthListAfter=`ifconfig -a | grep --perl-regexp --only-matching "^[\w\d]+"`
        echo -e "ETH interfaces after driver was loaded:\n${EthListAfter}" | tee --append ${TestCaseLogName}

        local EthList=`echo ${EthListBefore} ${EthListAfter} | sed 's/ /\n/g' | sort | uniq --unique`
        echo -e "ETH interfaces to test:\n${EthList}" | tee --append ${TestCaseLogName}

        if [ "${EthList}" == "" ]; then
                local TestError=${ERR_VALUE}
                echo "No ETH interfaces for test" | tee --append ${TestCaseLogName}
        else
                local TestError=${ERR_OK}
                echo "Waiting for ETH interfaces to obtain IP address..." | tee --append ${TestCaseLogName}
                sleep 15
        fi

        for Eth in ${EthList}; do
                local GwSet=`ip route list | grep "^default" | head --lines=1`
                if [ "${GwIp}" != "" ] && [ "${GwSet}" != "" ] && [ "${GwCurrent}" != "" ]; then
                        echo ${MenPcPassword} | sudo --stdin --prompt="" ip route delete ${GwSet}
                        local GwCurrent="default via ${GwIp} dev ${Eth} proto static"
                        echo "Changing default gateway to: ${GwCurrent}" | tee --append ${TestCaseLogName}
                        echo ${MenPcPassword} | sudo --stdin --prompt="" ip route add ${GwCurrent}
                        local GwSet=`ip route list | grep "^default" | head --lines=1`
                        echo "Default gateway is now: ${GwSet}" | tee --append ${TestCaseLogName}
                fi

                echo "Testing ping on ETH interface ${Eth}" | tee --append ${TestCaseLogName}
                ping -c ${PingPacketCount} -W ${PingPacketTimeout} -I ${Eth} ${PingTestHost} | tee --append ${TestCaseLogName} 2>&1
                if [ ${PIPESTATUS} -ne 0 ]; then
                        local TestError=${ERR_VALUE}
                        echo "No ping reply on ETH interface ${Eth}" | tee --append ${TestCaseLogName}
                else
                        echo "Ping on ETH interface ${Eth} OK" | tee --append ${TestCaseLogName}
                fi
        done

        local GwSet=`ip route list | grep "^default" | head --lines=1`
        if [ "${GwSet}" != "" ] && [ "${GwDefault}" != "" ] && [ "${GwSet}" != "${GwDefault}" ]; then
                echo ${MenPcPassword} | sudo --stdin --prompt="" ip route delete ${GwSet}
                echo "Changing default gateway to: ${GwDefault}" | tee --append ${TestCaseLogName}
                echo ${MenPcPassword} | sudo --stdin --prompt="" ip route add ${GwDefault}
                local GwSet=`ip route list | grep "^default" | head --lines=1`
                echo "Default gateway is now: ${GwSet}" | tee --append ${TestCaseLogName}
        fi

        return ${TestError}
}

###############################################################################

# Move to correct Test_Summary directory
cd ${1}

###############################################################################
###############################################################################
######################## Start of Test Case ###################################
###############################################################################
###############################################################################

# 0 means success
TestCaseStep1=0 # Cable test
TestCaseStep2=0 # Cable test
TestCaseStep3=${ERR_UNDEFINED}
TestCaseStep4=${ERR_UNDEFINED}
TestCaseStep5=${ERR_UNDEFINED}
TestCaseStep6=${ERR_UNDEFINED}

CmdResult=${ERR_UNDEFINED}

# State machine runs all steps described in Test Case
# Step1
# .....
# Step5
# Additional Break state is added to handle/finish TestCase properly
MachineState="Step1"
MachineRun=true

while ${MachineRun}; do
        case ${MachineState} in
        Step1);&
        Step2);&
        Step3);&
        Step4);&
        Step5)
                echo "Run steps @2, @3, @4, @5"
                echo "Test case ${ScriptName} started"
                run_test_case_common_actions ${TestCaseLogName} ${TestCaseName}
                CmdResult=${?}
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        echo "run_test_case_common_actions: Failed, force exit Test Case" | tee --append ${TestCaseLogName}
                        MachineState="Break"
                else
                        echo "Run steps @2, @3, @4, @5" > ${TestCaseLogName}
                        echo "Test case ${ScriptName} started" > ${TestCaseLogName}
                        TestCaseStep2=0
                        TestCaseStep3=0
                        TestCaseStep4=0
                        TestCaseStep5=0
                        MachineState="Step6"
                fi
                ;;
        Step6)
                echo "Run step @6" | tee --append ${TestCaseLogName}
                eth_test
                CmdResult=${?}
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        TestCaseStep6=${CmdResult}
                else
                        TestCaseStep6=0
                fi
                MachineState="Break"
                ;;
        Break) # Clean after Test Case
                echo "Break State"  | tee --append ${TestCaseLogName}
                run_test_case_common_end_actions ${TestCaseLogName} ${TestCaseName}
                MachineRun=false
                ;;
        *)
                echo "State is not set, start with Step1" | tee --append ${TestCaseLogName}
                MachineState="Step1"
                ;;
        esac
done

ResultsSummaryTmp="${ResultsFileLogName}.tmp"
echo "${TestCaseName}" | tee --append ${TestCaseLogName} ${ResultsSummaryTmp}
echo "@1 - ${TestCaseStep1}" | tee --append ${TestCaseLogName} ${ResultsSummaryTmp}
echo "@2 - ${TestCaseStep2}" | tee --append ${TestCaseLogName} ${ResultsSummaryTmp}
echo "@3 - ${TestCaseStep3}" | tee --append ${TestCaseLogName} ${ResultsSummaryTmp}
echo "@4 - ${TestCaseStep4}" | tee --append ${TestCaseLogName} ${ResultsSummaryTmp}
echo "@5 - ${TestCaseStep5}" | tee --append ${TestCaseLogName} ${ResultsSummaryTmp}
echo "@6 - ${TestCaseStep6}" | tee --append ${TestCaseLogName} ${ResultsSummaryTmp}

# move to previous directory
cd ${CurrDir}

exit ${TestError}
