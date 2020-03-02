#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/Ip_Core_Tests/z029_can.sh"
source "${MyDir}/Ip_Core_Tests/z034_z037_gpio.sh"
source "${MyDir}/Ip_Core_Tests/z025_uart.sh"

############################################################################
# board g215 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function f215_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------G215 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    g215_${ModuleNo}"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run board g215 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function g215_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local BoardInSystem=${3}

    # Board in this Test Case always have
    VenID="0x1a88"
    DevID="0x4d45"
    SubVenID="0x00a2"
    UartNo="2"
    CanTest="loopback"
    GpioTest="read" # "write"
    MachineState="uart_test"
    MachineRun=true

    while ${MachineRun}; do
        case "${MachineState}" in
        uart_test)
            echo "${LogPrefix} Run UART test" | tee -a "${TestCaseLogName}" 2>&1
            blacklist_mcb_pci "${TestCaseLogName}" "${LogPrefix}" # Move to PC_Configure script
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z025_uart"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "${UartNo}"\
                                             -dno "1"
            UartTestResult=$?
            MachineState="can_test"
            ;;
        can_test)
            echo "${LogPrefix} Run CAN test" | tee -a "${TestCaseLogName}" 2>&1
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
            MachineState="gpio_test"
            ;;
        gpio_test)
            echo "${LogPrefix} Run GPIO test" | tee -a "${TestCaseLogName}" 2>&1
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z034_z037_gpio"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "dummy"\
                                             -dno "1"
            GpioTestResult=$?
            MachineState="Break"
            ;;
        Break) 
            # Clean after Test Case
            echo "${LogPrefix} Break State" | tee --a "${TestCaseLogName}"
            MachineRun=false
            ;;
        *)
            echo "${LogPrefix} State is not set, start with uart_test" | tee -a "${TestCaseLogName}"
            MachineState="uart_test"
            ;;
        esac
    done

    if [ "${UartTestResult}" = "${ERR_OK}" ] && [ "${CanTestResult}" = "${ERR_OK}" ] && [ "${GpioTestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
