#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/SMB2_Tests/b_smb2_eetemp.sh"
source "${MyDir}/Ip_Core_Tests/z029_can.sh"

############################################################################
# Box PC BL51 description
#
# parameters:
# $1    Module number
# $2    Module log path 
function bl51_boxpc_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "--------------------------BL51 BoxPC Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Run Z029, RS422/485, RS232 tests on BL50"
    echo "    Tests on BL51 for ip cores:"
    echo "       Z029 (can test)"
    echo "    UART loopback tests on interfaces:"
    echo "       RS422/485"
    echo "       RS232"
    echo "PURPOSE:"
    echo "    Check if all interfaces of BoxPC are detected and are working"
    echo "    correctly"
    echo "UPPER_REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    echo "    MEN_13MD0590_SWR_0870"
    print_requirements "z029_can_description"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1080"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on BL51 are passed."
    echo "    FAIL otherwise"
    echo ""

    if [ ! -z "${LongDescription}" ]
    then
        z029_can_description
    fi
}

############################################################################
# Box PC BL51E10 test
#
# parameters:
#
function bl51_boxpc_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

    # Board in this Test Case always have
    VenID="sc31_fpga"
    DevID=""
    SubVenID=""
    UartDevice0="ttyS1"  # RS422/485
    UartDevice1="ttyS2"  # RS232

    CanTest="loopback_single"
    MachineState="uart_test0"
    MachineRun=true
    CanTestResult=${ERR_OK} # This test is disabled
    UartTestResult0=${ERR_VALUE}
    UartTestResult1=${ERR_VALUE}

    while ${MachineRun}; do
        case "${MachineState}" in
        #can_test)
        #    debug_print "${LogPrefix} Run CAN test" "${LogFile}"
        #    "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
        #                                     -id "${TestCaseId}"\
        #                                     -os "${OsNameKernel}"\
        #                                     -dname "z029_can"\
        #                                     -venid "${VenID}"\
        #                                     -devid "${DevID}"\
        #                                     -subvenid "${SubVenID}"\
        #                                     -tspec "${CanTest}"\
        #                                     -dno "1"
        #    CanTestResult=$?
        #    MachineState="uart_test0"
        #    ;;
        uart_test0)
            debug_print "${LogPrefix} Run UART RS422/485 test" "${LogFile}"
            "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z125_uart"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "${UartDevice0}"\
                                             -dno "1"
            UartTestResult0=$?
            MachineState="uart_test1"
            ;;
        uart_test1)
            debug_print "${LogPrefix} Run UART RS232 test" "${LogFile}"
            "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z125_uart"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "${UartDevice1}"\
                                             -dno "2"
            UartTestResult1=$?
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

    if [ "${CanTestResult}" = "${ERR_OK}" ] && \
       [ "${UartTestResult0}" = "${ERR_OK}" ] && \
       [ "${UartTestResult1}" = "${ERR_OK}" ]
    then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
