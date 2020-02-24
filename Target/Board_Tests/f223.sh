#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# board f223 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function f223_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------F223 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo ""
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run board f223 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function f223_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    MachineState="Step1"
    MachineRun=true

    while ${MachineRun}; do
        case "${MachineState}" in
            Step1);&
            Step2)
                echo "Run step @2" | tee -a "${TestCaseLogName}" 2>&1
                echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_pi7c9_gpio
                if [ $? -ne 0 ]; then
                    echo "ERR_VALUE: could not modprobe men_ll_pi7c9_gpio" | tee -a "${TestCaseLogName}" 2>&1
                    return "${ERR_VALUE}"
                fi
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' pi7c9_gpio_simp -g pi7c9_gpio_1 > pi7c9_gpio_simp_output.txt 2>&1
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                    echo "ERR pi7c9_gpio_simp -g pi7c9_gpio_1" | tee -a "${TestCaseLogName}" 2>&1
                    MachineState="Break"
                    TestCaseStep2=${ERR_SIMP_ERROR}
                else
                    TestCaseStep2=0
                    BinaryStateBegin="$(cat ./pi7c9_gpio_simp_output.txt\
                      | awk NR==2'{print $2 $3 $4 $5 $6 $7 $8 $9}')"
                    MachineState="Step3"
                fi
                ;;
            Step3)
                echo "Run step @3" | tee -a "${TestCaseLogName}" 2>&1
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' pi7c9_gpio_simp -s=1 -p=0x01 pi7c9_gpio_1
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                    echo "ERR pi7c9_gpio_simp -s=1 -p=0x01 pi7c9_gpio_1" | tee -a "${TestCaseLogName}" 2>&1
                    TestCaseStep3=${ERR_SIMP_ERROR}
                    MachineState="Break"
                else
                    TestCaseStep3=0
                    MachineState="Step4"
                fi
                echo "PORT 0 should be 1: $(awk NR==2'{print $9}')" | tee -a "${TestCaseLogName}" 2>&1
                ;;
            Step4)
                echo "Run step @4" | tee -a "${TestCaseLogName}" 2>&1
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' pi7c9_gpio_simp -s=0 -p=0x01 pi7c9_gpio_1
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                    echo "ERR pi7c9_gpio_simp -s=0 -p=0x01 pi7c9_gpio_1" | tee -a "${TestCaseLogName}" 2>&1
                    MachineState="Break"
                else
                    TestCaseStep4=0
                    MachineState="Step5"
                fi
                echo "PORT 0 should be 0: $(awk NR==2'{print $9}')" | tee -a "${TestCaseLogName}" 2>&1
                ;;
            Step5)
                echo "Run step @5" | tee -a ${TestCaseLogName} 2>&1
                echo "Go to beginning state of F223"            | tee -a "${TestCaseLogName}" 2>&1
                echo "Beginning state: ${BinaryStateBegin}"       | tee -a "${TestCaseLogName}" 2>&1
                echo "Disable all port first"                   | tee -a "${TestCaseLogName}" 2>&1
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' pi7c9_gpio_simp -s=0 -p=0xFF pi7c9_gpio_1
                echo "Set previous value"                       | tee -a "${TestCaseLogName}" 2>&1
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' pi7c9_gpio_simp -s=1 -p=0x$((2#${BinaryStateBegin})) pi7c9_gpio_1
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' pi7c9_gpio_simp -g pi7c9_gpio_1 > pi7c9_gpio_simp_output_end.txt 2>&1
                # Check if value at the end of the Test Case is equal to the value from
                # the beginning
                BinaryStateEnd="$(cat ./pi7c9_gpio_simp_output_end.txt\
                                | awk NR==2'{print $2 $3 $4 $5 $6 $7 $8 $9}')"
                echo "End state: ${BinaryStateBegin}" | tee -a "${TestCaseLogName}" 2>&1

                if [ $((${BinaryStateBegin})) -ne $((${BinaryStateEnd})) ]; then
                    echo "ERR ${ERR_VALUE} :could not set up previous state" | tee -a "${TestCaseLogName}" 2>&1
                else
                    TestCaseStep5=0
                    MachineState="Break"
                fi
                ;;
            Break)
                # Clean after Test Case
                ;;
            *)
                echo "State is not set, start with Step1"
                MachineState="Step1"
                ;;
        esac
    done
    if [ "${TestCaseStep2}" = "${ERR_OK}" ] && [ "${TestCaseStep3}" = "${ERR_OK}" ] &&\
       [ "${TestCaseStep3}" = "${ERR_OK}" ] && [ "${TestCaseStep4}" = "${ERR_OK}" ] &&\
       [ "${TestCaseStep5}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
