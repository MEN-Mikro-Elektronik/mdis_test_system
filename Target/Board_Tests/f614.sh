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
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "--------------------------------F614 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    F614_${ModuleNo} Interfaces Test"
    echo "    Run tests for devices: z087_eth"
    echo "PURPOSE:"
    echo "    Check if interfaces of F614 board are detected and are working"
    echo "    correctly"
    echo "UPPER_REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    print_requirements "z087_eth_description"
    #echo "REQUIREMENT_ID:"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on F614 are passed."
    echo "    FAIL otherwise"
    echo ""

    if [ ! -z "${LongDescription}" ]
    then
        z087_eth_description
    fi
}

############################################################################
# run board f614 test
#
# parameters:
# $1    Test case ID
# $2    Test summary directory
# $3    Os kernel
# $4    Log file
# $5    Log prefix
# $6    Board number
function f614_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
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
            debug_print "${LogPrefix} Run ETH test" "${LogFile}"
            "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
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
            debug_print "${LogPrefix} Break State" "${LogFile}"
            MachineRun=false
            ;;
        *)
            debug_print "${LogPrefix} State is not set, start with eth_test" "${LogFile}"
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
