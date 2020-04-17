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
function z025_uart_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "---------------------------Ip Core z025 UART----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "    If there are 2 UARTs on board then they shall be connected with each other"
    echo "DESCRIPTION:"
    echo "    1.Read chameleon table from board"
    echo "    2.Load m-module drivers: modprobe men_mdis_kernel, men_lx_z25"
    echo "    3.Find UART devices on board"
    echo "    4.If 2 UART interfaces are available on board perform loopback test"
    echo "    5.Check if both UART interfaces send and received data properly"
    echo "PURPOSE:"
    echo "    Check if ip core z025 with men_mdis_kernel men_lx_z25 drivers is working"
    echo "    correctly"
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
function z025_uart_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local UartNo=${7} 
    local UartNoList="UART_board_tty_numbers.txt"
    local ChamTableDumpFile="Chameleon_table_${VenID}_${DevID}_${SubVenID}_${BoardInSystem}.log"

    # Debian workaround. Could not dump chameleon table when
    # men_lx_z25 is loaded
    unload_z025_driver "${LogFile}" "${LogPrefix}"
    obtain_chameleon_table "${VenID}" "${DevID}" "${SubVenID}" "${ChamTableDumpFile}" "${BoardInSystem}" "${LogFile}" "${LogPrefix}"
    load_z025_driver "${LogFile}" "${LogPrefix}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        debug_print "${LogPrefix} load_z025_driver failed, err: ${CmdResult}" "${LogFile}"
        return "${CmdResult}"
    fi


    if ! obtain_tty_number_list_from_board "${LogFile}" "${ChamTableDumpFile}" "${UartNoList}" "${LogPrefix}"
    then
        debug_print "${LogPrefix} obtain_tty_number_list_from_board failed, err: ${CmdResult}" "${LogFile}"
        return "${CmdResult}"
    fi

    uart_test_lx_z25 "${LogFile}" "${LogPrefix}" "${UartNoList}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        debug_print "${LogPrefix} uart_test_lx_z25 failed, err: ${CmdResult}" "${LogFile}"
    fi

    return "${CmdResult}"
}

############################################################################
# Load men_lx_z25 driver
#
# parameters:
# $1    Log file
# $2    Log prefix
function load_z025_driver {
    local LogFile=${1}
    local LogPrefix=${2}
    local CmdResult=${ERR_UNDEFINED}

    debug_print "${LogPrefix} modprobe men_mdis_kernel" "${LogFile}"

    if ! run_as_root modprobe men_mdis_kernel
    then
        debug_print "${LogPrefix} ERR_MODPROBE :could not modprobe men_mdis_kernel" "${LogFile}"
        return "${ERR_MODPROBE}"
    fi

    debug_print "${LogPrefix} modprobe men_lx_z25 baud_base=1843200 mode=se,se" "${LogFile}"

    if ! run_as_root modprobe men_lx_z25 baud_base=1843200 mode=se,se
    then
        debug_print "${LogPrefix} ERR_MODPROBE :could not modprobe men_lx_z25 baud_base=1843200 mode=se,se" "${LogFile}"
        return "${ERR_MODPROBE}"
    fi

    return "${ERR_OK}"
}

############################################################################
# Unload men_lx_z25 driver
#
# parameters:
# $1    Log file
# $2    Log prefix
function unload_z025_driver {
    local LogFile=${1}
    local LogPrefix=${2}
    ## DEBIAN workaround -- on DEBIAN chameleon table disapears when module men_lx_z25 is loaded
    ## rmmod men_lx_z25 for a while. (it must be loaded to set proper uart mmmio address)
    local IsDebian
    IsDebian="$(hostnamectl | grep "Operating System" | grep -c "Debian")"
    debug_print "${LogPrefix} IsDebian: ${IsDebian}" "${LogFile}"
    if [ "${IsDebian}" == "1" ]; then
        run_as_root rmmod men_lx_z25
    fi
}
############################################################################
# Test RS232 with men_lx_z25 IpCore 
# 
# parameters:
# $1    Log file
# $2    Log prefix
# $3    List of UART devices
function uart_test_lx_z25 {
    local LogFile=${1}
    local LogPrefix=${2}
    local UartNoList=${3}

    FILE="${UartNoList}"
    if [ -f ${FILE} ]; then
        debug_print "${LogPrefix} file: \"${FILE}\" exists" "${LogFile}"
        TtyDeviceCnt=$(< "${FILE}" wc -l)

        for i in $(seq 1 ${TtyDeviceCnt}); do
            Arr[${i}]=$(< "${FILE}" awk NR==${i}'{print $1}')
            debug_print "${LogPrefix} read from file: ${Arr[${i}]}" "${LogFile}"
        done
    else
        debug_print "${LogPrefix} file UART_board_tty_numbers does not exists" "${LogFile}"
        return "${ERR_NOEXIST}"
    fi

    local tty0
    local tty1
    tty0="ttyS$(< ${FILE} awk NR==1'{print $1}')"
    tty1="ttyS$(< ${FILE} awk NR==2'{print $1}')"

    if ! uart_test_tty "${tty1}" "${tty0}" "${LogPrefix}" "${LogFile}"
    then
        debug_print "${LogPrefix}  ERR_VALUE: ${tty1} with ${tty0}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    sleep 1
    if ! run_as_root rmmod men_lx_z25
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not rmmod m" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if ! run_as_root modprobe men_lx_z25 baud_base=1843200 mode=se,se
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not  modprobe men_lx_z25 baud_base=1843200 mode=se,se" "${LogFile}"
        return "${ERR_VALUE}"
    fi
    sleep 1

    if ! uart_test_tty "${tty0}" "${tty1}" "${LogPrefix}" "${LogFile}"
    then
        debug_print "${LogPrefix}  ERR_VALUE: ${tty0} with ${tty1}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"

    # Linux kernel bug 
    # https://bugs.launchpad.net/ubuntu/+source/linux-signed-hwe/+bug/1815021
    #
    #for item in "${Arr[@]}"; do 
    #        # Conditions must be met: i2c-i801 is loaded, mcb_pci is disabled
    #        echo ${MenPcPassword} | sudo -S --prompt=$'\r' chmod o+rw /dev/ttyS${item}
    #        if [ $? -ne 0 ]; then
    #                echo "${LogPrefix} Could not chmod o+rw on ttyS${item}"\
    #                  | tee -a ${LogFile} 2>&1
    #        fi
    #        sleep 2
    #        # Below command prevent infitite loopback on serial port 
    #        echo ${MenPcPassword} | sudo -S --prompt=$'\r' stty -F /dev/ttyS${item} -echo -onlcr
    #        if [ $? -ne 0 ]; then
    #                echo "${LogPrefix} Could not stty -F on ttyS${item}"\
    #                  | tee -a ${LogFile} 2>&1
    #        fi
    #        sleep 2
    #        # Listen on port in background
    #        echo ${MenPcPassword} | sudo -S --prompt=$'\r' cat /dev/ttyS${item}\
    #          > echo_on_serial_S${item}.txt &
    #        
    #        if [ $? -ne 0 ]; then
    #                echo "${LogPrefix} Could not cat on ttyS${item} in background"\
    #                  | tee -a ${LogFile} 2>&1
    #        fi
    #        sleep 2 
    #        # Save background process PID 
    #        CatEchoTestPID=$!
    #        # Send data into port
    #        echo ${MenPcPassword} | sudo -S --prompt=$'\r' echo ${EchoTestMessage} > /dev/ttyS${item}
    #        if [ $? -ne 0 ]; then
    #                echo "${LogPrefix} Could not echo on ttyS${item}"\
    #                  | tee -a ${LogFile} 2>&1
    #        fi
    #        # Kill process
    #        sleep 2 
    #        echo ${MenPcPassword} | sudo -S --prompt=$'\r' kill -9 ${CatEchoTestPID}
    #        if [ $? -ne 0 ]; then
    #                echo "${LogPrefix} Could not kill cat backgroung process ${CatEchoTestPID} on ttyS${item}"\
    #                  | tee -a ${LogFile} 2>&1
    #        fi
    #        # Compare and check if echo test message was received.
    #        sleep 1 
    #        grep -a "${EchoTestMessage}" echo_on_serial_S${item}.txt
    #        if [ $? -eq 0 ]; then
    #                echo "${LogPrefix} Echo succeed on ttyS${item}"\
    #                  | tee -a ${LogFile} 2>&1
    #        else
    #                echo "${LogPrefix} Echo failed on ttyS${item}"\
    #                  | tee -a ${LogFile} 2>&1
    #                return ${ERR_VALUE}
    #        fi
    #
    #        #rm echo_on_serial_S${item}.txt
    #done
}
