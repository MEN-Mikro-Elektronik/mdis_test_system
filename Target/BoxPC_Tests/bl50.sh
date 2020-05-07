#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/SMB2_Tests/b_smb2_eetemp.sh"
source "${MyDir}/SMB2_Tests/b_smb2_pci.sh"
source "${MyDir}/SMB2_Tests/b_smb2_poe.sh"
source "${MyDir}/Ip_Core_Tests/z029_can.sh"

############################################################################
# Box PC BL50 description
#
# parameters:
# $1    Module number
# $2    Module log path 
function bl50_boxpc_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------BL50 BoxPC Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Run tests on BL50:"
    echo "       SMB2 read boardident"
    echo "       SMB2 read temperature"
    echo "       SMB2 power over ethernet (register read,write)"
    echo "       SMB2 enable/disable pci extension card (register read,write)"
    echo "       Z029 (can test)"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on BL51 are passed."
    echo "    FAIL otherwise"
    echo ""
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
        can_test)
            print_debug "${LogPrefix} Run CAN test" "${LogFile}"
            CanTestResult=${ERR_VALUE}
            MachineState="Break"
            ;;
        Break)
            # Clean after Test Case
            print_debug "${LogPrefix} Break State" "${LogFile}"
            MachineRun=false
            ;;
        *)
            print_debug "${LogPrefix} State is not set, start with can_test" "${LogFile}"
            MachineState="can_test"
            ;;
        esac
    done

    if [ "${CanTestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
