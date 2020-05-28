#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z087_eth test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function z087_eth_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "-------------------Ip Core z087 Test Case----------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "    ETH interfaces should be plugged into network switch"
    echo "DESCRIPTION:"
    echo "    Load ip core driver and run simple test programs"
    echo "    1.Read list of available network interfaces"
    echo "    2.Load m-module drivers: modprobe men_lx_z77 phyadr=1,2"
    echo "    3.Read list of available network interfaces and note new ones"
    echo "    4.Configure routing table to put all traffic through new interface"
    echo "    5.Ping any working public host: ping 8.8.8.8"
    echo "    6.Go to 4. if there's any new interface left that has not been tested"
    echo "    7.Check the results - result log shall contain no errors or warnings"
    echo "PURPOSE:"
    echo "    Check if ip core z087 with men_lx_z77 driver is working"
    echo "    correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1280"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1460"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# IP core have to be tested on certain carrier, so user has to specify
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
function z087_eth_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}
    debug_print "${LogPrefix} z087 fixed on F614 - add support for other chameleon dev" "${LogFile}"
    eth_test "${LogFile}" "${LogPrefix}"
    return $?
}

############################################################################
# Test z087 ip core
# 
# parameters:
# $1    Log file
# $2    Log prefix
# $3    Mezzaine chameleon device description file
function eth_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local MezzChamDevDescriptionFile=${3}

    local TestError=${ERR_VALUE}
    local GwDefault
    local GwBlah
    local GwCurrent
    local GwIp
    local GwCount
    local GwSet
    local EthListBefore
    local EthListAfter
    local EthList

    GwDefault="$(ip route list | grep "^default" | head --lines=1)"
    debug_print "${LogPrefix} Default gateway: ${GwDefault}" "${LogFile}"
    GwCurrent=${GwDefault}
    if [[ "$GwCurrent" =~ ^.+[[:space:]]dev[[:space:]][a-zA-Z0-9]+(.*)$ ]]; then
        GwBlah="${BASH_REMATCH[1]}"
    fi
    GwIp="$(echo "${GwDefault}" | grep --perl-regexp --only-matching "via\s+[\d\.]+" | grep --perl-regexp --only-matching "[\d\.]+")"
    debug_print "${LogPrefix}  Default gateway IP address: ${GwIp}" "${LogFile}"

    EthListBefore="$(ifconfig -a | grep --perl-regexp --only-matching "^[\w\d]+")"
    debug_print "${LogPrefix} ETH interfaces before driver was loaded:\n${EthListBefore}" "${LogFile}"

    if ! run_as_root modprobe men_lx_z77 phyadr=1,2
    then
        debug_print "${LogPrefix}  ERR ${ERR_MODPROBE}:could not modprobe men_lx_z77" "${LogFile}"
        return "${ERR_MODPROBE}"
    fi

    EthListAfter="$(ifconfig -a | grep --perl-regexp --only-matching "^[\w\d]+")"
    debug_print "${LogPrefix} ETH interfaces after driver was loaded:\n${EthListAfter}" "${LogFile}"

    EthList="$(echo "${EthListBefore}" "${EthListAfter}" | sed 's/ /\n/g' | sort | uniq --unique)"
    debug_print "${LogPrefix} ETH interfaces to test:\n${EthList}" "${LogFile}"

    if [ "${EthList}" == "" ]; then
        TestError="${ERR_VALUE}"
        debug_print "${LogPrefix}  No ETH interfaces for test" "${LogFile}"
    else
        TestError="${ERR_OK}"
        debug_print "${LogPrefix}  Waiting for ETH interfaces to obtain IP address..." "${LogFile}"
        sleep 15
    fi

    GwCount="$(ip route list | grep "^default" | wc --lines)"
    for Index in $(seq 1 ${GwCount}); do
        GwSet="$(ip route list | grep "^default" | head --lines=1)"
        if [ "${GwSet}" != "" ]; then
            run_as_root ip route delete ${GwSet}
        fi
    done

    for Eth in ${EthList}; do
        GwSet="$(ip route list | grep "^default" | head --lines=1)"
        if [ "${GwIp}" != "" ]; then
            if [ "${GwSet}" != "" ]; then
                run_as_root ip route delete ${GwSet}
            fi
            GwCurrent="default via ${GwIp} dev ${Eth}${GwBlah}"
            debug_print "${LogPrefix}  Changing default gateway to: ${GwCurrent}" "${LogFile}"
            run_as_root ip route add ${GwCurrent}
            GwSet="$(ip route list | grep "^default" | head --lines=1)"
            debug_print "${LogPrefix} Default gateway is now: ${GwSet}" "${LogFile}"
        fi

        debug_print "Testing ping on ETH interface ${Eth}" "${LogFile}"
        ping -c "${PING_PACKET_COUNT}" -W "${PING_PACKET_TIMEOUT}" -I "${Eth}" "${PING_TEST_HOST}" | tee --append "${LogFile}" 2>&1
        if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            TestError="${ERR_VALUE}"
            debug_print "${LogPrefix} No ping reply on ETH interface ${Eth}" "${LogFile}"
        else
            debug_print "${LogPrefix} Ping on ETH interface ${Eth} OK" "${LogFile}"
        fi
    done

    GwSet="$(ip route list | grep "^default" | head --lines=1)"
    if [ "${GwSet}" != "" ] && [ "${GwDefault}" != "" ] && [ "${GwSet}" != "${GwDefault}" ]; then
        run_as_root ip route delete ${GwSet}
        debug_print "${LogPrefix}  Changing default gateway to: ${GwDefault}" "${LogFile}"
        run_as_root ip route add ${GwDefault}
        GwSet="$(ip route list | grep "^default" | head --lines=1)"
        debug_print "${LogPrefix}  Default gateway is now: ${GwSet}" "${LogFile}"
    fi

    return "${TestError}"
}
