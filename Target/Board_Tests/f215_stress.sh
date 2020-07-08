#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/Ip_Core_Tests/z029_can.sh"
source "${MyDir}/Ip_Core_Tests/z034_gpio.sh"

############################################################################
# board f215 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function f215_stress_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "--------------------------------F215 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    F215_${ModuleNo} Interfaces Test"
    echo "    Run tests for devices: z029_can, z034_gpio"
    echo "PURPOSE:"
    echo "    MDIS stress test on can and gpio interfaces"
    echo "    correctly"
    echo "UPPER_REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    arch_requirement "pci"
    echo "    MEN_13MD0590_SWR_1010"
    print_requirements "z029_can_description"
    print_requirements "z034_gpio_description"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1300"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on F215 are passed."
    echo "    FAIL otherwise"
    echo ""

    if [ ! -z "${LongDescription}" ]
    then
        z029_can_description
        z034_gpio_description
    fi
}

############################################################################
# run board f215 test
#
# parameters:
# $1    Test case ID
# $2    Test summary directory
# $3    Os kernel
# $4    Log file
# $5    Log prefix
# $6    Board number
function f215_stress_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

    # Board in this Test Case always have
    VenID="0x1a88"
    DevID="0x4d45"
    SubVenID="0x006a"
    UartNo="2"
    CanTest="stress_test"
    GpioTest="stress_test" # "write"
    MachineState="gpio_z034_test"
    MachineRun=true

    while ${MachineRun}; do
        case "${MachineState}" in
        can_test)
            debug_print "${LogPrefix} Run CAN test" "${LogFile}"
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z029_can"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "${CanTest}"\
                                             -dno "1"
            CanTestResult=$?
            MachineState="gpio_z034_test"
            ;;
        gpio_z034_test)
            debug_print "${LogPrefix} Run GPIO z034 test" "${LogFile}"
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z034_gpio_stress"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "${GpioTest}"\
                                             -dno "1"
            GpioZ034TestResult=$?
            MachineState="Break"
            ;;
        Break) 
            # Clean after Test Case
            debug_print "${LogPrefix} Break State" "${LogFile}"
            MachineRun=false
            ;;
        *)
            debug_print "${LogPrefix} State is not set, start with uart_test" "${LogFile}"
            MachineState="uart_test"
            ;;
        esac
    done

    if [ "${CanTestResult}" = "${ERR_OK}" ] && [ "${GpioZ034TestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
