#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m77 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m77_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M77 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load mdis kernel driver: modprobe men_mdis_kernel"
    echo "    2.Create mdis device: mdis_createdev -b <carrier>"
    echo "    3.Load m-module drivers: modprobe men_lx_m77 ..."
    echo "    4.Set proper port file mode: chmod o+rw \"/dev/ttyD0\""
    echo "    5.Prevent infitite loopback on serial port: stty -F \"/dev/ttyD0\""
    echo "    6.Listen on port: cat \"/dev/ttyD1\""
    echo "    7.Send data to port: echo \"test message\" > \"/dev/ttyD0\""
    echo "    8.Verify if test message appears on port /dev/ttyD1"
    echo "PURPOSE:"
    echo "    Check if M-module m77 is working correctly"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m77 test 
# 
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m77_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    
    local M77CarrierName=""
    # obtain from system.dsc
    M77CarrierName=$(obtain_m_module_carrier_name  "m77_${ModuleNo}") 

    if [ -z "${M77CarrierName}" ]
    then
        debug_print "${LogPrefix} ERR_VALUE: could not find m77 board in system" "${LogFile}"
        return "${ERR_VALUE}"
    else
        debug_print "${LogPrefix} M77 CarrierName: ${M77CarrierName}" "${LogFile}"
        # Check if this is G204 or F205
        local IsCarrierG204="0"
        IsCarrierG204=$(echo "${M77CarrierName}" | grep -c "d203")
        if [ "${IsCarrierG204}" -gt 0 ]
        then
            debug_print "${LogPrefix} m77 @ G204" "${LogFile}"
        else
            debug_print "${LogPrefix} m77 @ F205" "${LogFile}"
        fi
    fi

    if ! run_as_root modprobe men_mdis_kernel
    then
        debug_print "${LogPrefix} ERR_VALUE: could not modprobe men_mdis_kernel" "${LogFile}"
        return "${ERR_VALUE}"
    fi
    
    if ! run_as_root mdis_createdev -b "${M77CarrierName}" > /dev/null
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not mdis_createdev -b ${M77CarrierName}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if ! run_as_root modprobe men_lx_m77 devName=m77_"${ModuleNo}" brdName="${M77CarrierName}" slotNo=0 mode=7,7,7,7
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_lx_m77 devName=m77_${ModuleNo} brdName=${M77CarrierName} slotNo=0 mode=7,7,7,7" "${LogFile}"
        return "${ERR_VALUE}"
    fi
    local tty0="ttyD0"
    local tty1="ttyD1"
    local tty2="ttyD2"
    local tty3="ttyD3"

    if ! uart_test_tty "${tty0}" "${tty1}" "${LogPrefix}" "${LogFile}"
    then
        debug_print "${LogPrefix}  ERR_VALUE: ${tty0} with ${tty1}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if ! uart_test_tty "${tty3}" "${tty2}" "${LogPrefix}" "${LogFile}"
    then
        debug_print "${LogPrefix}  ERR_VALUE: ${tty3} with ${tty2}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    sleep 2 
    if ! run_as_root rmmod men_lx_m77
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not rmmod m" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if ! run_as_root modprobe men_lx_m77 devName=m77_"${ModuleNo}" brdName="${M77CarrierName}" slotNo=0 mode=7,7,7,7
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_lx_m77 devName=m77_${ModuleNo} brdName=${M77CarrierName} slotNo=0 mode=7,7,7,7" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if ! uart_test_tty "${tty1}" "${tty0}" "${LogPrefix}" "${LogFile}"
    then
        debug_print "${LogPrefix}  ERR_VALUE: ${tty1} with ${tty0}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if ! uart_test_tty "${tty2}" "${tty3}" "${LogPrefix}" "${LogFile}"
    then
        debug_print "${LogPrefix}  ERR_VALUE: ${tty2} with ${tty3}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
