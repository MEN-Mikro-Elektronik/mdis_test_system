#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/Ip_Core_Tests/z087_eth.sh"

############################################################################
# board f614 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function f614_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------F614 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    f614_${ModuleNo}"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on f614 are passed."
    echo "    FAIL otherwise"
    echo ""
}

############################################################################
# run board f614 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function f614_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local TestCaseLogName=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

    # Board in this Test Case always have
    VenID="0x1a88"
    DevID="0x4d45"
    SubVenID="0x00d7"

    MachineState="eth_test"
    MachineRun=true

    while ${MachineRun}; do
        case "${MachineState}" in
        eth_test)
            echo "${LogPrefix} Run UART test" | tee -a "${TestCaseLogName}" 2>&1
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z087_eth"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -tspec "none"\
                                             -dno "1"
            EthTestResult=$?
            MachineState="Break"
            ;;
        Break) 
            # Clean after Test Case
            echo "${LogPrefix} Break State" | tee --a "${TestCaseLogName}"
            MachineRun=false
            ;;
        *)
            echo "${LogPrefix} State is not set, start with eth_test" | tee -a "${TestCaseLogName}"
            MachineState="eth_test"
            ;;
        esac
    done

    if [ "${EthTestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
