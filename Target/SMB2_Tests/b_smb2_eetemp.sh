#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# b_smb2_eetemp test
#
# parameters:
# $1    Module number
# $2    Module log path 
function b_smb2_eetemp_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "---------------------SMB2 temperature read Test Case-----------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Run SMB2 eetemp to read board temperature"
    echo "    1.Load drivers: modprobe men_mdis_kernel"
    echo "    2.Get board temperature"
    echo "    3.Check if temeparatue is returned"
    echo "PURPOSE:"
    echo "    Check if board temperature can be read"
    echo "UPPER_REQUIREMENT_ID:"
    print_env_requirements "${TestSummaryDirectory}"
    echo "    MEN_13MD0590_SWR_1950"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1600"
    echo "RESULTS"
    echo "    SUCCESS if test is passed without error(s) warning(s)"
    echo "    FAIL otherwise"
    echo ""
}

############################################################################
# run board smb2 read temperature test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function b_smb2_eetemp_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

    MachineState="Step1"
    MachineRun=true

    DevName="smb2_1"    # smb device name (e.g. smb2_1)

    while ${MachineRun}; do
        case ${MachineState} in
            Step1)
                debug_print "${LogPrefix} Run step @1" "${LogFile}"
                if ! do_modprobe men_mdis_kernel
                then
                    debug_print "${LogPrefix}  ERR_MODPROBE: could not modprobe men_mdis_kernel" "${LogFile}"
                    TestCaseStep1=${ERR_MODPROBE}
                    MachineState="Break"
                else
                    TestCaseStep1=${ERR_OK}
                    MachineState="Step2"
                fi
                ;;
            Step2)
                debug_print "${LogPrefix} Run step @2" "${LogFile}"
                run_as_root smb2_eetemp "${DevName}" > smb2_eetemp.log
                TestCaseStep2=${ERR_OK}
                MachineState="Step3"
                ;;
            Step3)
                debug_print "${LogPrefix} Run step @3" "${LogFile}"
                if ! grep "Current Board temperature: [0-9]\+\.[0-9]\+" smb2_eetemp.log; then
                    debug_print "${LogPrefix}  ERR_VALUE: could not read temperature" "${LogFile}"
                    TestCaseStep3=${ERR_VALUE}
                    MachineState="Break"
                else
                    TestCaseStep3=${ERR_OK}
                    MachineState="Break"
                fi
                ;;
            Break) # Clean after Test Case
                debug_print "${LogPrefix} Break State" "${LogFile}"
                MachineRun=false
                ;;
            *)
                debug_print "${LogPrefix} State is not set, start with Step1" "${LogFile}"
                MachineState="Step1"
                ;;
        esac
    done

    if [ "${TestCaseStep1}" = "${ERR_OK}" ] && [ "${TestCaseStep2}" = "${ERR_OK}" ] &&\
       [ "${TestCaseStep3}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi

}
