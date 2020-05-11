#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# smb2 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function b_smb2_poe_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "---------------------SMB2 Power over ethernet Test Case-----------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load drivers: modprobe men_mdis_kernel"
    echo "    2.Enable POE"
    echo "    3.Check if POE has been enabled"
    echo "    4.Disable POE"
    echo "    5.Check if POE has beed disabled"
    echo "PURPOSE:"
    echo "    Check if POE enabling is working"
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
# run board smb2 Power over ethernet test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function b_smb2_poe_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

    while ${MachineRun}; do
        case ${MachineState} in
            Step1)
                debug_print "${LogPrefix} Run step @1" "${LogFile}"
                if ! run_as_root modprobe men_mdis_kernel
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
                if ! run_as_root smb2_poe smb2_1 -s > "smb2_poe_set.log"; then
                    debug_print "${LogPrefix}  ERR_VALUE: Could not set POE state" "${LogFile}"
                    TestCaseStep2=${ERR_VALUE}
                    MachineState="Break"
                else
                    TestCaseStep2=${ERR_OK}
                    MachineState="Step3"
                fi
                ;;
            Step3)
                debug_print "${LogPrefix} Run step @3" "${LogFile}"
                if ! run_as_root smb2_poe smb2_1 -g > "smb2_poe_enabled.log"; then
                    debug_print "${LogPrefix}  ERR_VALUE: Could not get POE state" "${LogFile}"
                    TestCaseStep3=${ERR_VALUE}
                    MachineState="Break"
                else
                    TestCaseStep3=${ERR_OK}
                    MachineState="Step4"
                fi
                ;;
            Step4)
                debug_print "${LogPrefix} Run step @4" "${LogFile}"
                if ! grep "^state: 1  1  1  1" smb2_poe_enabled.log; then
                    debug_print "${LogPrefix}  ERR_VALUE: POE has not been enabled" "${LogFile}"
                    TestCaseStep4=${ERR_VALUE}
                    MachineState="Break"
                else
                    TestCaseStep4=${ERR_OK}
                    MachineState="Step5"
                fi
                ;;
            Step5)
                debug_print "${LogPrefix} Run step @5" "${LogFile}"
                if ! run_as_root smb2_poe smb2_1 -c > "smb2_poe_clear.log"; then
                    debug_print "${LogPrefix}  Could not clear POE state" "${LogFile}"
                    TestCaseStep5=${ERR_VALUE}
                    MachineState="Break"
                else
                    TestCaseStep5=${ERR_OK}
                    MachineState="Step6"
                fi
                ;;
            Step6)
                debug_print "${LogPrefix} Run step @6" "${LogFile}"
                if ! run_as_root smb2_poe smb2_1 -g > "smb2_poe_disabled.log"; then
                    debug_print "${LogPrefix}  ERR_VALUE: Could not get POE state" "${LogFile}"
                    TestCaseStep6=${ERR_VALUE}
                    MachineState="Break"
                else
                    TestCaseStep6=${ERR_OK}
                    MachineState="Step7"
                fi
                ;;
            Step7)
                debug_print "${LogPrefix} Run step @7" "${LogFile}"
                if ! grep "^state: 0  0  0  0" smb2_poe_disabled.log; then
                    debug_print "${LogPrefix}  ERR_VALUE: POE has not been diabled" "${LogFile}"
                    TestCaseStep7=${ERR_VALUE}
                    MachineState="Break"
                else
                    TestCaseStep7=${ERR_OK}
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
       [ "${TestCaseStep3}" = "${ERR_OK}" ] && [ "${TestCaseStep4}" = "${ERR_OK}" ] &&\
       [ "${TestCaseStep5}" = "${ERR_OK}" ] && [ "${TestCaseStep6}" = "${ERR_OK}" ] &&\
       [ "${TestCaseStep7}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}
