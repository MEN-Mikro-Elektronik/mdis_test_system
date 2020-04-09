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
function m72_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M77 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    1.Load mdis kernel driver: modprobe men_mdis_kernel"
    echo "    2.Create mdis device: mdis_createdev -b ..."
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
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    echo "m77_Test"

}


############################################################################
# run m77 test 
# 
# parameters:
# $1    Test case log file name
# $2    Test case name
# $3    M77 board number
# $4    Carrier board number
function m_module_m77_test {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    local M77Nr=${3}
    local M77CarrierName="d203_a24_${4}" # obtain from system.dsc (only G204)
    local LogPrefix="[m77_test]"

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_mdis_kernel
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_mdis_kernel"\
          | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' mdis_createdev -b "${M77CarrierName}"
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  ERR_VALUE: could not mdis_createdev -b ${M77CarrierName}"\
          | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_lx_m77 devName=m77_${M77Nr} brdName=${M77CarrierName} slotNo=0 mode=7,7,7,7
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_lx_m77 devName=m77_${M77Nr} brdName=${M77CarrierName} slotNo=0 mode=7,7,7,7"\
          | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi
    local tty0="ttyD0"
    local tty1="ttyD1"
    local tty2="ttyD2"
    local tty3="ttyD3"

    if ! uart_test_tty "${tty0}" "${tty1}"
    then
        echo "${LogPrefix}  ERR_VALUE: ${tty0} with ${tty1}" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    if ! uart_test_tty "${tty3}" "${tty2}"
    then
        echo "${LogPrefix}  ERR_VALUE: ${tty3} with ${tty2}" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    sleep 2 
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rmmod men_lx_m77 
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  ERR_VALUE: could not rmmod m" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_lx_m77 devName=m77_${M77Nr} brdName=${M77CarrierName} slotNo=0 mode=7,7,7,7
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_lx_m77 devName=m77_${M77Nr} brdName=${M77CarrierName} slotNo=0 mode=7,7,7,7"\
          | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    if ! uart_test_tty "${tty1}" "${tty0}"
    then
        echo "${LogPrefix}  ERR_VALUE: ${tty1} with ${tty0}" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    if ! uart_test_tty "${tty2}" "${tty3}"
    then
        echo "${LogPrefix}  ERR_VALUE: ${tty2} with ${tty3}" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}

