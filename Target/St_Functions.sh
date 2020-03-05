#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/../Common/Conf.sh
source "${MyDir}"/Mdis_Functions.sh
source "${MyDir}"/Relay_Functions.sh

# This script contains all common functions that are used by test cases


function run_test_case {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    if [ "${TEST_CASES_MAP[${TestCaseId}]+_}" ]; then
        run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "${TEST_CASES_MAP[${TestCaseId}]}"
    else
        echo "Test case not found"
    fi
}

### @brief Run command as root
### @param $@ Command to run, command arguments
function run_as_root {
    if [ "${#}" -gt "0" ]; then
        echo "${MenPcPassword}" | sudo -S --prompt=$'\r' -- "${@}"
    fi
}

function print {
    local Msg="${1}"
    local LogFile="${2}"
    echo "${Msg}" | tee -a "${LogFile}" 2>&1
}

function debug_print {
    local Msg="${1}"
    local LogFile="${2}"
    if [ "${VERBOSE_LEVEL}" -ge "1" ]; then
        echo "${Msg}" | tee -a "${LogFile}" 2>&1
    fi
}

function checkDeviceNo {
    echo "checkDeviceNo empty"
}

############################################################################
# Create directory
#
# parameters:
# $1    ditectory name,
# $2    log prefix
function create_directory {
    local DirectoryName="$1"
    local LogPrefix="$2 "
    if [ ! -d "${DirectoryName}" ]; then
        # create and move to Test Case directory 
        if ! mkdir "${DirectoryName}"
        then
            echo "${LogPrefix} ERR_CREATE :$1 - cannot create directory"
            return "${ERR_CREATE}"
        fi
    else
        echo "${LogPrefix}Directory: ${DirectoryName} exists ..."
        return "${ERR_DIR_EXISTS}"
    fi
    return "${ERR_OK}"
}

############################################################################
# Get test summary directory name 
#
# parameters:
#       None 
#
function get_test_summary_directory_name {
    local CurrDir=$(pwd)
    local CommitIdShortened
    local SystemName
    local TestResultsDirectoryName
    cd "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" || exit "${ERR_NOEXIST}"
    CommitIdShortened=$(git log --pretty=format:'%h' -n 1)
    SystemName=$(hostnamectl | grep "Operating System" | awk '{ print $3 $4 }')
    TestResultsDirectoryName="Results_${SystemName}_commit_${CommitIdShortened}"
    cd "${CurrDir}" || exit "${ERR_NOEXIST}"

    echo "${TestResultsDirectoryName}"
}


############################################################################
# Get mdis sources commit sha
#
# parameters:
#       None 
#
function get_os_name_with_kernel_ver {
    cd "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" || exit "${ERR_NOEXIST}"
    local SystemName
    local Kernel
    local Arch
    SystemName=$(hostnamectl | grep "Operating System" | awk '{ print $3 $4 }')
    Kernel=$(uname -r)
    Arch=$(uname -m)

    cd "${CurrDir}" || exit "${ERR_NOEXIST}"
    SystemName="${SystemName//\//_}"
    SystemName="${SystemName//(/_}"
    SystemName="${SystemName//)/_}"
    echo "${SystemName}_${Kernel}_${Arch}"
}

############################################################################
# Run_test_case_common_actions - perform: 
#       - create directory and move into it
#       - create test case log file
#
# parameters:
# $1     Test Case Log name 
# $2     Test Case name
function run_test_case_dir_create {
    local TestCaseLogName=${1}
    local TestCaseName=${2}

    local CmdResult="${ERR_UNDEFINED}"

    # Create directory with bash script name 
    if ! create_directory "${TestCaseName}"
    then
        return "${CmdResult}"
    fi

    # Move into test case directory
    cd "${TestCaseName}" || exit "${ERR_NOEXIST}"

    # Create log file
    touch "${TestCaseLogName}"
}

function blacklist_mcb_pci {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    # Check if mcb_pci is already in blacklist, UART loopback test
    echo "${LogPrefix} Check if mcb_pci is blacklisted" | tee -a "${TestCaseLogName}" 2>&1
    run_as_root grep "blacklist mcb_pci" /etc/modprobe.d/blacklist.conf > /dev/null
    if [ $? -ne 0 ]; then
        # Add mcb_pci into blacklist
        run_as_root echo "# Add mcb_pci into blacklist" >> /etc/modprobe.d/blacklist.conf
        run_as_root echo "blacklist mcb_pci" >> /etc/modprobe.d/blacklist.conf
    else
        echo "${LogPrefix} blacklist mcb_pci found"
    fi
}

############################################################################
# Obtain device list from chameleon device, If there are several same boards
# number of board have to specified (default 1 board is taken as valid) 
#
# parameters:
# $1      Ven ID
# $2      Dev ID
# $3      SubVen ID
# $4      File name for results
# $5      Board number (optional, when there is more than one-the same mezz board)
function obtain_device_list_chameleon_device {
    local VenID=$1
    local DevID=$2
    local SubVenID=$3
    local FileWithResults=$4
    local BoardNumberParam=$5
    local TestCaseLogName=$6
    local LogPrefix=$7

    local BoardNumber=1
    local BoardsCnt=0
    local BusNr=0
    local DevNr=0

    debug_print "${LogPrefix} obtain_device_list_chameleon_device" "${TestCaseLogName}"
    # Check how many boards are present
    BoardsCnt=$(run_as_root /opt/menlinux/BIN/fpga_load -s | grep -c "${VenID} * ${DevID} * ${SubVenID}")
    debug_print "${LogPrefix} There are: ${BoardsCnt} mezzaine ${VenID} ${DevID} ${SubVenID} board(s) in the system" "${TestCaseLogName}"

    if (( "${BoardsCnt}" >= "2" )) ; then
        if [ "${BoardNumberParam}" -eq "0" ] || [ "${BoardNumberParam}" -ge "${BoardsCnt}" ]; then
            BoardNumber=1
        else
            BoardNumber=${BoardNumberParam}
        fi
    fi

    debug_print "${LogPrefix} Obtain modules name from mezz ${BoardNumber}" "${TestCaseLogName}"

    # Obtain BUS number
    BusNr=$(run_as_root /opt/menlinux/BIN/fpga_load -s | grep "${VenID} * ${DevID} * ${SubVenID}" | awk NR==${BoardNumber}'{print $3}')

    # Obtain DEVICE number
    DevNr=$(run_as_root /opt/menlinux/BIN/fpga_load -s | grep "${VenID} * ${DevID} * ${SubVenID}" | awk NR==${BoardNumber}'{print $4}')

    debug_print "${LogPrefix} Device BUS:${BusNr}, Dev:${DevNr}" "${TestCaseLogName}"
    # Check how many chameleon devices are present in configuration
    debug_print "${LogPrefix} Current Path:" "${TestCaseLogName}"
    debug_print "${LogPrefix} $PWD" "${TestCaseLogName}"

    local ChamBoardsNr
    ChamBoardsNr=$(grep -c "^mezz_cham*" ../../system.dsc)
    debug_print "${LogPrefix} Number of Chameleon boards: ${ChamBoardsNr}" "${TestCaseLogName}"

    local ChamBusNr=0
    local ChamDevNr=0
    local ChamValidId=0;

    # Check if device is present in system.dsc file
    #   PCI_BUS_NUMBER = BusNr
    #   PCI_DEVICE_NUMBER = DevNr

    for i in $(seq 1 "${ChamBoardsNr}"); do
        # Display chameleon bus and device number
        ChamBusNr=$(sed -n "/^mezz_cham_${i}/,/}/p" ../../system.dsc | grep "PCI_BUS_NUMBER" | awk '{print $4}')
        ChamDevNr=$(sed -n "/^mezz_cham_${i}/,/}/p" ../../system.dsc | grep "PCI_DEVICE_NUMBER" | awk '{print $4}')

        # Convert to decimal and check if it is valid chameleon board
        ChamBusNr=$(( 16#$(echo ${ChamBusNr} | awk -F'x' '{print $2}')))
        ChamDevNr=$(( 16#$(echo ${ChamDevNr} | awk -F'x' '{print $2}') ))

        if [ "${ChamBusNr}" -eq "${BusNr}" ] && [ "${ChamDevNr}" -eq "${DevNr}" ]; then
            print "${LogPrefix} mezz_cham_${i} board is valid" "${TestCaseLogName}"
            ChamValidId=${i}
        fi
    done

    # Check how many devices are present in system.dsc
    local DeviceNr
    DeviceNr=$(grep -c "{" ../../system.dsc)
    
    # Create file with devices description on mezzaine chameleon board
    touch "${FileWithResults}"

    for i in $(seq 1 "${DeviceNr}"); do
        #Check if device belongs to choosen chameleon board
        local DevToCheck
        DevToCheck=$(grep "{" ../../system.dsc  | awk NR==${i}'{print $1}')
        if [ "${DevToCheck}" != "mezz_cham_${ChamValidId}" ]; then
            sed -n "/${DevToCheck}/,/}/p" ../../system.dsc  | grep "mezz_cham_${ChamValidId}" > /dev/null 2>&1

            if [ $? -eq 0 ]; then
                debug_print "${LogPrefix}  Device: ${DevToCheck} belongs to mezz_cham_${ChamValidId}" "${TestCaseLogName}"
                echo "${DevToCheck}" >> "${FileWithResults}"
            fi
        fi
    done
}

############################################################################
# Obtain chameleon table dump
#
# parameters:
# $1      Ven ID
# $2      Dev ID
# $3      SubVen ID
# $4      File name for chameleon table
# $5      Board number (optional, when there is more than one-the same mezz board)
# $6      Test case log name
# $7      Log prefix
function obtain_chameleon_table {
    local VenID=$1
    local DevID=$2
    local SubVenID=$3
    local FileWithResults=$4
    local BoardNumberParam=$5 #TBD
    local LogFile=$6
    local LogPrefix=$7

    local BoardCnt=0
    local BoardMaxSlot=8

    debug_print "${LogPrefix} obtain_tty_number_list_from_board" "${LogFile}"
    for i in $(seq 0 ${BoardMaxSlot}); do
        run_as_root /opt/menlinux/BIN/fpga_load "${VenID}" "${DevID}" "${SubVenID}" "${i}" -t > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            BoardCnt=$((BoardCnt+1))
        else
            break
        fi
    done

    debug_print "${LogPrefix} Found ${BoardCnt}: ${VenID} ${DevID} ${SubVenID} board(s)" "${LogFile}"

    # Save chamelon table for board(s)
    for i in $(seq 1 ${BoardCnt}); do
        run_as_root /opt/menlinux/BIN/fpga_load "${VenID}" "${DevID}" "${SubVenID}" $((i-1)) -t >> "${FileWithResults}"
        if [ $? -eq 0 ]; then
            debug_print "${LogPrefix} Chameleon for Board_${VenID}_${DevID}_${SubVenID}_${i} board saved (1)" "${LogFile}"
        else
            break
        fi
    done
}

############################################################################
# Test RS232 at given tty_xx device
# Example:
#       uart_test_tty xxxx yyyy
#
# where x is: ttyS0 ... ttySx / ttyD0 ... ttyDx
# where y is: ttyS0 ... ttySx / ttyD0 ... ttyDx  
# It two uarts are connected with each other, then pass two different parameters
# It uart is connected with loopback, then pass two same parameters
# Example:
#       uart_test_tty xxxx yyyy
#       uart_test_tty ttyD0 ttyD1
#       uart_test_tty ttyD0 ttyD0
# parameters:
# $1      tty 0 name
# $2      tty 1 name
#
function uart_test_tty {
    local tty0=${1}
    local tty1=${2}
    local LogPrefix=${3}
    local LogFile=${4}

    #Conditions must be met: i2c-i801 is loaded, mcb_pci is not loaded
    run_as_root chmod o+rw /dev/${tty0}
    if [ $? -ne 0 ]; then
        debug_print "${LogPrefix} Could not chmod o+rw on ${tty0}" "${LogFile}"
    fi
    sleep 1
    # Below command prevent infitite loopback on serial port
    run_as_root stty -F /dev/${tty0} -onlcr
    if [ $? -ne 0 ]; then
        debug_print "${LogPrefix} Could not stty -F on ttyS${item}" "${LogFile}"
    fi
    sleep 1
    # Listen on port in background
    run_as_root cat /dev/${tty1}\
      > echo_on_serial_${tty1}.txt &

    if [ $? -ne 0 ]; then
        debug_print "${LogPrefix} Could not cat on ${tty1} in background" "${LogFile}"
    fi
    sleep 1 
    # Save background process PID 
    CatEchoTestPID=$!

    # Send data into port
    run_as_root echo "${EchoTestMessage}" > /dev/${tty0}
    if [ $? -ne 0 ]; then
        debug_print "${LogPrefix} Could not echo on ${tty0}" "${LogFile}"
    fi
    # Kill process
    sleep 1
    # Set up previous settings
    run_as_root chmod o-rw /dev/${tty0}
    if [ $? -ne 0 ]; then
        debug_print "${LogPrefix} Could not chmod o+rw on ${tty0}" "${LogFile}"
    fi

    run_as_root kill ${CatEchoTestPID}
    if [ $? -ne 0 ]; then
        print "${LogPrefix} Could not kill cat backgroung process ${CatEchoTestPID} on ${tty1}" "${LogFile}"
    fi
    # Compare and check if echo test message was received.
    sleep 1
    grep -a "${EchoTestMessage}" echo_on_serial_${tty1}.txt
    if [ $? -eq 0 ]; then
        debug_print "${LogPrefix} Echo succeed on ${tty1}" "${LogFile}"
        return "${ERR_OK}"
    else
        debug_print "${LogPrefix} Echo failed on ${tty1}" "${LogFile}"
    fi
    return "${ERR_VALUE}"
}

############################################################################
# This function resolves 'connection' beetween UART IpCore and ttyS number
# in linux system. Addresses for UART and ttyS are compared. 
#
# parameters:
# $1      Log file name
# $2      VenID
# $3      DevID
# $4      SubVenID
# $5      Board Number (1 as default)
function obtain_tty_number_list_from_board {
    local LogFile=$1
    local ChamTableDumpFile=$2
    local UartNoList=$3
    local LogPrefix=$4

    # Save uart devices into file
    run_as_root cat /proc/tty/driver/serial >> UART_devices_dump.txt

    # Check How many UARTS are on board(s)
    UartCnt=0
    for i in $(seq 1 ${BoardCnt}); do
        UartBrdCnt=$(grep -c "UART" "${ChamTableDumpFile}")
        for j in $(seq 1 ${UartBrdCnt}); do
            UartAddr=$(grep "UART" "${ChamTableDumpFile}" | awk NR==${j}'{print $11}')
            if [ $? -eq 0 ]; then
                debug_print "${LogPrefix}  UART ${j} addr saved" "${LogFile}"
                UartBrdNr[${UartCnt}]=${i}
                UartNr[${UartCnt}]=$(grep -i ${UartAddr} "UART_devices_dump.txt" | awk '{print $1}' | egrep -o '^[^:]+')
                UartCnt=$((UartCnt+1))
            else
                debug_print "${LogPrefix}  No more UARTs in board" "${LogFile}"
            fi
        done
    done

    debug_print "${LogPrefix} There are ${UartCnt} UART(s) on Chameleon table log" "${LogFile}"
    if [ ${UartCnt} -eq 0 ]; then
        return "${ERR_NOT_DEFINED}"
    fi
    # List all UARTs that are on board(s)
    touch "${UartNoList}"

    # Loop through all UART interfaces per board
    local UartNrInBoard=0
    for item in "${UartBrdNr[@]}"; do
        debug_print "${LogPrefix} Board: ${item}" "${LogFile}"
        debug_print "${LogPrefix} For board ${item} UART ttyS${UartNr[${UartNrInBoard}]} should be tested" "${LogFile}"
        echo "${UartNr[${UartNrInBoard}]}" >> "${UartNoList}"
        UartNrInBoard=$((UartNrInBoard + 1))
    done
}

############################################################################
# This function runs m module test
#   Possible machine states
#   1 - ModprobeDriver
#   2 - CheckInput
#   3 - EnableInput
#   4 - RunExampleInputEnable
#   5 - RunExampleInputDisable
#   6 - CompareResults
#   7 - DisableInput
#
#   IMPORTANT: 
#   If device cannot be opened there should always be line:
#   *** ERROR (LINUX) #2:  No such file or directory ***
#
# Function supports below m-modules
#       m66
#       m31
#       m35 
#       m36
#       m82

# parameters:
# $1
#
function m_module_x_test {
    local LogFile=${1}
    local TestCaseName=${2}
    local CommandCode=${3}
    local MModuleName=${4}
    local MModuleBoardNr=${5}
    local SubtestName=${6}
    local LogPrefix="${7}"

    local CmdResult=${ERR_UNDEFINED}
    local ErrorLogCnt=1
    local TestError=${ERR_UNDEFINED}
    local MachineState="ModprobeDriver"
    local MachineRun=true 

    local ModprobeDriver=""
    local ModuleSimp=""
    local ModuleSimpOutput="simp"
    local ModuleResultCmpFunc=""
    local ModuleInstanceName=""

    case "${MModuleName}" in
        m11)
            ModprobeDriver="men_ll_m11"
            ModuleSimp="m11_port_veri"
            ModuleResultCmpFunc="compare_m11_port_veri_values"
            ModuleInstanceName="${MModuleName}_${MModuleBoardNr}"
            ;;
        m31)
            ModprobeDriver="men_ll_m31"
            ModuleSimp="m31_simp"
            ModuleResultCmpFunc="compare_m31_simp_values"
            ModuleInstanceName="${MModuleName}_${MModuleBoardNr}"
            ;;
        m35)
            ModprobeDriver="men_ll_m34"
            if [ "${SubtestName}" == "blkread" ]; then
                ModuleSimp="m34_blkread -r=14 -b=1 -i=3 -d=1"
                ModuleSimpOutput="blkread"
                ModuleResultCmpFunc="compare_m35_blkread_values"
                ModuleInstanceName="${MModuleName}_${MModuleBoardNr}"
            else
                ModuleSimp="m34_simp"
                ModuleResultCmpFunc="compare_m35_simp_values"
                ModuleInstanceName="${MModuleName}_${MModuleBoardNr} 14"
            fi
            ;;
        m36n)
            ModprobeDriver="men_ll_m36"
            ModuleSimp="m36_simp"
            ModuleResultCmpFunc="compare_m36_simp_values"
            ModuleInstanceName="${MModuleName}_${MModuleBoardNr}"
            ;;
        m43)
            ModprobeDriver="men_ll_m43"
            ModuleSimp="m43_ex1"
            ModuleResultCmpFunc="compare_m43_simp_values"
            ModuleInstanceName="${MModuleName}_${MModuleBoardNr}"
            ;;
        m66)
            ModprobeDriver="men_ll_m66"
            ModuleSimp="m66_simp"
            ModuleResultCmpFunc="compare_m66_simp_values"
            ModuleInstanceName="${MModuleName}_${MModuleBoardNr}"
            ;;
        m82)
            #Software compatible with m31
            ModprobeDriver="men_ll_m31"
            ModuleSimp="m31_simp"
            ModuleResultCmpFunc="compare_m82_simp_values"
            ModuleInstanceName="${MModuleName}_${MModuleBoardNr}"
            ;;
        *)
            echo "MModule is not set"
            MModuleName="NotDefined"
            MachineRun=false
            TestError=${ERR_NOT_DEFINED}
            ;;
    esac

    debug_print "${LogPrefix} M-Module to test: ${MModuleName}" "${LogFile}"
    debug_print "${LogPrefix} M-Module modprobeDriver: ${ModprobeDriver}" "${LogFile}"
    debug_print "${LogPrefix} M-Module command: ${ModuleSimp} ${ModuleInstanceName}" "${LogFile}"
    debug_print "${LogPrefix} M-Module cmp function: ${ModuleResultCmpFunc}" "${LogFile}"

    while ${MachineRun}; do
        case "${MachineState}" in
            ModprobeDriver)
                # Modprobe driver
                debug_print "${LogPrefix} ModprobeDriver" "${LogFile}"
                run_as_root modprobe "${ModprobeDriver}"
                CmdResult=$?
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                    debug_print "${LogPrefix} Error: ${ERR_MODPROBE} :could not modprobe ${ModprobeDriver}" "${LogFile}"
                    MachineRun=false
                else
                    MachineState="CheckInput"
                fi
                ;;
            CheckInput)
                # Check if input is disabled - if not disable input 
                debug_print "${LogPrefix} CheckInput" "${LogFile}"
                change_input "${LogFile}" "${TestCaseName}" $((CommandCode+100)) "${LogPrefix}"
                CmdResult=$?
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                    debug_print "${LogPrefix} Error: ${CmdResult} in function change_input" "${LogFile}"
                    MachineRun=false
                else
                    MachineState="RunExampleInputDisable"
                fi
                ;;
            RunExampleInputDisable)
                # Run example first time (banana plugs disconnected)
                # If device cannot be opened there is a log in result  :
                # *** ERROR (LINUX) #2:  No such file or directory ***
                debug_print "${LogPrefix} RunExampleInputDisable" "${LogFile}"
                run_as_root ${ModuleSimp} ${ModuleInstanceName} > ${MModuleName}_${MModuleBoardNr}_${ModuleSimpOutput}_output_disconnected.txt 2>&1
                ErrorLogCnt=$(grep "ERROR" ${MModuleName}_${MModuleBoardNr}_${ModuleSimpOutput}_output_disconnected.txt | grep -c "No such file or directory") 
                CmdResult="${ErrorLogCnt}"
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                    debug_print "${LogPrefix} Error: ${ERR_SIMP_ERROR} :could not run ${ModuleSimp} ${ModuleInstanceName}" "${LogFile}"
                    MachineRun=false
                else
                    if [ "${MModuleName}" == "m35" ] && [ "${SubtestName}" == "blkread" ]; then
                        MachineState="CompareResults"
                    else
                        MachineState="EnableInput"
                    fi
                fi
                ;;
            EnableInput)
                debug_print "${LogPrefix} EnableInput" "${LogFile}"
                change_input "${LogFile}" "${TestCaseName}" "${CommandCode}" "${LogPrefix}"
                CmdResult=$?
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                    debug_print "${LogPrefix} Error: ${CmdResult} in function change_input" "${LogFile}"
                    MachineState=false
                else
                    MachineState="RunExampleInputEnable"
                fi
                ;;
            RunExampleInputEnable)
                # Run example second time (banana plugs connected)
                # If device cannot be opened there is a log in result  :
                # *** ERROR (LINUX) #2:  No such file or directory ***
                debug_print "${LogPrefix} RunExampleInputEnable" "${LogFile}"
                run_as_root ${ModuleSimp} ${ModuleInstanceName} > ${MModuleName}_${MModuleBoardNr}_${ModuleSimpOutput}_output_connected.txt 2>&1
                ErrorLogCnt=$(grep "ERROR" ${MModuleName}_${MModuleBoardNr}_${ModuleSimpOutput}_output_connected.txt | grep -c "No such file or directory") 
                CmdResult="${ErrorLogCnt}"
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                    debug_print "${LogPrefix} Error: ${ERR_SIMP_ERROR} :could not run ${ModuleSimp} ${ModuleInstanceName}" "${LogFile}"
                    MachineState="DisableInput"
                else
                    MachineState="CompareResults"
                fi
                ;;
            CompareResults)
                debug_print "${LogPrefix} CompareResults" "${LogFile}"
                "${ModuleResultCmpFunc}" "${LogFile}" "${LogPrefix}" "${MModuleBoardNr}"
                CmdResult=$?
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                    debug_print "${LogPrefix} Error: ${CmdResult} in ${ModuleResultCmpFunc} ${LogFile} ${TestCaseName} ${MModuleBoardNr}" "${LogFile}"
                    MachineState="DisableInput"
                    TestError=${CmdResult}
                else
                    MachineState="DisableInput"
                    TestError=${ERR_OK}
                fi
                ;;
            DisableInput)
                debug_print "${LogPrefix} DisableInput" "${LogFile}"
                change_input "${LogFile}" "${TestCaseName}" $((CommandCode+100)) "${LogPrefix}"
                CmdResult=$?
                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
                    debug_print "${LogPrefix} Error: ${CmdResult} in function change_input" "${LogFile}"
                fi
                MachineRun=false
                ;;
            *)
                debug_print "${LogPrefix} State is not set, start with ModprobeDriver" "${LogFile}"
                MachineState="ModprobeDriver"
                ;;
        esac
    done

    if [ "${TestError}" -eq "${ERR_UNDEFINED}" ]; then
        return "${CmdResult}"
    else
        return "${TestError}"
    fi
}
