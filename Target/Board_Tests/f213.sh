#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# board f213 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function f213_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "--------------------------------F213 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    NOT TESTED"
    echo "PURPOSE:"
    echo "    "
    echo "UPPER_REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    #echo "REQUIREMENT_ID:"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run board f213 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function f213_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    MachineState="Step1"
    MachineRun=true

    while ${MachineRun}; do
        case $(echo "${MachineState}") in
          Step1)
                echo "Run step @1" | tee -a ${TestCaseLogName} 2>&1

                run_as_root i2cdetect -y -l > "i2c_bus_list_before.log" 2>&1

                TestCaseStep1=0
                MachineState="Step2"
                ;;
          Step2)
                echo "Run step @2" | tee -a ${TestCaseLogName} 2>&1

                do_modprobe men_lx_z001
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

                run_as_root i2cdetect -y -l > "i2c_bus_list_after.log" 2>&1

                TestCaseStep3=0
                MachineState="Step4"
                ;;
          Step4)
                echo "Run step @4" | tee -a ${TestCaseLogName} 2>&1

                cat "i2c_bus_list_before.log" "i2c_bus_list_after.log" | sort | uniq --unique > "i2c_bus_list_test.log" 2>&1
                SMBUS_ID=$(grep --only-matching "16Z001-[0-1]\+ BAR[0-9]\+ offs 0x[0-9]\+" "i2c_bus_list_test.log")
                run_as_root i2cdump -y "${SMBUS_ID}" 0x57 | grep "P511"
                CmdResult=$?
                if [ ${CmdResult} -ne ${ERR_OK} ]; then
                        echo "ERR_VALUE: i2cdump failed for ${SMBUS_ID}" | tee -a ${TestCaseLogName} 2>&1
                        MachineState="Break"
                        TestCaseStep4=${ERR_VALUE}
                else
                        TestCaseStep4=0
                        MachineState="Break"
                fi
                do_rmmod men_lx_z001
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
    done
    if [ "${TestCaseStep2}" = "${ERR_OK}" ] && [ "${TestCaseStep3}" = "${ERR_OK}" ] &&\
       [ "${TestCaseStep3}" = "${ERR_OK}" ] && [ "${TestCaseStep4}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
