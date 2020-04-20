#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/Ip_Core_Tests/z055_hdlc.sh"

############################################################################
# board f206 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function f206_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------F206 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    F206_${ModuleNo} Interfaces Test. Z055_hdlc core is not detected automatically!"
    echo "    Run tests for devices: z055_hdlc"
    echo "PURPOSE:"
    echo "    Check if all interfaces of z055_hdlc ip-core are working correctly"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on F206 are passed."
    echo "    FAIL otherwise"
    echo ""
}

############################################################################
# run board f206 test
#
# parameters:
# $1    Test case ID
# $2    Test summary directory
# $3    Os kernel
# $4    Log file
# $5    Log prefix
# $6    Board number
function f206_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

    # Board in this Test Case always have
    MachineState="z055_hdlc_test"
    MachineRun=true

    while ${MachineRun}; do
        case "${MachineState}" in
        z055_hdlc_test)
            debug_print "${LogPrefix} Run z055_hdlc test" "${LogFile}"
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z055_hdlc"\
                                             -dno "1"
            HdlcTestResult=$?
            MachineState="Break"
            ;;
        Break) 
            # Clean after Test Case
            debug_print "${LogPrefix} Break State" "${LogFile}"
            MachineRun=false
            ;;
        *)
            debug_print "${LogPrefix} State is not set, start with z055_hdlc_test" "${LogFile}"
            MachineState="z055_hdlc_test"
            ;;
        esac
    done

    if [ "${HdlcTestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
