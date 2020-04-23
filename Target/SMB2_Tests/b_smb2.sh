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
function b_smb2_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------SMB2 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Run SMB2 tests - supports only G025A03 CPU Board"
    echo "PURPOSE:"
    echo "    Check access to SMB devices via the MDIS SMB2 API"
    echo "REQUIREMENT_ID:"
    echo "    MEN_13MD05-90_SA_1600"
    echo "RESULTS"
    echo "    SUCCESS if test is passed without error(s) warning(s)"
    echo "    FAIL otherwise"
    echo ""
}

############################################################################
# run board smb2 test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function b_smb2_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    MachineState="Step1"
    MachineRun=true

    DevName="smb2_1"    # smb device name (e.g. smb2_1)
    BoardName="G025A03" # board name (e.g. G025A03)

    while ${MachineRun}; do
        case ${MachineState} in
            Step1)
                debug_print "Run step @1" "${LogFile}"
                run_as_root modprobe men_mdis_kernel
                if [ $? -ne 0 ]; then
                    debug_print "${LogPrefix}  ERR_MODPROBE: could not modprobe men_mdis_kernel" "${LogFile}"
                    TestCaseStep1=${ERR_MODPROBE}
                    MachineState="Break"
                else
                    TestCaseStep1=${ERR_OK}
                    MachineState="Step2"
                fi
                ;;
            Step2)
                debug_print "Run step @2" "${LogFile}"
                run_as_root modprobe i2c_i801
                if [ $? -ne 0 ]; then
                    debug_print "${LogPrefix}  ERR_MODPROBE: could not modprobe i2c_i801" "${LogFile}"
                    TestCaseStep2=${ERR_MODPROBE}
                    MachineState="Break"
                else
                    TestCaseStep2=${ERR_OK}
                    MachineState="Step3"
                fi
                ;;
            Step3)
                debug_print "Run step @3" "${LogFile}"
                run_as_root smb2_boardident "${DevName}" > "smb2_boardident.log"
                run_as_root grep "HW-Name[[:space:]]\+=[[:space:]]\+${BoardName}" "smb2_boardident.log"
                CmdResult=$?
                if [ ${CmdResult} -ne 0 ]; then
                    debug_print "${LogPrefix}  ERR_VALUE: \"${BoardName}\" not found with smb2_boardident" "${LogFile}"
                    TestCaseStep3=${ERR_VALUE}
                    MachineState="Break"
                else
                    TestCaseStep3=${ERR_OK}
                    MachineState="Break"
                fi
                ;;
            Break) # Clean after Test Case
                debug_print "Break State" "${LogFile}"
                run_test_case_common_end_actions "${LogFile}" "${TestCaseName}"
                MachineRun=false
                ;;
            *)
                debug_print "State is not set, start with Step1" "${LogFile}"
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
