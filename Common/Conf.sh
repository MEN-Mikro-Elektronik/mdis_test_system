#! /bin/bash
#
#
# This script contains definition of all variables that have to be defined by user,
#
# Below information about all exit codes that can be used during tests
# Error code description (common for all test cases and this script):
ERR_OK=0                #  0 - no error
ERR_CREATE=1            #  1 - cannot create directory (e.g. no privileges)
ERR_SCAN=2              #  2 - error during scanning the hardware
ERR_MAKE=3              #  3 - error during make on MDIS sources
ERR_INSTALL=4           #  4 - error during install 
ERR_MODPROBE=5          #  5 - error while loading the driver via 'modprobe' command
ERR_RMMOD=6             #  6 - error while removing loaded driver via 'rmmod' command 
ERR_CLEANUP=7           #  7 - could not clean up test case directory
ERR_CONNECT=8           #  8 - could not connect to external device
ERR_SWITCH=9            #  9 - could not enable/disable outputs on external device
ERR_VALUE=10            # 10 - incorrect output value after test
ERR_NOEXIST=11          # 11 - requested file/param does not exists
ERR_RUN=12              # 12 - error while running example module program
ERR_LOCK_EXISTS=13      # 13 - lock file exists
ERR_LOCK_NO_EXISTS=14   # 14 - lock file not exists
ERR_LOCK_NO_RESULT=15   # 15 - lock, no result yet
ERR_LOCK_INVALID=16     # 16 - invalid lock file, wrong Test Case name, wrong value
ERR_SIMP_ERROR=17       # 17 - error while running module example script 
ERR_NOT_DEFINED=18      # 18 - error, some variable is not defined
ERR_DOWNLOAD=19         # 19 - error while downloading the sources
ERR_CONF=20             # 20 - configuration error
ERR_DIR_EXISTS=21       # 21 - directory exists
ERR_DIR_NOT_EXISTS=22   # 22 - directory does not exist
ERR_WARNING=23          # 23 - warning
ERR_UNDEFINED=99        # 99 - undefined error

# Command code description (common for all test cases and this script)
IN_0_ENABLE=100         # change input 0 to enable (with BL51 stands for OPT1) 
IN_1_ENABLE=101         # change input 1 to enable (with BL51 stands for OPT2) 
IN_2_ENABLE=102         # change input 2 to enable (with BL51 stands for RELAY 1) 
IN_3_ENABLE=103         # change input 3 to enable (with BL51 stands for RELAY 2) 
IN_4_ENABLE=104         # change input 4 to enable
IN_0_DISABLE=200        # change input 0 to disable (with BL51 stands for OPT1) 
IN_1_DISABLE=201        # change input 1 to disable (with BL51 stands for OPT2) 
IN_2_DISABLE=202        # change input 2 to disable (with BL51 stands for RELAY 1)
IN_3_DISABLE=203        # change input 3 to disable (with BL51 stands for RELAY 2) 
IN_4_DISABLE=204        # change input 4 to disable

declare -A TEST_CASES_MAP
TEST_CASES_MAP["1"]="b_smb2"
TEST_CASES_MAP["2"]="b_smb2_eetemp"
TEST_CASES_MAP["3"]="b_smb2_led"
TEST_CASES_MAP["4"]="b_smb2_pci"
TEST_CASES_MAP["5"]="b_smb2_poe"
TEST_CASES_MAP["100"]="f215"
TEST_CASES_MAP["101"]="f223"
TEST_CASES_MAP["102"]="f614"
TEST_CASES_MAP["103"]="g229"
TEST_CASES_MAP["104"]="g215"
TEST_CASES_MAP["105"]="f206"
TEST_CASES_MAP["150"]="f215_stress"
TEST_CASES_MAP["151"]="g229_stress"
TEST_CASES_MAP["500"]="bl50_boxpc"
TEST_CASES_MAP["501"]="bl51_boxpc"
TEST_CASES_MAP["502"]="bl70_boxpc"
TEST_CASES_MAP["700"]="dc19_panelpc"

# Address of Target that will be tested
MenPcIpAddr="11.10.10.12"

# Credentials for Pc that will be tested - required by ssh connection and sudo cmds
MenPcLogin="men"
MenPcPassword="men"

# Address of device that will be changing status of inputs in tested device 
MenBoxPcIpAddr="11.10.10.10"
INPUT_SWITCH_TIMEOUT=10 #seconds

# Credentials, address, and command to download Git repository with Test Cases source
GitTestSourcesBranch="mad-dev-06-24"
GitTestSourcesCmd="git clone -b ${GitTestSourcesBranch} https://github.com/MEN-Mikro-Elektronik/mdis_test_system.git"

# Credentials, address, and command to download Git repository with 13MD05-90 sources
GitMdisBranch="master"
GitMdisCmd="git clone --recursive -b ${GitMdisBranch} https://github.com/MEN-Mikro-Elektronik/13MD05-90.git"
# This is optional if specific commit have to be tested !
# If Commit sha is not defined, then the most recent commit on branch is used. 
# Example: 
# GitMdisCommitSha="15fe1dd75ed20209e5a6165876ac4d6953987f55"
GitMdisCommitSha=""

# Directory names that are used during tests
# Directory structure as below:
#       MDIS_Test/
#       |-- 13MD05-90
#       |-- Test_Sources
#       `-- Results
#               |--Commit_xxxx
#               `--Commit_xxxx
#
MainTestDirectoryPath="/media/tests"
MdisSourcesDirectoryName="13MD05-90" 
TestSourcesDirectoryName="mdis_test_system"
MainTestDirectoryName="MDIS_Test"
MdisResultsDirectoryName="Results"
# optional - used for proprietary drivers
MdisExternalDirectoryPath="/media/tests/MDIS_External_Sources"

MdisResultsDirectoryPath="${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisResultsDirectoryName}"
GitTestCommonDirPath="${MainTestDirectoryPath}/${MainTestDirectoryName}/${TestSourcesDirectoryName}/Common"
GitTestTargetDirPath="${MainTestDirectoryPath}/${MainTestDirectoryName}/${TestSourcesDirectoryName}/Target"
GitTestHostDirPath="${MainTestDirectoryPath}/${MainTestDirectoryName}/${TestSourcesDirectoryName}/Host/Mdis_Test"

ResultsFileLogName="Results_summary.log"

# LockFile can be created only in 
#       ${MainTestDirectoryName}/
#       `-- lock.change.input.tmp
#
# When input change is required - file is created and Test Case name and Command  
# code is written into file. When the change has been done, success / fail flag  
# is added after Command code. When the status is read, file have to be deleted.
# Lock file contains only ONE command code!
# example: 
#       TestCaseName : IN_0_ENABLE : success
# example1: 
#       TestCaseName : IN_2_DISABLE : failed
#
LockFileName="${MainTestDirectoryPath}/${MainTestDirectoryName}/lock.change.input.tmp"
LockFileNameResult="${MainTestDirectoryPath}/${MainTestDirectoryName}/lock.change.input.tmp.result"
LockFileSuccess="success"
LockFileFailed="failed"

# Number of request packets to send
PING_PACKET_COUNT=3
# Time to wait for a response [s]
PING_PACKET_TIMEOUT=1
# Host to test
PING_TEST_HOST=www.google.com

# Uart loopback message to test
EchoTestMessage="UART LOOPBACK TEST"

# GRUB configuration file
GrubConfFile=/media/tests/boot.cfg
# List of OSes to test (GRUB menu entries). The first is the default OS and is
# not used for tests.

# List of test setups that require manual OS booting
ManualOsBootSetups=()

#F26L
GrubOsesF26L=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )

#F23P
GrubOsesF23P=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )
#G23
GrubOsesG23=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )
#G25A
GrubOsesG25A=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )
#BL50
GrubOsesBL50=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )
#BL51E
GrubOsesBL51E=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )
#BL70
GrubOsesBL70=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )
#CB70
GrubOsesCB70=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )
#A25
GrubOsesA25=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )

#DC19
GrubOsesDC19=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Ubuntu, with Linux 5.4.0-26-generic (on /dev/sda12)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 8 (Core) (on /dev/sda9)" \
        "Debian GNU/Linux 10 (buster) (on /dev/sda14)" \
        "Debian GNU/Linux, with Linux 4.19.0-10-amd64 (on /dev/sda15)" \
        "Debian GNU/Linux (on /dev/sda20)" \
        "Debian GNU/Linux (on /dev/sda21)" \
        )

function create_test_cases_map {
    local IsTarget="${1}"
    local TestPath=""
    local TestCaseId=""
    local Module=""

    if [ ! -z "${IsTarget}" ]
    then
        TestPath=$(realpath "${GitTestTargetDirPath}")
    else
        TestPath=$(realpath ../../Target)
    fi

    if [ ! -d "${TestPath}" ]
    then
        echo "Dir ${TestPath} does not exists"
        exit
    fi

    # All supported m-modules can be found in directory Target/M_Modules_Tests
    # loop through G204 carrier board
    for Module in $(ls -l ${TestPath}/M_Modules_Tests/ | awk '{print $9}' | sed 's/.sh//'); do
        TestCaseId=$(get_test_case_id "${Module}" "G204")
        TEST_CASES_MAP["${TestCaseId}"]="carrier_g204_${Module}"
    done
    # loop through F205 carrier board
    for Module in $(ls -l ${TestPath}/M_Modules_Tests/ | awk '{print $9}' | sed 's/.sh//'); do
        TestCaseId=$(get_test_case_id "${Module}" "F205")
        TEST_CASES_MAP["${TestCaseId}"]="carrier_f205_${Module}"
    done
}

############################################################################
# get m-module test case id
#
# parameters:
# $1     Module name
# $2     Carrier name
function get_test_case_id {
    local Module=${1}
    local CarrierBoard=${2}

    local TestCaseId="9999"
    local baseG204Id=200
    local baseF205Id=300
    local baseId="0"

    if [ "${CarrierBoard}" = "G204" ]
    then
        baseId=${baseG204Id}
    elif [ "${CarrierBoard}" = "F205" ]
    then
        baseId=${baseF205Id}
    else
        echo "${TestCaseId}"
        return
    fi

    case "${Module}" in
        m11)
            TestCaseId=$((baseId+1))
            ;;
        m31)
            TestCaseId=$((baseId+2))
            ;;
        m32)
            TestCaseId=$((baseId+3))
            ;;
        m33)
            TestCaseId=$((baseId+4))
            ;;
        m35n)
            TestCaseId=$((baseId+5))
            ;;
        m36n)
            TestCaseId=$((baseId+6))
            ;;
        m37n)
            TestCaseId=$((baseId+7))
            ;;
        m43n)
            TestCaseId=$((baseId+8))
            ;;
        m47)
            TestCaseId=$((baseId+9))
            ;;
        m57)
            TestCaseId=$((baseId+10))
            ;;
        m58)
            TestCaseId=$((baseId+11))
            ;;
        m62n)
            TestCaseId=$((baseId+12))
            ;;
        m65n)
            TestCaseId=$((baseId+13))
            ;;
        m66)
            TestCaseId=$((baseId+14))
            ;;
        m72)
            TestCaseId=$((baseId+15))
            ;;
        m77)
            TestCaseId=$((baseId+16))
            ;;
        m81)
            TestCaseId=$((baseId+17))
            ;;
        m82)
            TestCaseId=$((baseId+18))
            ;;
        m99)
            TestCaseId=$((baseId+19))
            ;;
        m199)
            TestCaseId=$((baseId+20))
            ;;
        m65n_canopen)
            TestCaseId=$((baseId+21))
            ;;
        *)
            TestCaseId="9999"
            ;;
    esac

echo "${TestCaseId}"
}

declare -a TEST_SETUP_1_TEST_CASES
declare -a TEST_SETUP_2_TEST_CASES
declare -a TEST_SETUP_3_TEST_CASES
declare -a TEST_SETUP_4_TEST_CASES
declare -a TEST_SETUP_5_TEST_CASES
declare -a TEST_SETUP_6_TEST_CASES
declare -a TEST_SETUP_7_TEST_CASES
declare -a TEST_SETUP_8_TEST_CASES
declare -a TEST_SETUP_9_TEST_CASES
declare -a TEST_SETUP_10_TEST_CASES
declare -a TEST_SETUP_11_TEST_CASES
# Create test setup test cases map:
function create_test_setup_test_cases_map {
    local Setup="${1}"
    case "${Setup}" in
        1)
            TEST_SETUP_1_TEST_CASES[100]="true"
            TEST_SETUP_1_TEST_CASES[104]="true"
            TEST_SETUP_1_TEST_CASES[$(get_test_case_id "m65n" "G204")]="true"
            TEST_SETUP_1_TEST_CASES[$(get_test_case_id "m65n_canopen" "G204")]="true"
            TEST_SETUP_1_TEST_CASES[$(get_test_case_id "m77" "G204")]="true"
            TEST_SETUP_1_TEST_CASES[$(get_test_case_id "m33" "F205")]="true"
            TEST_SETUP_1_TEST_CASES[$(get_test_case_id "m47" "F205")]="true"
            ;;
        2)
            TEST_SETUP_2_TEST_CASES[102]="true"
            TEST_SETUP_2_TEST_CASES[101]="true"
            TEST_SETUP_2_TEST_CASES[$(get_test_case_id "m43n" "F205")]="true"
            TEST_SETUP_2_TEST_CASES[$(get_test_case_id "m11" "F205")]="true"
            TEST_SETUP_2_TEST_CASES[$(get_test_case_id "m66" "F205")]="true"
            TEST_SETUP_2_TEST_CASES[$(get_test_case_id "m31" "F205")]="true"
            TEST_SETUP_2_TEST_CASES[$(get_test_case_id "m32" "F205")]="true"
            TEST_SETUP_2_TEST_CASES[$(get_test_case_id "m58" "F205")]="true"
            TEST_SETUP_2_TEST_CASES[$(get_test_case_id "m37n" "F205")]="true"
            TEST_SETUP_2_TEST_CASES[$(get_test_case_id "m62n" "F205")]="true"
            TEST_SETUP_2_TEST_CASES[$(get_test_case_id "m57" "F205")]="true"
            ;;
        3)
            TEST_SETUP_3_TEST_CASES[$(get_test_case_id "m35n" "G204")]="true"
            TEST_SETUP_3_TEST_CASES[$(get_test_case_id "m36n" "G204")]="true"
            ;;
        4)
            TEST_SETUP_4_TEST_CASES[1]="true"
            TEST_SETUP_4_TEST_CASES[103]="true"
            TEST_SETUP_4_TEST_CASES[$(get_test_case_id "m81" "G204")]="true"
            TEST_SETUP_4_TEST_CASES[$(get_test_case_id "m72" "G204")]="true"
            ;;
        5)
            TEST_SETUP_5_TEST_CASES[105]="true"
            TEST_SETUP_5_TEST_CASES[$(get_test_case_id "m82" "G204")]="true" #x2
            TEST_SETUP_5_TEST_CASES[$(get_test_case_id "m99" "F205")]="true"
            TEST_SETUP_5_TEST_CASES[$(get_test_case_id "m199" "F205")]="true"
            ;;
        6)
            TEST_SETUP_6_TEST_CASES[1]="true"
            TEST_SETUP_6_TEST_CASES[2]="true"
            ;;
        7)
            # Manuall tests
            ;;
        8)
            TEST_SETUP_8_TEST_CASES[1]="true"
            TEST_SETUP_8_TEST_CASES[2]="true"
            TEST_SETUP_8_TEST_CASES[3]="true"
            TEST_SETUP_8_TEST_CASES[4]="true"
            TEST_SETUP_8_TEST_CASES[500]="true"
            ;;
        9)
            TEST_SETUP_9_TEST_CASES[1]="true"
            TEST_SETUP_9_TEST_CASES[2]="true"
            TEST_SETUP_9_TEST_CASES[3]="true"
            TEST_SETUP_9_TEST_CASES[4]="true"
            TEST_SETUP_9_TEST_CASES[501]="true"
            ;;
        10)
            TEST_SETUP_10_TEST_CASES[1]="true"
            TEST_SETUP_10_TEST_CASES[2]="true"
            TEST_SETUP_10_TEST_CASES[3]="true"
            TEST_SETUP_10_TEST_CASES[4]="true"
            TEST_SETUP_10_TEST_CASES[5]="true"
            TEST_SETUP_10_TEST_CASES[502]="true"
            ;;
        11)
            TEST_SETUP_11_TEST_CASES[700]="true"
            ;;
        *)
            echo "TEST SETUP OR TEST ID IS NOT SET PROPERLY"
            exit 99
            ;;
    esac
}
