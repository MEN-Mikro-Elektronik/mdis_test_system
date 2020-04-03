#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z025_uart test description
#
# parameters:
# $1    Module number
# $2    Module log path
function z055_hdlc_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "---------------------------Ip Core z055 HDLC----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "    Two HDCL interaces on board are connected with each other"
    echo "DESCRIPTION:"
    echo "    1.Load driver men_lx_z055"
    echo "    2.Run z055 script to establish ppp connection between interfaces"
    echo "    3.Send ping request over ppp0 and ppp1 interface"
    echo "    4.Check if ping request data was sent properly on each interface:"\
    echo "      - compare ppp0 rx data with ppp1 tx data (shall be the same)"
    echo "      - compare ppp0 tx data with ppp0 rx data (shall be the same)"
    echo "PURPOSE:"
    echo "    Check if ip core z055_hdlc is working correctly"
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
# $7    UART interfaces on board (optional)
function z055_hdlc_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}

    # load driver and establish ppp connection between Z055_HDLC interfaces
    ${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}/DRIVERS/Z055_HDLC/start-ppp-two-ports.sh &
    PPP_script_PID=$!

    # ping response is not required
    ping -I ppp0 -c 20 -i 0.1 -s 1400 &
    ping -I ppp1 -c 20 -i 0.2 -s 1400

    # compare ifconfig stats for ppp0 and ppp1
    z055_hdlc_compare_ppp_stats
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        debug_print "${LogPrefix} ppp stats failed, err: ${CmdResult}" "${LogFile}"
        return "${CmdResult}"
    fi

    # stop ppp connection
    ${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}/DRIVERS/Z055_HDLC/stop-ppp.sh
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        debug_print "${LogPrefix} ppp stats failed, err: ${CmdResult}" "${LogFile}"
        return "${CmdResult}"
    fi

    # unload z055_hdlc driver
    ${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}/DRIVERS/Z055_HDLC/unload-drivers.sh
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        debug_print "${LogPrefix} ppp stats failed, err: ${CmdResult}" "${LogFile}"
        return "${CmdResult}"
    fi

    return ${ERR_OK}
}


############################################################################
# compare ppp stats
#
# parameters:
# $1    Log file
# $2    Log prefix
function z055_hdlc_compare_ppp_stats {
    debug_print "${LogPrefix} z055_hdlc_compare_ppp_stats" "${LogFile}"
    echo ""
}
