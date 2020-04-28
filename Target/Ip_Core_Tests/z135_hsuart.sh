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
    echo "-------------------------Ip Core 16Z135_UART Test Case---------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "    Used driver: DRIVERS/13Z135/driver.mak"
    echo "DESCRIPTION:"
    echo "    1.Read chameleon table from board"
    echo "    2.Load m-module drivers: modprobe men_lx_z135"
    echo "    3.Check if there are HSUART(s) available in /dev/*"
    echo "    9.Check results - driver shall be loaded successfully,"
    echo "      In /dev/* five ttyHSU* HSUART(s) are available"
    echo "PURPOSE:"
    echo "    Check if men_lx_z135 driver is loaded correctly,"
    echo "    and new uart devices appears "
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

    MezzChamDevName="MezzChamDevName.txt"
    obtain_device_list_chameleon_device "${VenID}" "${DevID}" "${SubVenID}" "${MezzChamDevName}" "${BoardInSystem}" "${LogFile}" "${LogPrefix}"

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

    return "${ERR_VALUE}"
}
