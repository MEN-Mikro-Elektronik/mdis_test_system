#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/SMB2_Tests/b_smb2.sh"
source "${MyDir}/SMB2_Tests/b_smb2_eetemp.sh"
source "${MyDir}/SMB2_Tests/b_smb2_pci.sh"
source "${MyDir}/SMB2_Tests/b_smb2_led.sh"
source "${MyDir}/Ip_Core_Tests/z029_can.sh"

############################################################################
# Box PC BL70 description
#
# parameters:
# $1    Module number
# $2    Module log path 
function bl70_boxpc_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------BL70 BoxPC Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Run tests on BL70:"
    echo "       SMB2 read board ident"
    echo "       SMB2 read temperature"
    echo "       SMB2 enable/disable pci extension card (register read,write)"
    echo "       Z029 (can test)"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on BL51 are passed."
    echo "    FAIL otherwise"
    echo ""
}

############################################################################
# Box PC BL70  test
#
# parameters:
#
function bl70_boxpc_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

    # Board in this Test Case always have
    VenID=""
    DevID=""
    SubVenID=""

    CanTest="loopback_single"
    MachineState="can_test"
    MachineRun=true
    CanTestResult=${ERR_VALUE}

    while ${MachineRun}; do
        case "${MachineState}" in
        board_ident_test)
            debug_print "${LogPrefix} Read board ident" "${LogFile}"
            MachineState="Break"
            ;;
        temperature_test)
            debug_print "${LogPrefix} Read board temperature" "${LogFile}"
            MachineState="Break"
            ;;
        pci_test)
            debug_print "${LogPrefix} Enable and disable pci card" "${LogFile}"
            PciTestResult=$?
            MachineState="Break"
            ;;
        led_test)
            debug_print "${LogPrefix} Turn on/off LEDs" "${LogFile}"
            LedTestResult=$?
            MachineState="Break"
            ;;
        can_test)
            debug_print "${LogPrefix} Run CAN test" "${LogFile}"
            CanTestResult=$?
            MachineState="Break"
            ;;
        Break)
            # Clean after Test Case
            debug_print "${LogPrefix} Break State" "${LogFile}"
            MachineRun=false
            ;;
        *)
            debug_print "${LogPrefix} State is not set, start with can_test" "${LogFile}"
            MachineState="board_ident_test"
            ;;
        esac
    done

    if [ "${BoardIdentTestResult}" = "${ERR_OK}" ] && [ "${TemperatureTestResult}" = "${ERR_OK}" ] && [ "${PciTestResult}" = "${ERR_OK}" ] && [ "${LedTestResult}" = "${ERR_OK}" ] && [ "${CanTestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
