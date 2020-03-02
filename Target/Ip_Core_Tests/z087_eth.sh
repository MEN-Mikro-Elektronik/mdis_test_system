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
}

############################################################################
# IP core have to be tested on certain carrier, so user has to specify
# exact location of ip core in the system
#
# parameters:
# $1    Test case log name
# $2    Log prefix
# $3    Board vendor id
# $4    Board device id
# $5    Board subvendor id
# $6    Board number in system
# $7    Optional parameter - test type (optional)
function z087_eth_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}
    echo "${LogPrefix} z087 fixed on F614 - add support for other chameleon dev"
    eth_test "${TestCaseLogName}" "${LogPrefix}"
    return $?
}

function eth_test {
    local LogFileName=${1}
    local LogPrefix=${2}
    local MezzChamDevDescriptionFile=${3}

    local TestError=${ERR_VALUE}
    local GwDefault=
    local GwCurrent=
    local GwIp=
    local GwCount=
    local GwSet=
    local EthListBefore=
    local EthListAfter=
    local EthList=

    GwDefault="$(ip route list | grep "^default" | head --lines=1)"
    echo "${LogPrefix} Default gateway: ${GwDefault}" | tee --append "${LogFileName}"
    GwCurrent=${GwDefault}
    GwIp="$(echo "${GwDefault}" | grep --perl-regexp --only-matching "via\s+[\d\.]+" | grep --perl-regexp --only-matching "[\d\.]+")"
    echo "${LogPrefix}  Default gateway IP address: ${GwIp}" | tee --append "${LogFileName}"

    EthListBefore="$(ifconfig -a | grep --perl-regexp --only-matching "^[\w\d]+")"
    echo -e "${LogPrefix} ETH interfaces before driver was loaded:\n${EthListBefore}" | tee --append "${LogFileName}"

    if ! echo "${MenPcPassword}" | sudo --stdin --prompt=$'\r' modprobe men_lx_z77 phyadr=1,2
    then
        echo "${LogPrefix}  ERR ${ERR_MODPROBE}:could not modprobe men_lx_z77" | tee --append "${LogFileName}"
        return "${ERR_MODPROBE}"
    fi

    EthListAfter="$(ifconfig -a | grep --perl-regexp --only-matching "^[\w\d]+")"
    echo -e "${LogPrefix} ETH interfaces after driver was loaded:\n${EthListAfter}" | tee --append "${LogFileName}"

    EthList="$(echo "${EthListBefore}" "${EthListAfter}" | sed 's/ /\n/g' | sort | uniq --unique)"
    echo -e "${LogPrefix} ETH interfaces to test:\n${EthList}" | tee --append "${LogFileName}"

    if [ "${EthList}" == "" ]; then
        TestError="${ERR_VALUE}"
        echo "${LogPrefix}  No ETH interfaces for test" | tee --append "${LogFileName}"
    else
        TestError="${ERR_OK}"
        echo "${LogPrefix}  Waiting for ETH interfaces to obtain IP address..." | tee --append "${LogFileName}"
        sleep 15
    fi

    GwCount="$(ip route list | grep "^default" | wc --lines)"
    for Index in $(seq 1 ${GwCount}); do
        GwSet="$(ip route list | grep "^default" | head --lines=1)"
        if [ "${GwSet}" != "" ]; then
            echo "${MenPcPassword}" | sudo --stdin --prompt=$'\r' ip route delete ${GwSet}
        fi
    done

    for Eth in ${EthList}; do
        GwSet="$(ip route list | grep "^default" | head --lines=1)"
        if [ "${GwIp}" != "" ]; then
            if [ "${GwSet}" != "" ]; then
                echo "${MenPcPassword}" | sudo --stdin --prompt=$'\r' ip route delete ${GwSet}
            fi
            GwCurrent="default via ${GwIp} dev ${Eth}"
            echo "${LogPrefix}  Changing default gateway to: ${GwCurrent}" | tee --append "${LogFileName}"
            echo "${MenPcPassword}" | sudo --stdin --prompt=$'\r' ip route add ${GwCurrent}
            GwSet="$(ip route list | grep "^default" | head --lines=1)"
            echo "${LogPrefix} Default gateway is now: ${GwSet}" | tee --append "${LogFileName}"
        fi

        echo "Testing ping on ETH interface ${Eth}" | tee --append "${LogFileName}"
        ping -c "${PingPacketCount}" -W "${PingPacketTimeout}" -I "${Eth}" "${PingTestHost}" | tee --append "${LogFileName}" 2>&1
        if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            TestError="${ERR_VALUE}"
            echo "${LogPrefix} No ping reply on ETH interface ${Eth}" | tee --append "${LogFileName}"
        else
            echo "${LogPrefix} Ping on ETH interface ${Eth} OK" | tee --append "${LogFileName}"
        fi
    done

    GwSet="$(ip route list | grep "^default" | head --lines=1)"
    if [ "${GwSet}" != "" ] && [ "${GwDefault}" != "" ] && [ "${GwSet}" != "${GwDefault}" ]; then
        echo "${MenPcPassword}" | sudo --stdin --prompt=$'\r' ip route delete ${GwSet}
        echo "${LogPrefix}  Changing default gateway to: ${GwDefault}" | tee --append "${LogFileName}"
        echo "${MenPcPassword}" | sudo --stdin --prompt=$'\r' ip route add ${GwDefault}
        GwSet="$(ip route list | grep "^default" | head --lines=1)"
        echo "${LogPrefix}  Default gateway is now: ${GwSet}" | tee --append "${LogFileName}"
    fi

    return "${TestError}"
}
