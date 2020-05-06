#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z135_uart_description
#
# parameters:
# $1    Module number
# $2    Module log path
function z135_hsuart_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "-------------------------Ip Core 16Z135_HSUART Test Case---------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "    Used driver: DRIVERS/13Z135/driver.mak"
    echo "    This test supports z135_hsuart ipcore on G229 board"
    echo "    Connect two uart adapters on G229 with RS422 cable"
    echo "DESCRIPTION:"
    echo "    1.Load m-module driver: modprobe men_lx_z135"
    echo "    2.Check if there are HSUART(s) available in /dev/*"
    echo "    3.Check results - driver shall be loaded successfully,"
    echo "      In /dev/* five ttyHSU* HSUART(s) shall be available"
    echo "    4.Perform echo test on ttyHSU1 and ttyHSU3"
    echo "PURPOSE:"
    echo "    Check if men_lx_z135 driver is loaded correctly,"
    echo "    and new uart devices appears"
    echo "REQUIREMENT_ID:"
    echo "    MEN_13MD05-90_SA_1490"
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
# $7    Optional parameter - test type (optional)
function z135_hsuart_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}
    local RelayOutput=${IN_0_ENABLE}

    if ! run_as_root modprobe men_lx_z135
    then
        debug_print "${LogPrefix} ERR_MODPROBE :could not modprobe men_lx_z135" "${LogFile}"
        return "${ERR_MODPROBE}"
    fi

    CntHSUART=$(ls -l /dev/ttyHSU* | wc -l)
    debug_print "${LogPrefix} CntHSUART: ${CntHSUART}" "${LogFile}"

    if [ "${CntHSUART}" -eq 5 ]
    then
        return "${ERR_OK}"
    fi

    uart_test_lx_z135 "${LogFile}" "${LogPrefix}" "1" "3"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        debug_print "${LogPrefix} uart_test_lx_z135 failed, err: ${CmdResult}" "${LogFile}"
    fi

    return "${CmdResult}"
}

############################################################################
# Test RS422 with men_lx_z135 IpCore 
# 
# parameters:
# $1    Log file
# $2    Log prefix
# $3    First UART device
# $4    Second UART device
function uart_test_lx_z135 {
    local LogFile=${1}
    local LogPrefix=${2}
    local tty0="ttyHSU${3}"
    local tty1="ttyHSU${4}"

    if ! run_as_root stty -F "/dev/${tty0}" 9600
    then
        debug_print "${LogPrefix} Could not stty -F on /dev/${tty0}" "${LogFile}"
    fi
    sleep 1
    if ! run_as_root stty -F "/dev/${tty1}" 9600
    then
        debug_print "${LogPrefix} Could not stty -F on /dev/${tty1}" "${LogFile}"
    fi
    sleep 1

    if ! uart_test_tty "${tty1}" "${tty0}" "${LogPrefix}" "${LogFile}"
    then
        debug_print "${LogPrefix}  ERR_VALUE: ${tty1} with ${tty0}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    sleep 1
    if ! run_as_root rmmod men_lx_z135
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not rmmod m" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if ! run_as_root modprobe men_lx_z135
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not  modprobe men_lx_z135" "${LogFile}"
        return "${ERR_VALUE}"
    fi
    sleep 1

    if ! run_as_root stty -F "/dev/${tty0}" 9600
    then
        debug_print "${LogPrefix} Could not stty -F on /dev/${tty0}" "${LogFile}"
    fi
    sleep 1
    if ! run_as_root stty -F "/dev/${tty1}" 9600
    then
        debug_print "${LogPrefix} Could not stty -F on /dev/${tty1}" "${LogFile}"
    fi
    sleep 1

    if ! uart_test_tty "${tty0}" "${tty1}" "${LogPrefix}" "${LogFile}"
    then
        debug_print "${LogPrefix}  ERR_VALUE: ${tty0} with ${tty1}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
