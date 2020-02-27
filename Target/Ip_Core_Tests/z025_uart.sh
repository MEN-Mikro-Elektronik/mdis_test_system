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
}

function z025_uart_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local MezzChamTable=${3}

    return "${CmdResult}"
}


function load_z025_driver {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local CmdResult=${ERR_UNDEFINED}

    echo "${LogPrefix} modprobe men_mdis_kernel" | tee -a "${TestCaseLogName}" 2>&1
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_mdis_kernel
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} ERR_MODPROBE :could not modprobe men_mdis_kernel"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_MODPROBE}"
    fi

    echo "${LogPrefix} modprobe men_lx_z25 baud_base=1843200 mode=se,se"\
        | tee -a "${TestCaseLogName}" 2>&1
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_lx_z25 baud_base=1843200 mode=se,se
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} ERR_MODPROBE :could not modprobe men_lx_z25 baud_base=1843200 mode=se,se"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_MODPROBE}"
    fi

    return "${ERR_OK}"
}

function unload_z025_driver {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    ## DEBIAN workaround -- on DEBIAN chameleon table disapears when module men_lx_z25 is loaded
    ## rmmod men_lx_z25 for a while. (it must be loaded to set proper uart mmmio address)
    local IsDebian="$(hostnamectl | grep "Operating System" | grep "Debian" | wc -l)"
    echo "${LogPrefix} IsDebian: ${IsDebian}" | tee -a "${TestCaseLogName}" 2>&1
    if [ "${IsDebian}" == "1" ]; then
        echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rmmod men_lx_z25
    fi
}
############################################################################
# Test RS232 with men_lx_z25 IpCore 
# 
#
# parameters:
# $1      name of file with log 
# $2      array of ttyS that should be tested
function uart_test_lx_z25 {
    local LogFileName=${1}
    local LogPrefix=${2}
    local UartNoList=${3}

    FILE="${UartNoList}"
    if [ -f ${FILE} ]; then
            echo "${LogPrefix} file: \"${FILE}\" exists"\
              | tee -a "${LogFileName}" 2>&1
            TtyDeviceCnt=$(cat ${FILE} | wc -l)

            for i in $(seq 1 ${TtyDeviceCnt}); do
                    Arr[${i}]=$(cat ${FILE} | awk NR==${i}'{print $1}')
                    echo "${LogPrefix} read from file: ${Arr[${i}]}"
            done
    else
            echo "${LogPrefix} file UART_board_tty_numbers does not exists"\
              | tee -a "${LogFileName}" 2>&1
            return "${ERR_NOEXIST}"
    fi

    local tty0="ttyS$(cat ${FILE} | awk NR==1'{print $1}')"
    local tty1="ttyS$(cat ${FILE} | awk NR==2'{print $1}')"

    uart_test_tty "${tty1}" "${tty0}" "${LogPrefix}" "${LogFileName}"
    if [ $? -ne 0 ]; then
            echo "${LogPrefix}  ERR_VALUE: ${tty1} with ${tty0}" | tee -a "${LogFileName}"
            return "${ERR_VALUE}"
    fi

    sleep 1
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rmmod men_lx_z25 
    if [ $? -ne 0 ]; then
            echo "${LogPrefix}  ERR_VALUE: could not rmmod m" | tee -a "${LogFileName}"
            return "${ERR_VALUE}"
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_lx_z25 baud_base=1843200 mode=se,se
    if [ $? -ne 0 ]; then
            echo "${LogPrefix}  ERR_VALUE: could not  modprobe men_lx_z25 baud_base=1843200 mode=se,se"\
              | tee -a "${LogFileName}"
            return "${ERR_VALUE}"
    fi
    sleep 1

    uart_test_tty "${tty0}" "${tty1}" "${LogPrefix}" "${LogFileName}"
    if [ $? -ne 0 ]; then
            echo "${LogPrefix}  ERR_VALUE: ${tty0} with ${tty1}" | tee -a "${LogFileName}"
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
    #                  | tee -a ${LogFileName} 2>&1
    #        fi
    #        sleep 2
    #        # Below command prevent infitite loopback on serial port 
    #        echo ${MenPcPassword} | sudo -S --prompt=$'\r' stty -F /dev/ttyS${item} -echo -onlcr
    #        if [ $? -ne 0 ]; then
    #                echo "${LogPrefix} Could not stty -F on ttyS${item}"\
    #                  | tee -a ${LogFileName} 2>&1
    #        fi
    #        sleep 2
    #        # Listen on port in background
    #        echo ${MenPcPassword} | sudo -S --prompt=$'\r' cat /dev/ttyS${item}\
    #          > echo_on_serial_S${item}.txt &
    #        
    #        if [ $? -ne 0 ]; then
    #                echo "${LogPrefix} Could not cat on ttyS${item} in background"\
    #                  | tee -a ${LogFileName} 2>&1
    #        fi
    #        sleep 2 
    #        # Save background process PID 
    #        CatEchoTestPID=$!
    #        # Send data into port
    #        echo ${MenPcPassword} | sudo -S --prompt=$'\r' echo ${EchoTestMessage} > /dev/ttyS${item}
    #        if [ $? -ne 0 ]; then
    #                echo "${LogPrefix} Could not echo on ttyS${item}"\
    #                  | tee -a ${LogFileName} 2>&1
    #        fi
    #        # Kill process
    #        sleep 2 
    #        echo ${MenPcPassword} | sudo -S --prompt=$'\r' kill -9 ${CatEchoTestPID}
    #        if [ $? -ne 0 ]; then
    #                echo "${LogPrefix} Could not kill cat backgroung process ${CatEchoTestPID} on ttyS${item}"\
    #                  | tee -a ${LogFileName} 2>&1
    #        fi
    #        # Compare and check if echo test message was received.
    #        sleep 1 
    #        grep -a "${EchoTestMessage}" echo_on_serial_S${item}.txt
    #        if [ $? -eq 0 ]; then
    #                echo "${LogPrefix} Echo succeed on ttyS${item}"\
    #                  | tee -a ${LogFileName} 2>&1
    #        else
    #                echo "${LogPrefix} Echo failed on ttyS${item}"\
    #                  | tee -a ${LogFileName} 2>&1
    #                return ${ERR_VALUE}
    #        fi
    #
    #        #rm echo_on_serial_S${item}.txt
    #done
}
