#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/../Common/Conf.sh
source "${MyDir}"/Mdis_Functions.sh
source "${MyDir}"/Relay_Functions.sh
source "${MyDir}"/Environment_Requirements.sh

# This script contains all common functions that are used by test cases

############################################################################
# run_test_case_id specified by user
#
# parameters:
# $1     Test Id
# $2     TestSummaryDirectory
# $3     OsNameKernel
function run_test_case_id {
    local TestCaseId=${1}
    local TestSummaryDirectory=${2}
    local OsNameKernel=${3}
    local Board=""
    local Module=""
    echo "run_test_case_id: ${TestCaseId}"

    create_test_cases_map "Target"

    if [ -z "${TEST_CASES_MAP[${TestCaseId}]}" ]
    then
        echo "Invalid Test ID"
        exit
    fi

    if [ "${TestCaseId}" -lt "200" ]
    then
        Board=$(echo "${TEST_CASES_MAP[${TestCaseId}]}")
        run_test_case_board "${TestCaseId}" "${TestSummaryDirectory}" "${OsNameKernel}"
    elif [ "${TestCaseId}" -lt "300" ]
    then
        Module=$(echo "${TEST_CASES_MAP[${TestCaseId}]}" | sed 's/carrier_g204_//')
        echo "Module: ${Module}"
        run_test_case_module "${Module}" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
    elif [ "${TestCaseId}" -le "400" ]
    then
        Module=$(echo "${TEST_CASES_MAP[${TestCaseId}]}" | sed 's/carrier_f205_//')
        echo "Module: ${Module}"
        run_test_case_module "${Module}" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
    fi
}

############################################################################
# run_test_case_module specified by user
#
# parameters:
# $1     Module name
# $2     Carrier name
# $3     Module number
function run_test_case_module {
    local Module=${1}
    local CarrierBoard=${2}
    local ModuleNo=${3}
    local TestSummaryDirectory=${4}
    local OsNameKernel=${5}
    local OptionalParam=${6}
    local TestCaseId="0"

    if [ "${CarrierBoard}" = "G204" ]
    then
        echo "Board G204"
    elif [ "${CarrierBoard}" = "F205" ]
    then
        echo "Board F205"
    else
        echo "Board undefined"
        return "${ERR_VALUE}"
    fi

    TestCaseId=$(get_test_case_id "${Module}" "${CarrierBoard}")
    echo "TestCaseId: ${TestCaseId}"

    if [ "${TestCaseId}" = "9999" ]
    then
        return "${ERR_VALUE}"
    fi

    if [ "${CarrierBoard}" = "G204" ]
    then
        run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "carrier_g204_TPL" -module "${Module}" -moduleno "${ModuleNo}"
    else
        run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "carrier_f205_TPL" -module "${Module}" -moduleno "${ModuleNo}"
    fi
}
############################################################################
# run_test_case specified by user
#
# parameters:
# $1     Test case id
# $2     Test case summary directory
# $3     OS kernel no
function run_test_case_board {
    local TestCaseId="${1}"
    local DeviceNo="${2}"
    local TestSummaryDirectory="${3}"
    local OsNameKernel="${4}"
    if [ "${TEST_CASES_MAP[${TestCaseId}]+_}" ]; then
        run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "${TEST_CASES_MAP[${TestCaseId}]}" -dno "${DeviceNo}"
    else
        echo "Test case not found"
    fi
}

############################################################################
# Run command as root
#
# parameters:
# $1     command to run
function run_as_root {
    if [ "${#}" -gt "0" ]; then
        echo "${MenPcPassword}" | sudo -S --prompt=$'\r' -- "${@}"
    fi
}

############################################################################
# Print into terminal and into log file
#
# parameters:
# $1     Msg to print/log
# $2     Log file name
function print {
    local Msg="${1}"
    local LogFile="${2}"
    echo "${Msg}" | tee -a "${LogFile}" 2>&1
}

############################################################################
# Print debug verbose information into terminal and into log file
#
# parameters:
# $1     Msg to print/log
# $2     Log file name
function debug_print {
    local Msg="${1}"
    local LogFile="${2}"
    if [ "${VERBOSE_LEVEL}" -ge "1" ]; then
        echo "${Msg}" | tee -a "${LogFile}" 2>&1
    fi
}

############################################################################
# Print requirements from test case description
#
# parameters:
# $1     TestCase name
function print_requirements {
    local TestCase=${1}
    local Req=""
    local ReqCnt=1
    while [ "${Req}" != "INVALID" ]
    do  
        ReqCnt=$((ReqCnt+1))
        Req=$("${TestCase}" | grep -A 10 "UPPER_REQUIREMENT_ID:" | awk NR==${ReqCnt} | tr -d ' ')
        if [ "${Req}" != "RESULTS" ] && [ "${Req}" != "" ]
        then
            echo "    ${Req}"
        else
            Req="INVALID"
        fi
    done 
}

############################################################################
# Print environment requirements (OS, CPU, Kernel, Arch)
#
# parameters:
# none
function print_env_requirements {
    local TestSummaryDirectory="${1}"
    local CPU=""
    local OS=""
    local Kernel=""
    local ArchSpec""

    OS=$(hostnamectl | grep "Operating System" | awk '{ print $3 $4 }')
    if echo "${OS}" | grep -i "ubuntu" > /dev/null
    then
        os_requirement "ubuntu"
    elif echo "${OS}" | grep -i "centos" > /dev/null
    then
        os_requirement "centos"
    elif echo "${OS}" | grep -i "debian" > /dev/null
    then
        os_requirement "debian"
    fi

    Kernel=$(uname -r)
    if echo "${Kernel}" | grep -i "^3.16" > /dev/null ||
       echo "${Kernel}" | grep -i "^4.4" > /dev/null ||
       echo "${Kernel}" | grep -i "^4.9" > /dev/null ||
       echo "${Kernel}" | grep -i "^4.14" > /dev/null ||
       echo "${Kernel}" | grep -i "^4.19" > /dev/null ||
       echo "${Kernel}" | grep -i "^5.4" > /dev/null
    then
        kernel_requirement "lts"
    elif echo "${Kernel}" | grep -i "^5.5" > /dev/null ||
         echo "${Kernel}" | grep -i "^5.6"> /dev/null
    then
        kernel_requirement "latest"
    fi

    CPU=$(obtain_device_wiz_model "cpu" "${TestSummaryDirectory}")

    if echo "${CPU}" | grep -i "f23p" > /dev/null
    then
        cpu_requirement "f23p"
    elif echo "${CPU}" | grep -i "f26" > /dev/null
    then
        cpu_requirement "f26"
    elif echo "${CPU}" | grep -i "g23" > /dev/null
    then
        cpu_requirement "g23"
    elif echo "${CPU}" | grep -i "g25a" > /dev/null
    then
        cpu_requirement "g25a"
    elif echo "${CPU}" | grep -i "cb70" > /dev/null
    then
        cpu_requirement "cb70"
    elif echo "${CPU}" | grep -i "a25" > /dev/null
    then
        cpu_requirement "a25"
    fi

}

############################################################################
# Check if tested device belongs to board specified in the test case
#
# parameters:
# $1     ??
function checkDeviceNo {
    echo "checkDeviceNo empty"
}

############################################################################
# Create directory
#
# parameters:
# $1    Directory name
# $2    Log prefix
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
function get_test_summary_directory_name {
    local CurrDir
    local CommitIdShortened
    local SystemName
    local TestResultsDirectoryName
    CurrDir=$(pwd)
    cd "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" || exit "${ERR_NOEXIST}"
    CommitIdShortened=$(git log --pretty=format:'%h' -n 1)
    SystemName=$(hostnamectl | grep "Operating System" | awk '{ print $3 $4 }')
    TestResultsDirectoryName="Results_${SystemName}_commit_${CommitIdShortened}"
    cd "${CurrDir}" || exit "${ERR_NOEXIST}"

    echo "${TestResultsDirectoryName}"
}

############################################################################
# Get os name and kernel version
#
# parameters:
#       None
function get_os_name_with_kernel_ver {
    local SystemName
    local Kernel
    local Arch
    SystemName=$(hostnamectl | grep "Operating System" | awk '{ print $3 $4 }')
    Kernel=$(uname -r)
    Arch=$(uname -m)

    SystemName="${SystemName//\//_}"
    SystemName="${SystemName//\(/_}"
    SystemName="${SystemName//\)/_}"
    echo "${SystemName}_${Kernel}_${Arch}"
}

############################################################################
# Create test case directory and log file
#
# parameters:
# $1     Log file
# $2     Test Case name
function run_test_case_dir_create {
    local LogFile=${1}
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
    touch "${LogFile}"
}

############################################################################
# Check if mcb_pci is blacklisted on current os and add entry into
# blacklist.conf if necessary
#
# parameters:
# $1     Log file
# $2     Test Case name
function blacklist_mcb_pci {
    local LogFile=${1}
    local TestCaseName=${2}
    # Check if mcb_pci is already in blacklist, UART loopback test
    echo "${LogPrefix} Check if mcb_pci is blacklisted" | tee -a "${LogFile}" 2>&1

    if ! run_as_root grep "blacklist mcb_pci" /etc/modprobe.d/blacklist.conf > /dev/null
    then
        # Add mcb_pci into blacklist
        run_as_root echo "# Add mcb_pci into blacklist" >> /etc/modprobe.d/blacklist.conf
        run_as_root echo "blacklist mcb_pci" >> /etc/modprobe.d/blacklist.conf
    else
        echo "${LogPrefix} blacklist mcb_pci found"
    fi
}

############################################################################
# Obtain _WIZ_MODEL for given device name
# It is assumed that following system.dsc format for WIZ_MODEL is used:
# _WIZ_MODEL = STRING 16Z034_GPIO
#
# parameters:
# $1      m-module name
function obtain_device_wiz_model {
    local DeviceName=${1}
    local TestSummaryDirectory="${2}"
    local PathSystemDsc=""
    if [ -z "${TestSummaryDirectory}" ]
    then
        PathSystemDsc=$(realpath ../../system.dsc)
    else
        PathSystemDsc="${TestSummaryDirectory}/system.dsc"
    fi
    awk -v mname="${DeviceName} {" '{
    if(index($0,mname)!=0)
            valid=1
    if(index($0,"}")!=0)
            valid=0
    if(valid==1)
            print
    }' "${PathSystemDsc}" | grep "_WIZ_MODEL" | awk '{print $4}'
}

############################################################################
# Obtain carrier board for given M-Module name
# It is assumed that following system.dsc format for CARRIER BOARD is used:
# BOARD_NAME = STRING <board>
#
# parameters:
# $1      m-module name
function obtain_m_module_carrier_name {
    local ModuleName=${1}
    awk -v mname="${ModuleName} {" '{
    if(index($0,mname)!=0)
            valid=1
    if(index($0,"}")!=0)
            valid=0
    if(valid==1)
            print
    }' ../../system.dsc | grep "BOARD_NAME" | awk '{print $4}'
}
############################################################################
# Obtain device list from chameleon device, If there are several same boards
# number of board have to specified (default the first board is taken)
#
# parameters:
# $1      Ven ID
# $2      Dev ID
# $3      SubVen ID
# $4      File with result name
# $5      Board number
# $6      Log file
# $7      Log prefix
function obtain_device_list_chameleon_device {
    local VenID=$1
    local DevID=$2
    local SubVenID=$3
    local FileWithResults=$4
    local BoardNumberParam=$5
    local LogFile=$6
    local LogPrefix=$7

    local BoardNumber=1
    local BoardsCnt=0
    local BusNr=0
    local DevNr=0

    debug_print "${LogPrefix} obtain_device_list_chameleon_device" "${LogFile}"

    if [ "${VenID}" = "sc24_fpga"]; then
        # Check how many devices are present in system.dsc
        local DeviceNr
        DeviceNr=$(grep -c "{" ../../system.dsc)

        # Create file with devices description on mezzaine chameleon board
        touch "${FileWithResults}"
        for i in $(seq 1 "${DeviceNr}"); do
            #Check if device belongs to choosen chameleon board
            local DevToCheck
            DevToCheck=$(grep "{" ../../system.dsc  | awk NR=="${i}"'{print $1}')
            if [ "${DevToCheck}" != "sc24_fpga" ]; then
                if sed -n "/${DevToCheck}/,/}/p" ../../system.dsc  | grep "sc24_fpga" > /dev/null 2>&1
                then
                    debug_print "${LogPrefix}  Device: ${DevToCheck} belongs to sc24_fpga" "${LogFile}"
                    echo "${DevToCheck}" >> "${FileWithResults}"
                fi
            fi
        done
        return
    fi

    if [ "${VenID}" = "sc31_fpga"]; then
        # Check how many devices are present in system.dsc
        local DeviceNr
        DeviceNr=$(grep -c "{" ../../system.dsc)

        # Create file with devices description on mezzaine chameleon board
        touch "${FileWithResults}"
        for i in $(seq 1 "${DeviceNr}"); do
            #Check if device belongs to choosen chameleon board
            local DevToCheck
            DevToCheck=$(grep "{" ../../system.dsc  | awk NR=="${i}"'{print $1}')
            if [ "${DevToCheck}" != "sc31_fpga" ]; then
                if sed -n "/${DevToCheck}/,/}/p" ../../system.dsc  | grep "sc31_fpga" > /dev/null 2>&1
                then
                    debug_print "${LogPrefix}  Device: ${DevToCheck} belongs to sc31_fpga" "${LogFile}"
                    echo "${DevToCheck}" >> "${FileWithResults}"
                fi
            fi
        done
        return
    fi

    # Check how many boards are present
    BoardsCnt=$(run_as_root /opt/menlinux/BIN/fpga_load -s | grep -c "${VenID} * ${DevID} * ${SubVenID}")
    debug_print "${LogPrefix} There are: ${BoardsCnt} mezzaine ${VenID} ${DevID} ${SubVenID} board(s) in the system" "${LogFile}"

    if (( "${BoardsCnt}" >= "2" )) ; then
        if [ "${BoardNumberParam}" -eq "0" ] || [ "${BoardNumberParam}" -ge "${BoardsCnt}" ]; then
            BoardNumber=1
        else
            BoardNumber=${BoardNumberParam}
        fi
    fi

    debug_print "${LogPrefix} Obtain modules name from mezz ${BoardNumber}" "${LogFile}"

    # Obtain BUS number
    BusNr=$(run_as_root /opt/menlinux/BIN/fpga_load -s | grep "${VenID} * ${DevID} * ${SubVenID}" | awk NR=="${BoardNumber}"'{print $3}')

    # Obtain DEVICE number
    DevNr=$(run_as_root /opt/menlinux/BIN/fpga_load -s | grep "${VenID} * ${DevID} * ${SubVenID}" | awk NR=="${BoardNumber}"'{print $4}')

    debug_print "${LogPrefix} Device BUS:${BusNr}, Dev:${DevNr}" "${LogFile}"
    # Check how many chameleon devices are present in configuration
    debug_print "${LogPrefix} Current Path:" "${LogFile}"
    debug_print "${LogPrefix} $PWD" "${LogFile}"

    local ChamBoardsNr
    ChamBoardsNr=$(grep -c "^mezz_cham*" ../../system.dsc)
    debug_print "${LogPrefix} Number of Chameleon boards: ${ChamBoardsNr}" "${LogFile}"

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
        ChamBusNr=$(( 16#$(echo "${ChamBusNr}" | awk -F'x' '{print $2}')))
        ChamDevNr=$(( 16#$(echo "${ChamDevNr}" | awk -F'x' '{print $2}') ))

        if [ "${ChamBusNr}" -eq "${BusNr}" ] && [ "${ChamDevNr}" -eq "${DevNr}" ]; then
            print "${LogPrefix} mezz_cham_${i} board is valid" "${LogFile}"
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
        DevToCheck=$(grep "{" ../../system.dsc  | awk NR=="${i}"'{print $1}')
        if [ "${DevToCheck}" != "mezz_cham_${ChamValidId}" ]; then
            if sed -n "/${DevToCheck}/,/}/p" ../../system.dsc  | grep "mezz_cham_${ChamValidId}" > /dev/null 2>&1
            then
                debug_print "${LogPrefix}  Device: ${DevToCheck} belongs to mezz_cham_${ChamValidId}" "${LogFile}"
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
# $6      Log file
# $7      Log prefix
function obtain_chameleon_table {
    local VenID=$1
    local DevID=$2
    local SubVenID=$3
    local FileWithResults=$4
    local BoardNumberParam=$5
    local LogFile=$6
    local LogPrefix=$7

    local BoardCnt=0
    local BoardMaxSlot=8

    debug_print "${LogPrefix} obtain_chameleon_table" "${LogFile}"
    for i in $(seq 0 ${BoardMaxSlot}); do
        if run_as_root /opt/menlinux/BIN/fpga_load "${VenID}" "${DevID}" "${SubVenID}" "${i}" -t > /dev/null 2>&1
        then
            BoardCnt=$((BoardCnt+1))
        else
            break
        fi
    done

    debug_print "${LogPrefix} Found ${BoardCnt}: ${VenID} ${DevID} ${SubVenID} board(s)" "${LogFile}"

    # Save chamelon table for board(s)
    for i in $(seq 1 ${BoardCnt}); do
        if run_as_root /opt/menlinux/BIN/fpga_load "${VenID}" "${DevID}" "${SubVenID}" $((i-1)) -t >> "${FileWithResults}"
        then
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
# where x is: ttyS0 ... ttySx / ttyD0 ... ttyDx
# where y is: ttyS0 ... ttySx / ttyD0 ... ttyDx
#
# If two uarts are connected with each other then pass two different tty devices
# If one uart is connected with loopback, then pass two same tty devices
# Example:
#       uart_test_tty xxxx yyyy
#       uart_test_tty ttyD0 ttyD1 (double)
#       uart_test_tty ttyD0 ttyD0 (single)
# parameters:
# $1      tty 0 name
# $2      tty 1 name
# $3      Log file
# $4      Log prefix
function uart_test_tty {
    local tty0=${1}
    local tty1=${2}
    local LogPrefix=${3}
    local LogFile=${4}

    #Conditions must be met: i2c-i801 is loaded, mcb_pci is not loaded
    if ! run_as_root chmod o+rw "/dev/${tty0}"
    then
        debug_print "${LogPrefix} Could not chmod o+rw on ${tty0}" "${LogFile}"
    fi
    sleep 1

    # Below command prevent infitite loopback on serial port
    if ! run_as_root stty -F "/dev/${tty0}" -onlcr
    then
        debug_print "${LogPrefix} Could not stty -F on /dev/${tty0}" "${LogFile}"
    fi
    sleep 1
    # Listen on port in background

    if ! run_as_root $(cat /dev/${tty1} > echo_on_serial_${tty1}.txt &)
    then
        debug_print "${LogPrefix} Could not cat on ${tty1} in background" "${LogFile}"
    fi
    sleep 1
    # Save background process PID
    CatEchoTestPID=$(ps aux | grep "cat /dev/${tty1}" | awk 'NR==1 {print $2}')

    # Send data into port
    if ! run_as_root echo "${EchoTestMessage}" > "/dev/${tty0}"
    then
        debug_print "${LogPrefix} Could not echo on ${tty0}" "${LogFile}"
    fi
    # Kill process
    sleep 1
    # Set up previous settings

    if ! run_as_root chmod o-rw "/dev/${tty0}"
    then
        debug_print "${LogPrefix} Could not chmod o+rw on ${tty0}" "${LogFile}"
    fi

    if ! run_as_root kill "${CatEchoTestPID}"
    then
        print "${LogPrefix} Could not kill cat backgroung process ${CatEchoTestPID} on ${tty1}" "${LogFile}"
    fi
    # Compare and check if echo test message was received.
    sleep 1
    
    if grep -a "${EchoTestMessage}" "echo_on_serial_${tty1}.txt" > /dev/null
    then
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
# $1      Log file
# $2      Dump of chameleon table
# $3      Uart device list
# $4      Log prefix
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
            UartAddr=$(grep "UART" "${ChamTableDumpFile}" | awk NR=="${j}"'{print $11}')
            debug_print "${LogPrefix} UART ${j} addr saved" "${LogFile}"
            UartBrdNr[${UartCnt}]=${i}
            UartNr[${UartCnt}]=$(grep -i "${UartAddr}" "UART_devices_dump.txt" | awk '{print $1}' | egrep -o '^[^:]+')
            if [ "${UartNr[${UartCnt}]}" = "" ]
            then
                return ${ERR_VALUE}
            fi
            UartCnt=$((UartCnt+1))
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
# To check if m-module is supported, please find 'case' below
#
# parameters:
# $1    Log file
# $2    Test case name
# $3    Relay switch
# $4    M-module name
# $5    M-module number
# $6    Test name (if there is more than 1)
# $7    Log prefix
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
                run_as_root ${ModuleSimp} ${ModuleInstanceName} > "${MModuleName}_${MModuleBoardNr}_${ModuleSimpOutput}_output_disconnected.txt" 2>&1
                ErrorLogCnt=$(grep "ERROR" "${MModuleName}_${MModuleBoardNr}_${ModuleSimpOutput}_output_disconnected.txt" | grep -c "No such file or directory") 
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
                run_as_root ${ModuleSimp} ${ModuleInstanceName} > "${MModuleName}_${MModuleBoardNr}_${ModuleSimpOutput}_output_connected.txt" 2>&1
                ErrorLogCnt=$(grep "ERROR" "${MModuleName}_${MModuleBoardNr}_${ModuleSimpOutput}_output_connected.txt" | grep -c "No such file or directory") 
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
