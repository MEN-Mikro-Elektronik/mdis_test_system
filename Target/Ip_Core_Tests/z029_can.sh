#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z029 CAN test description
#
# parameters:
# $1    Module number
# $2    Module log path
function z029_can_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "-------------------------Ip Core z029 CAN Test Case----------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "    If there are 2 CAN on board then they shall be connected with each other"
    echo "DESCRIPTION:"
    echo "    Test type:"
    echo "     - loopback between 2 CAN interfaces on the same board (loopback)"
    echo "     - internal loopback with 1 CAN interface (loopback_single)"
    echo "    Test type shall be passed as parameter"
    echo "    1.Read chameleon table from board"
    echo "    2.Load m-module drivers: modprobe men_ll_z15"
    echo "    3.Find CAN(s) devices on board"
    echo "    4.Run mscan_pingpong/mscan_loopb"
    echo "    5.Check the results - result log shall contain no errors or warnings"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# IP core have to be tested on certain carrier, user has to specify
# exact location of ip core in the system
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    Board vendor id
# $4    Board device id
# $5    Board subvendor id
# $6    Board number in system
# $7    Test type
function z029_can_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}

    MezzChamDevName="MezzChamDevName.txt"
    CmdResult=${ERR_VALUE}
    obtain_device_list_chameleon_device "${VenID}" "${DevID}" "${SubVenID}" "${MezzChamDevName}" "${BoardInSystem}" "${LogFile}" "${LogPrefix}"
    case "${TestType}" in
        loopback)
            #It is assumed, that 2 CANs are available, and are connected together
            can_test_ll_z15 "${LogFile}" "${LogPrefix}" "${MezzChamDevName}"
            CmdResult=$?
            if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                debug_print "${LogPrefix} can_test_ll_z15 err: ${CmdResult}" "${LogFile}"
            else
                debug_print "${LogPrefix} can_test_ll_z15 success " "${LogFile}"
            fi
            ;;
        loopback_single)
            #It is assumed, that 1 CAN is available in board
            can_test_ll_z15_loopback "${LogFile}" "${LogPrefix}" "${MezzChamDevName}"
            CmdResult=$?
            if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                debug_print "${LogPrefix} can_test_ll_z15_loopback err: ${CmdResult}" "${LogFile}"
            else
                debug_print "${LogPrefix} can_test_ll_z15_loopback success " "${LogFile}"
            fi
            ;;
        *)
            echo "${LogPrefix} No valid test name: ${TestType}" "${LogFile}"
            ;;
    esac

    return "${CmdResult}"
}

############################################################################
# Test CAN with men_ll_z15 IpCore 2 CAN interfaces
#
# parameters:
# $1      Log file
# $2      Log prefix
# $3      Mezzaine chameleon device description file
function can_test_ll_z15 {
    local LogFile=${1}
    local LogPrefix=${2}
    local MezzChamDevDescriptionFile=${3}

    if ! run_as_root modprobe men_ll_z15
    then
        debug_print "${LogPrefix}  ERR_VALUE :could not modprobe men_ll_z15" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    local CanNumber
    CanNumber=$(grep -c "^can" "${MezzChamDevDescriptionFile}")
    if [ "${CanNumber}" -ne "2" ]; then
        debug_print "${LogPrefix}  There are ${CanNumber} CAN interfaces" "${LogFile}"
    else
        local CAN1
        local CAN2
        CAN1=$(grep "^can" "${MezzChamDevDescriptionFile}" | awk NR==1'{print $1}')
        CAN2=$(grep "^can" "${MezzChamDevDescriptionFile}" | awk NR==2'{print $1}')
    fi

    if ! run_as_root mscan_pingpong "${CAN1}" "${CAN2}" >> "mscan_pingpong_${CAN1}_${CAN2}.txt" 2>&1
    then
        debug_print "${LogPrefix}  mscan_pingpong on ${CAN1} ${CAN2} error" "${LogFile}"
        return "${ERR_VALUE}"
    else
        local CanResult
        CanResult=$(grep "TEST RESULT:" "mscan_pingpong_${CAN1}_${CAN2}.txt" | awk NR==1'{print $3}')
        if [ "${CanResult}" -ne "${ERR_OK}" ]; then
            return "${ERR_RUN}"
        fi
        return "${ERR_OK}"
    fi
}

############################################################################
# Test CAN with men_ll_z15 IpCore 1 CAN interface
#
# parameters:
# $1      Log file
# $2      Log prefix
# $3      Mezzaine chameleon device description file
function can_test_ll_z15_loopback {
    local LogFile=${1}
    local LogPrefix=${2}
    local MezzChamDevDescriptionFile=${3}

    if ! run_as_root modprobe men_ll_z15
    then
        debug_print "${LogPrefix}  ERR_VALUE :could not modprobe men_ll_z15" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    local CanNumber
    CanNumber=$(grep -c "^can" "${MezzChamDevDescriptionFile}")
    if [ "${CanNumber}" -ne "1" ]; then
        debug_print "${LogPrefix}  There are ${CanNumber} CAN interfaces" "${LogFile}"
    else
        local CAN1
        CAN1=$(grep "^can" "${MezzChamDevDescriptionFile}" | awk NR==1'{print $1}')
    fi

    if ! run_as_root mscan_loopb "${CAN1}" >> "mscan_loopb_${CAN1}.txt" 2>&1
    then
        debug_print "${LogPrefix}  mscan_loopb on ${CAN1} error" "${LogFile}"
        return "${ERR_VALUE}"
    else
        local CanResult
        CanResult=$(grep "TEST RESULT:" "mscan_loopb_${CAN1}.txt" | awk NR==1'{print $3}')
        if [ "${CanResult}" -ne "${ERR_OK}" ]; then
            return "${ERR_RUN}"
        fi
        return "${ERR_OK}"
    fi
}
