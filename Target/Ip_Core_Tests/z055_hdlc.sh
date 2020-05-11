#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z055_uart test description
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
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1185"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1445"
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

    local StartScript="${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}/13Z055-90/DRIVERS/Z055_HDLC/start-ppp-two-ports.sh"
    local StopScript="${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}/13Z055-90/DRIVERS/Z055_HDLC/stop-ppp.sh"
    local UnloadDrv="${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}/13Z055-90/DRIVERS/Z055_HDLC/unload-drivers.sh"

    debug_print "${LogPrefix} Add proper .mak into main Makefile" "${LogFile}"
    z055_hdlc_mak_fix "${LogFile}" "${LogPrefix}"
    debug_print "${LogPrefix} z055_hdlc_mak_fix applied, move on.." "${LogFile}"

    # establish ppp connection between Z055_HDLC interfaces
    if ! run_as_root "${StartScript}" > /dev/null 2>&1
    then
        debug_print "${LogPrefix} Could not run start-ppp-two-ports.sh" "${LogFile}"
    fi

    sleep 5
    # ping response is not required
    debug_print "${LogPrefix} ping ppp0 -c 20 -i 0.05 -s 1400 8.8.8.8" "${LogFile}"
    run_as_root ping -I ppp0 -c 20 -i 0.05 -s 1400 8.8.8.8 > /dev/null
    debug_print "${LogPrefix} ping -I ppp1 -c 10 -i 0.1 -s 1400 8.8.8.8" "${LogFile}"
    run_as_root ping -I ppp1 -c 10 -i 0.1 -s 1400 8.8.8.8 > /dev/null

    # ping response is not required
    debug_print "${LogPrefix} ping -I ppp0 -c 16 -i 0.3 -s 65000 8.8.8.8" "${LogFile}"
    run_as_root ping -I ppp0 -c 16 -i 0.3 -s 65000 8.8.8.8 > /dev/null
    debug_print "${LogPrefix} ping -I ppp1 -c 16 -i 0.3 -s 65000 8.8.8.8" "${LogFile}"
    run_as_root ping -I ppp1 -c 17 -i 0.3 -s 65000 8.8.8.8 > /dev/null

    sleep 2
    # compare ifconfig stats for ppp0 and ppp1
    z055_hdlc_compare_ppp_stats
    Result=$?

    # stop ppp connectiona
    if ! run_as_root "${StopScript}" > /dev/null
    then
        debug_print "${LogPrefix}stop-ppp failed" "${LogFile}"
    fi

    # wait to close ppp connection
    sleep 5

    # unload z055_hdlc driver
    if ! run_as_root "${UnloadDrv}" > /dev/null
    then
        LoadedZ055=$(lsmod | grep -c "men_lx_z055")
        if [ "${LoadedZ055}" -gt "0" ]; then 
            debug_print "${LogPrefix} unload-drivers failed" "${LogFile}"
        fi
    fi

    return ${Result}
}

############################################################################
# compare ppp stats
#
# parameters:
# $1    Log file
# $2    Log prefix
function z055_hdlc_compare_ppp_stats {
    debug_print "${LogPrefix} z055_hdlc_compare_ppp_stats" "${LogFile}"
    local BytesTXPPP0="0"
    local BytesRXPPP0="0"
    local BytesTXPPP1="0"
    local BytesRXPPP1="0"
    local ErrorTXPPP0="0"
    local ErrorRXPPP0="0"
    local ErrorTXPPP1="0"
    local ErrorRXPPP1="0"

    ifconfig ppp0 > ppp0.log
    ifconfig ppp1 > ppp1.log

    BytesTXPPP0=$(ifconfig ppp0 | grep "TX packets" | awk '{print $5}')
    BytesTXPPP1=$(ifconfig ppp1 | grep "TX packets" | awk '{print $5}')
    BytesRXPPP0=$(ifconfig ppp0 | grep "RX packets" | awk '{print $5}')
    BytesRXPPP1=$(ifconfig ppp1 | grep "RX packets" | awk '{print $5}')

    ErrorTXPPP0=$(ifconfig ppp0 | grep "TX errors" | awk '{print $3}')
    ErrorRXPPP0=$(ifconfig ppp0 | grep "RX errors" | awk '{print $3}')
    ErrorTXPPP1=$(ifconfig ppp1 | grep "TX errors" | awk '{print $3}')
    ErrorRXPPP1=$(ifconfig ppp1 | grep "RX errors" | awk '{print $3}')

    debug_print "${LogPrefix} BytesTXPPP0: ${BytesTXPPP0}" "${LogFile}"
    debug_print "${LogPrefix} BytesTXPPP1: ${BytesTXPPP1}" "${LogFile}"
    debug_print "${LogPrefix} BytesRXPPP0: ${BytesRXPPP0}" "${LogFile}"
    debug_print "${LogPrefix} BytesRXPPP1: ${BytesRXPPP1}" "${LogFile}"

    debug_print "${LogPrefix} ErrorTXPPP0: ${ErrorTXPPP0}" "${LogFile}"
    debug_print "${LogPrefix} ErrorRXPPP0: ${ErrorRXPPP0}" "${LogFile}"
    debug_print "${LogPrefix} ErrorTXPPP1: ${ErrorTXPPP1}" "${LogFile}"
    debug_print "${LogPrefix} ErrorRXPPP1: ${ErrorRXPPP1}" "${LogFile}"

    if [ "${BytesTXPPP0}" -lt "1000000" ] || [ "${BytesTXPPP1}" -lt "1000000" ]
    then
        debug_print "${LogPrefix} No enought bytes transmitted..." "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if [ "${BytesTXPPP0}" = "${BytesRXPPP1}" ] &&
       [ "${BytesTXPPP1}" = "${BytesRXPPP0}" ] &&
       [ "${ErrorTXPPP0}" = "0" ] &&
       [ "${ErrorRXPPP0}" = "0" ] &&
       [ "${ErrorTXPPP1}" = "0" ] &&
       [ "${ErrorRXPPP1}" = "0" ]
    then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

############################################################################
# Add required .mak into Makefile
#
# parameters:
function z055_hdlc_mak_fix {
    local LogFile=${1}
    local LogPrefix=${2}
    local CurrentPath=$PWD

    debug_print "${LogPrefix} z055_hdlc_mak_fix" "${LogFile}"
    debug_print "${LogPrefix} Current Path:" "${LogFile}"
    debug_print "${CurrentPath}" "${LogFile}"

    cd ../.. || exit "${ERR_NOEXIST}"
    Z055_NATIVE_DRIVER="DRIVERS/Z055_HDLC/DRIVER/driver.mak"
    Z055_NATIVE_TOOL="DRIVERS/Z055_HDLC/TOOLS/Z055_HDLC_UTIL/program.mak"

    NativeDriverCnt=$(grep -c 'ALL_NATIVE_DRIVERS = \\' Makefile)
    if [ "${NativeDriverCnt}" -eq "0" ]
    then
        sed -i 's/'"ALL_NATIVE_DRIVERS =.*"'/& \\/' Makefile
        sed -i '/'"ALL_NATIVE_DRIVERS =.*"'/a '"\    \ ${Z055_NATIVE_DRIVER} \\\\"'' Makefile
    elif [ "${NativeDriverCnt}" -eq "1" ]
    then
        sed -i '/'"ALL_NATIVE_DRIVERS =.*"'/a '"\    \ ${Z055_NATIVE_DRIVER} \\\\"'' Makefile
    fi

    NativeToolCnt=$(grep -c 'ALL_NATIVE_TOOLS = \\' Makefile)
    if [ "${NativeToolCnt}" -eq "0" ]
    then
        sed -i 's/'"ALL_NATIVE_TOOLS =.*"'/& \\/' Makefile
        sed -i '/'"ALL_NATIVE_TOOLS =.*"'/a '"\    \ ${Z055_NATIVE_TOOL}"'' Makefile
    elif [ "${NativeToolCnt}" -eq "1" ]
    then
        sed -i '/'"ALL_NATIVE_DRIVERS =.*"'/a '"\    \ ${Z055_NATIVE_TOOL} \\\\"'' Makefile
    fi

    make_install "${LogPrefix}"
    cd "${CurrentPath}" || exit "${ERR_NOEXIST}"
}
