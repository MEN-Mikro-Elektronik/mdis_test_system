#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/Ip_Core_Tests/z001_smb.sh"
source "${MyDir}/Ip_Core_Tests/z029_can.sh"

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
    echo "    Run tests on g229_${ModuleNo} for ip cores:"
    echo "      - Z001 (smb test)"
    echo "      - Z029 (can test)"
    echo "      - Z135 (hsuart test)"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on G229 are passed."
    echo "    FAIL otherwise"
    echo ""

    if [ ! -z "${LongDescription}" ]
    then
        z001_smb_description
        z029_can_description
    fi
}

############################################################################
# run board g229 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function g229_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local TestCaseLogName=${4}
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
            echo "${LogPrefix} Smb test" | tee -a "${TestCaseLogName}" 2>&1
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
            MachineState="uart_test"
            ;;
        uart_test)
            echo "${LogPrefix} Run HSUART test" | tee -a "${TestCaseLogName}" 2>&1
            #run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
            #                                 -id "${TestCaseId}"\
            #                                 -os "${OsNameKernel}"\
            #                                 -dname "z029_can"\
            #                                 -venid "${VenID}"\
            #                                 -devid "${DevID}"\
            #                                 -subvenid "${SubVenID}"\
            #                                 -tspec "${CanTest}"\
            #                                 -dno "1"
            UartTestResult=${ERR_NOEXIST}
            MachineState="Break"
            ;;
        Break)
            # Clean after Test Case
            echo "${LogPrefix} Break State" | tee --a "${TestCaseLogName}"
            MachineRun=false
            ;;
        *)
            echo "${LogPrefix} State is not set, start with smb_test" | tee -a "${TestCaseLogName}"
            MachineState="smb_test"
            ;;
        esac
    done

    if [ "${CanTestResult}" = "${ERR_OK}" ] && [ "${SmbTestResult}" = "${ERR_OK}" ] && [ "${UartTestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
