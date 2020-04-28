#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/Ip_Core_Tests/z001_smb.sh"
source "${MyDir}/Ip_Core_Tests/z029_can.sh"
source "${MyDir}/Ip_Core_Tests/z127_gpio.sh"

############################################################################
# board g229 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function g229_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    local LongDescription=${3}
    echo "--------------------------------G229 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    G229 Interfaces Test"
    echo "    Run tests for devices: z001_smb, z029_can, z127_gpio, z135_hsuart"
    echo "PURPOSE:"
    echo "    Check if all interfaces of G215 board are detected and are working"
    echo "    correctly"
    echo "REQUIREMENT_ID:"
    echo "    MEN_13MD05-90_SA_1330"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on G229 are passed."
    echo "    FAIL otherwise"
    echo ""

    if [ ! -z "${LongDescription}" ]
    then
        z001_smb_description
        z029_can_description
        z127_gpio_description
        z135_hsuart_description
    fi
}

############################################################################
# run board g229 test
#
# parameters:
# $1    Test case ID
# $2    Test summary directory
# $3    Os kernel
# $4    Log file
# $5    Log prefix
# $6    Board number
function g229_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

    # Board in this Test Case always have
    VenID="0x1a88"
    DevID="0x4d45"
    SubVenID="0x00d1"

    CanTest="loopback_single"
    MachineState="smb_test"
    MachineRun=true
    SmbTestResult=${ERR_VALUE}
    CanTestResult=${ERR_VALUE}

    while ${MachineRun}; do
        case "${MachineState}" in
        smb_test)
            debug_print "${LogPrefix} Smb test" "${LogFile}"
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z001_smb"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "${CanTest}"\
                                             -dno "1"
            SmbTestResult=$?
            MachineState="can_test"
            ;;
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
            MachineState="gpio_z127_test"
            ;;
        gpio_z127_test)
            debug_print "${LogPrefix} Run GPIO z127 test" "${LogFile}"
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z127_gpio"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "dummy"\
                                             -dno "1"
            GpioZ127TestResult=$?
            MachineState="hsuart_test"
            ;;
        hsuart_test)
            debug_print "${LogPrefix} Run HSUART test" "${LogFile}"
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z135_hsuart"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "${CanTest}"\
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
            debug_print "${LogPrefix} State is not set, start with smb_test" "${LogFile}"
            MachineState="smb_test"
            ;;
        esac
    done

    if [ "${CanTestResult}" = "${ERR_OK}" ] && [ "${SmbTestResult}" = "${ERR_OK}" ] && [ "${GpioZ127TestResult}" = "${ERR_OK}" ] && [ "${UartTestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
