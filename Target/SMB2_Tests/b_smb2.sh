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
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "--------------------------------SMB2 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Run SMB2 boardident to read board name"
    echo "    1.Load men_mdis_kernel kernel module"
    echo "    2.Load i2c_i801 kernel module"
    echo "    3.Run program 'smb2_boardident'"
    echo "      Check output for errors"
    echo "      Check if HW-Name matches the CPU board"
    echo "PURPOSE:"
    echo "    Check access to SMB devices via the MDIS SMB2 API"
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
# run board smb2 test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function b_smb2_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}
    local BoardName=${7}

    MachineState="Step1"
    MachineRun=true

    DevName="smb2_1"    # smb device name (e.g. smb2_1)
    #BoardName="G025A03" # board name (e.g. G025A03)

    while ${MachineRun}; do
        case ${MachineState} in
            Step1)
                debug_print "${LogPrefix} Run step @1" "${LogFile}"
                if ! run_as_root  modprobe men_mdis_kernel
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
                if ! run_as_root  modprobe i2c_i801
                then
                    debug_print "${LogPrefix}  ERR_MODPROBE: could not modprobe i2c_i801" "${LogFile}"
                    TestCaseStep2=${ERR_MODPROBE}
                    MachineState="Break"
                else
                    TestCaseStep2=${ERR_OK}
                    MachineState="Step3"
                fi
                ;;
            Step3)
                debug_print "${LogPrefix} Run step @3" "${LogFile}"
                run_as_root smb2_boardident "${DevName}" > "smb2_boardident.log"
                if [ "${BoardName}" == "b_smb2" ]; then
                    run_as_root grep "HW-Name[[:space:]]\+=[[:space:]]\+[a-zA-Z0-9]\+" "smb2_boardident.log" > /dev/null
                else
                    run_as_root grep "HW-Name[[:space:]]\+=[[:space:]]\+${BoardName}" "smb2_boardident.log" > /dev/null
                fi
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
