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
    echo "    Load ip core driver and run simple test programs"
    echo "    Test type:"
    echo "     - loopback between 2 CAN interfaces on the same board (loopback)"
    echo "     - internal loopback with 1 CAN interface (loopback_single)"
    echo "    Test type shall be passed as parameter"
    echo "    1.Read chameleon table from board"
    echo "    2.Load m-module drivers: modprobe men_ll_z15"
    echo "    3.Find CAN(s) devices on board"
    echo "    4.Run mscan_pingpong/mscan_loopb"
    echo "    5.Check the results - result log shall contain no errors or warnings"
    echo "PURPOSE:"
    echo "    Check if ip core z029 with men_ll_z15 driver is working"
    echo "    correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1110"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1420"
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
        stress_test)
            #It is assumed, that 1 CAN is available in board
            can_test_ll_z15_stress "${LogFile}" "${LogPrefix}" "${MezzChamDevName}"
            CmdResult=$?
            if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                debug_print "${LogPrefix} can_test_ll_z15_stress err: ${CmdResult}" "${LogFile}"
            else
                debug_print "${LogPrefix} can_test_ll_z15_stress success " "${LogFile}"
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

############################################################################
# Test CAN with men_ll_z15 IpCore 1 CAN interface - stress test
# Prerequisites: CAN adapter available in system - it shall be detected as can0
#
# parameters:
# $1      Log file
# $2      Log prefix
# $3      Mezzaine chameleon device description file
function can_test_ll_z15_stress {
    local LogFile=${1}
    local LogPrefix=${2}
    local MezzChamDevDescriptionFile=${3}

    cd ../..
    sed -i '/MSCAN\/TOOLS\/MSCAN_PINGPONG\/COM\/program.mak/ a /MSCAN\/TOOLS\/MSCAN_CONCURRENT\/COM\/program.mak \\' Makefile
    make_install "${LogPrefix}"
    cd "${CurrentPath}" || exit "${ERR_NOEXIST}"

    debug_print "${LogPrefix} ip link set can0 type can bitrate 500000" "${LogFile}"
    if ! run_as_root ip link set can0 type can bitrate 500000
    then
        debug_print "${LogPrefix}  ERR_VALUE :ip link set can0 type can bitrate 500000" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    debug_print "${LogPrefix} ip link set up can0" "${LogFile}"
    if ! run_as_root ip link set up can0
    then
        debug_print "${LogPrefix}  ERR_VALUE :ip link set up can0" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    #Now can adapter shall be configured properly
    debug_print "${LogPrefix} modprobe men_ll_z15" "${LogFile}"
    if ! run_as_root modprobe men_ll_z15
    then
        debug_print "${LogPrefix}  ERR_VALUE :could not modprobe men_ll_z15" "${LogFile}"
        return "${ERR_VALUE}"
    fi
    debug_print "${LogPrefix}run mscan_concurrent > mscan_concurrent.log &" "${LogFile}"
    # Currently can number is fixed within mscan_concurrent (can_7 can8)
    if ! run_as_root $(mscan_concurrent > mscan_concurrent.log &)
    then
        debug_print "${LogPrefix}  ERR_VALUE :could not run mscan_concurrent" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Save background process PID
    local MscanConcurrentPID
    MscanConcurrentPID=$(pgrep "mscan_concurrent" | awk 'NR==1 {print $2}')
    debug_print "${LogPrefix}MscanConcurrentPID: ${MscanConcurrentPID}" "${LogFile}"
    # Can stress test duration in seconds
    local TestDuration=15

    debug_print "${LogPrefix} can_generate_frames" "${LogFile}"
    can_generate_frames "${LogFile}" "${LogPrefix}" "${TestDuration}" &

    debug_print "${LogPrefix}Test is running.." "${LogFile}"
    sleep ${TestDuration}

    # wait for all pending packets and updated mscan_concurrent log file
    debug_print "${LogPrefix}Waiting for results" "${LogFile}"
    sleep 40

    if ! run_as_root kill "${MscanConcurrentPID}"
    then
        print "${LogPrefix} Could not kill mscan_concurrent process ${MscanConcurrentPID}" "${LogFile}"
    fi

    # Compare packets number from can0 and MDIS can(s)
    local Can0PacketsNo
    local CanMdis0PacketsNo
    local CanMdis1PacketsNo
    Can0PacketsNo=$(ifconfig can0 | grep "TX packets" | awk '{print $3}')
    CanMdis0PacketsNo=$(grep can1 mscan_concurrent.log | tail -1 | awk '{print $5}')
    CanMdis1PacketsNo=$(grep can2 mscan_concurrent.log | tail -1 | awk '{print $7}')

    debug_print "${LogPrefix} Can0PacketsNo: ${Can0PacketsNo}" "${LogFile}"
    debug_print "${LogPrefix} CanMdis0PacketsNo: ${CanMdis0PacketsNo}" "${LogFile}"
    debug_print "${LogPrefix} CanMdis1PacketsNo: ${CanMdis1PacketsNo}" "${LogFile}"

    if [ "${Can0PacketsNo}" = "${CanMdis0PacketsNo}" ] && [ "${Can0PacketsNo}" = "${CanMdis1PacketsNo}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

############################################################################
# Generate can frames on external device - shall be connected as can0 to system
#
# parameters:
# $1      Log file
# $2      Log prefix
# $3      Mezzaine chameleon device description file
function can_generate_frames {
    local LogFile=${1}
    local LogPrefix=${2}
    local TimeParam=${3}

    local Duration=$((SECONDS+TimeParam))

    debug_print "${LogPrefix} gpio_stress z17_io ${DeviceName} -g" "${LogFile}"

    while [ $SECONDS -lt $Duration ]; do
        cangen can0 -g .2 -I 42A -e -L 5 -D i -n 20
        sleep 0.04
        debug_print "${LogPrefix} SECONDS: ${SECONDS}/${Duration}" "${LogFile}"
    done

    return "${ERR_OK}"
}
