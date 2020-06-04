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
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "--------------------------------F223 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Use pi7c9_gpio_simp to set GPIO port HIGH/LOW"
    echo "    1. Load men_ll_pi7c9_gpio driver"
    echo "    2. Save command pi7c9_gpio_simp -g pi7c0_gpio_1 output"
    echo "    3. Set f223 port state to 1: pi7c9_gpio_simp -s=1 -p=0x01 pi7c0_gpio_1"
    echo "       Check if port state was set."
    echo "    4. Set f223 port state to 0: pi7c9_gpio_simp -s=1 -p=0x01 pi7c0_gpio_1"
    echo "       Check if port state was set."
    echo "    5. Set f223 port values into state before the test and compare the read"
    echo "       values"
    echo "PURPOSE:"
    echo "    Check if F223 board is detected and is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    arch_requirement "pci"
    echo "    MEN_13MD0590_SWR_1020"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1310"
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
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function f223_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local Port0=""

    MachineState="Step1"
    MachineRun=true

    while ${MachineRun}; do
        case "${MachineState}" in
            Step1);&
            Step2)
                debug_print "${LogPrefix} Run step @2" "${LogFile}"
                if ! run_as_root modprobe men_ll_pi7c9_gpio
                then
                    debug_print "ERR_VALUE: could not modprobe men_ll_pi7c9_gpio" "${LogFile}"
                    return "${ERR_VALUE}"
                fi
                if ! run_as_root pi7c9_gpio_simp -g pi7c9_gpio_1 > pi7c9_gpio_simp_start.txt 2>&1
                then
                    debug_print "${LogPrefix} ERR pi7c9_gpio_simp -g pi7c9_gpio_1" "${LogFile}"
                    MachineState="Break"
                    TestCaseStep2=${ERR_SIMP_ERROR}
                else
                    TestCaseStep2=0
                    BinaryStateBegin="$(awk NR==2'{print $2 $3 $4 $5 $6 $7 $8 $9}' < pi7c9_gpio_simp_start.txt)"
                    MachineState="Step3"
                fi
                ;;
            Step3)
                debug_print "${LogPrefix} Run step @3" "${LogFile}"
                if ! run_as_root pi7c9_gpio_simp -s=1 -p=0x01 pi7c9_gpio_1
                then
                    debug_print "ERR pi7c9_gpio_simp -s=1 -p=0x01 pi7c9_gpio_1" "${LogFile}"
                    TestCaseStep3=${ERR_SIMP_ERROR}
                    MachineState="Break"
                else
                    run_as_root pi7c9_gpio_simp -g pi7c9_gpio_1 > pi7c9_gpio_simp_port0_set.txt 2>&1
                    Port0=$(awk NR==2'{print $9}' < pi7c9_gpio_simp_port0_set.txt)
                    if [ "${Port0}" = "1" ]
                    then
                        TestCaseStep3="0"
                    else
                        TestCaseStep3="${ERR_VALUE}"
                    fi
                    MachineState="Step4"
                fi
                debug_print "${LogPrefix} PORT0 should be 1: ${Port0}" "${LogFile}"
                ;;
            Step4)
                debug_print "${LogPrefix} Run step @4" "${LogFile}"
                if ! run_as_root pi7c9_gpio_simp -s=0 -p=0x01 pi7c9_gpio_1
                then
                    debug_print "${LogPrefix} ERR pi7c9_gpio_simp -s=0 -p=0x01 pi7c9_gpio_1" "${LogFile}"
                    MachineState="Break"
                else
                    run_as_root pi7c9_gpio_simp -g pi7c9_gpio_1 > pi7c9_gpio_simp_port0_clear.txt 2>&1
                    Port0=$(awk NR==2'{print $9}' < pi7c9_gpio_simp_port0_clear.txt)
                    if [ "${Port0}" = "0" ]
                    then
                        TestCaseStep4="0"
                    else
                        TestCaseStep4="${ERR_VALUE}"
                    fi
                    TestCaseStep4=0
                    MachineState="Step5"
                fi
                debug_print "PORT0 should be 0: ${Port0}" "${LogFile}"
                ;;
            Step5)
                debug_print "${LogPrefix} Run step @5" "${LogFile}"
                debug_print "${LogPrefix} Go to beginning state of F223" "${LogFile}"
                debug_print "${LogPrefix} Beginning state: ${BinaryStateBegin}" "${LogFile}"
                debug_print "${LogPrefix} Disable all port first" "${LogFile}"
                run_as_root pi7c9_gpio_simp -s=0 -p=0xFF pi7c9_gpio_1
                debug_print "${LogPrefix} Set previous value" "${LogFile}"
                run_as_root pi7c9_gpio_simp -s=1 -p=0x$((2#${BinaryStateBegin})) pi7c9_gpio_1
                run_as_root pi7c9_gpio_simp -g pi7c9_gpio_1 > pi7c9_gpio_simp_end.txt 2>&1
                # Check if value at the end of the Test Case is equal to the value from
                # the beginning
                BinaryStateEnd="$(awk NR==2'{print $2 $3 $4 $5 $6 $7 $8 $9}' < pi7c9_gpio_simp_end.txt)"
                debug_print "${LogPrefix} End state: ${BinaryStateBegin}" "${LogFile}"

                if [ $((BinaryStateBegin)) -ne $((BinaryStateEnd)) ]; then
                    debug_print "${LogPrefix} ERR ${ERR_VALUE} :could not set up previous state" "${LogFile}"
                else
                    TestCaseStep5=0
                    MachineState="Break"
                fi
                ;;
            Break)
                # Clean after Test Case
                debug_print "${LogPrefix} Break State" "${LogFile}"
                MachineRun=false
                ;;
            *)
                debug_print "${LogPrefix} State is not set, start with Step1" "${LogFile}"
                MachineState="Step1"
                ;;
        esac
    done
    if [ "${TestCaseStep2}" = "${ERR_OK}" ] && [ "${TestCaseStep2}" = "${ERR_OK}" ] &&\
       [ "${TestCaseStep3}" = "${ERR_OK}" ] && [ "${TestCaseStep4}" = "${ERR_OK}" ] &&\
       [ "${TestCaseStep5}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
