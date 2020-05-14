#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/SMB2_Tests/b_smb2_eetemp.sh"
source "${MyDir}/SMB2_Tests/b_smb2_pci.sh"
source "${MyDir}/SMB2_Tests/b_smb2_led.sh"
source "${MyDir}/Ip_Core_Tests/z029_can.sh"
source "${MyDir}/Ip_Core_Tests/z125_uart.sh"

############################################################################
# Box PC BL50 description
#
# parameters:
# $1    Module number
# $2    Module log path 
function bl50_boxpc_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "--------------------------BL50 BoxPC Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Run tests on BL50:"
    echo "       Z029 (can test)"
    echo "       UART test"
    echo "PURPOSE:"
    echo "    Check if all interfaces of BoxPC are detected and are working"
    echo "    correctly"
    echo "UPPER_REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    echo "    MEN_13MD0590_SWR_0840"
    print_requirements "z029_can_description"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1060"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on BL50 are passed."
    echo "    FAIL otherwise"
    echo ""

    if [ ! -z "${LongDescription}" ]
    then
        z029_can_description
    fi
}

############################################################################
# Box PC BL50  test
#
# parameters:
#
function bl50_boxpc_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

    # FPGA chameleon table identifier
    VenID="sc24_fpga"
    DevID=""
    SubVenID=""
    UartDevice="ttyS3"  # device under /dev/*"

    CanTest="loopback_single"
    MachineState="can_test"
    MachineRun=true
    CanTestResult=${ERR_VALUE}

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
            MachineState="uart_test"
            ;;
        uart_test)
            debug_print "${LogPrefix} Run UART test" "${LogFile}"
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z125_uart"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "${UartDevice}"\
                                             -dno "1"
            UartTestResult=$?
            MachineState="Break"
            ;;
        Break)
            # Clean after Test Case
            debug_print "${LogPrefix} Break State" "${LogFile}"
            MachineRun=false
            ;;
        *)
            debug_print "${LogPrefix} State is not set, start with can_test" "${LogFile}"
            MachineState="can_test"
            ;;
        esac
    done

    if [ "${CanTestResult}" = "${ERR_OK}" ] && [ "${UartTestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
