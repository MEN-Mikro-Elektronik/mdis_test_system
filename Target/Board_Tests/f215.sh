#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/Ip_Core_Tests/z029_can.sh"
source "${MyDir}/Ip_Core_Tests/z034_z037_gpio.sh"

############################################################################
# board f215 test
#
# parameters:
# $1    Module number
# $2    Module log path 
function f215_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------F215 Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    f215_${ModuleNo}"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run board f215 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function f215_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    # Board in this Test Case always have
    VenID="0x1a88"   
    DevID="0x4d45"
    SubVenID="0x006a"
    BoardInSystem="1"
    InputToChange=${IN_0_ENABLE}

    while ${MachineRun}; do
        case "${MachineState}" in
        Step1);&
        Step2);&
        Step3);&
        Step4);&
        Step5)
            # Check if mcb_pci is already in blacklist, UART loopback test
            echo "${LogPrefix} Run step @5" | tee -a "${TestCaseLogName}" 2>&1
            echo "${MenPcPassword}" | sudo -S --prompt=$'\r' grep "blacklist mcb_pci" /etc/modprobe.d/blacklist.conf > /dev/null
            if [ $? -ne 0 ]; then
                # Add mcb_pci into blacklist
                echo "${MenPcPassword}" | sudo -S --prompt=$'\r' echo "# Add mcb_pci into blacklist" >> /etc/modprobe.d/blacklist.conf
                echo "${MenPcPassword}" | sudo -S --prompt=$'\r' echo "blacklist mcb_pci" >> /etc/modprobe.d/blacklist.conf
            else
                echo "${LogPrefix} blacklist mcb_pci found"
            fi
            UartNoList="UART_board_tty_numbers.txt"
            obtain_tty_number_list_from_board  "${TestCaseLogName}" "${VenID}" "${DevID}" "${SubVenID}" "${BoardInSystem}" "${UartNoList}" "${LogPrefix}"
            CmdResult=$?
            if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                echo "${LogPrefix} obtain_tty_number_list_from_board failed, err: ${CmdResult} "\
                 | tee -a "${TestCaseLogName}" 2>&1
                return "${CmdResult}"
            fi

            uart_loopback_test "${TestCaseLogName}" "${LogPrefix} "${UartNoList}"
            CmdResult=$?
            if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                echo "${LogPrefix} uart_test_board err: ${CmdResult} "\
                  | tee -a "${TestCaseLogName}" 2>&1
            else
                echo "${LogPrefix} uart_test_board success "\
                  | tee -a "${TestCaseLogName}" 2>&1
            fi
            TestCaseStep5=${CmdResult}
            MachineState="Step6"
            ;;
        Step6)
            # Can test
            echo "${LogPrefix} Run step @6" | tee -a "${TestCaseLogName}" 2>&1
            # Run step @8 Test CAN interfaces, there should be 2 cans available
            MezzChamDevName="MezzChamDevName.txt"
            obtain_device_list_chameleon_device "${VenID}" "${DevID}" "${SubVenID}" "${MezzChamDevName}" "${BoardInSystem}" "${TestCaseLogName}" "${LogPrefix}"
            can_test_ll_z15 "${TestCaseLogName}" "${LogPrefix}" "${MezzChamDevName}"
            CmdResult=$?
            if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                echo "${LogPrefix} can_test_ll_z15 err: ${CmdResult} "\
                  | tee -a "${TestCaseLogName}" 2>&1
            else
                echo "${LogPrefix} can_test_ll_z15 success "\
                  | tee -a "${TestCaseLogName}" 2>&1
            fi
            TestCaseStep6=${CmdResult}
            MachineState="Step7"
            ;;
        Step7)
            # Test GPIO / LEDS 
            echo "${LogPrefix} Run step @7" | tee -a "${TestCaseLogName}" 2>&1
            z034_z037_gpio_test "${TestCaseLogName}" "${MezzChamDevName}" "${LogPrefix}" "${InputToChange}" 
            CmdResult=$?
            if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                     echo "${LogPrefix} gpio_test on ${GPIO2} err: ${CmdResult} "\
                       | tee -a "${TestCaseLogName}" 2>&1
            else
                     echo "${LogPrefix} gpio_test on ${GPIO2} success "\
                       | tee -a "${TestCaseLogName}" 2>&1
            fi
            TestCaseStep7=${CmdResult}
#            TestCaseStep7="${ERR_OK}"
            MachineState="Break"
            ;;
        Break) 
            # Clean after Test Case
            echo "${LogPrefix} Break State" | tee --a "${TestCaseLogName}"
            MachineRun=false
            ;;
        *)
            echo "${LogPrefix} State is not set, start with Step1" | tee -a "${TestCaseLogName}"
            MachineState="Step1"
            ;;
        esac
    done
}
