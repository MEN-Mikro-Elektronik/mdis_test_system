#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/Ip_Core_Tests/z050_bioc.sh"
source "${MyDir}/Ip_Core_Tests/z051_dac.sh"

############################################################################
# board f401 test
#
# parameters:
# $1    Module number
# $2    Module log path
function f401_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "--------------------------------f401 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    f401_${ModuleNo} Interfaces Test"
    echo "    Run tests for devices: z051_dac"
    echo "PURPOSE:"
    echo "    Check if all interfaces of z051_dac ip-core are working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    arch_requirement "pci"
    print_requirements "z051_dac_description"
    #echo "REQUIREMENT_ID:"
    echo "RESULTS"
    echo "    SUCCESS if ip-cores tests on f401 are passed."
    echo "    FAIL otherwise"
    echo ""

    if [ ! -z "${LongDescription}" ]
    then
        z051_io_dac_description
    fi
}

############################################################################
# run board f401 test
#
# parameters:
# $1    Test case ID
# $2    Test summary directory
# $3    Os kernel
# $4    Log file
# $5    Log prefix
# $6    Board number
function f401_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}


    VenID="0x1172"
    DevID="0x000a"
    SubVenID="0x4d45"

    # Board in this Test Case always have
    MachineState="z050_bioc_test"
    MachineRun=true

    while ${MachineRun}; do
        case "${MachineState}" in
        z051_dac_test)
            debug_print "${LogPrefix} Run z051_dac test" "${LogFile}"
            "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z051_io_dac"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -dno "1"
            TestResult=$?
            MachineState="z050_bioc_test"
            ;;
        z050_bioc_test)
            debug_print "${LogPrefix} Run z050_bioc test" "${LogFile}"
            "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}"\
                                             -id "${TestCaseId}"\
                                             -os "${OsNameKernel}"\
                                             -dname "z050_io_bioc"\
                                             -venid "${VenID}"\
                                             -devid "${DevID}"\
                                             -subvenid "${SubVenID}"\
                                             -dno "1"
            TestResult=$?
            MachineState="Break"
            ;;
        Break)
            # Clean after Test Case
            debug_print "${LogPrefix} Break State" "${LogFile}"
            MachineRun=false
            ;;
        *)
            debug_print "${LogPrefix} State is not set, start with z051_dac_test" "${LogFile}"
            MachineState="z051_dac_test"
            ;;
        esac
    done

    if [ "${TestResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
