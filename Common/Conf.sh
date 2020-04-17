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
TEST_CASES_MAP["0100"]="f215"
TEST_CASES_MAP["0101"]="f223"
TEST_CASES_MAP["0102"]="f614"
TEST_CASES_MAP["0103"]="g229"
TEST_CASES_MAP["0104"]="g215"

# Address of Target that will be tested
MenPcIpAddr="192.168.1.21"

# Credentials for Pc that will be tested - required by ssh connection and sudo cmds
MenPcLogin="men"
MenPcPassword="men"

# Address of device that will be changing status of inputs in tested device 
MenBoxPcIpAddr="192.168.1.14"
INPUT_SWITCH_TIMEOUT=10 #seconds

# Credentials, address, and command to download Git repository with Test Cases source
GitTestSourcesBranch="jpe-dev-02_02"
GitTestSourcesCmd="git clone -b ${GitTestSourcesBranch} https://github.com/MEN-Mikro-Elektronik/mdis_test_system.git"

# Credentials, address, and command to download Git repository with 13MD05-90 sources
GitMdisBranch="jpe-dev"
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
MainTestDirectoryPath="/home/men/TEST/tests"
MdisSourcesDirectoryName="13MD05-90" 
TestSourcesDirectoryName="mdis_test_system"
MainTestDirectoryName="MDIS_Test"
MdisResultsDirectoryName="Results"
# optional - used for proprietary drivers
MdisExternalDirectoryPath="/home/men/TEST/MDIS_External_Sources"

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

#F26L
GrubOsesF26L=("0" \
        "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)" \
        "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda15)" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-686-pae (on /dev/sda18)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-amd64 (on /dev/sda19)" \
        "Poky (Yocto Project Reference Distro) 2.5 (sumo) (on /dev/sda21)" \
        "Poky (Yocto Project Reference Distro) 2.7.1 (warrior) (on /dev/sda22)" \
        )

#F23P
GrubOsesF23P=("0" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "CentOS Linux 7 (Core) (on /dev/sda10)" \
        "CentOS Linux 8 (Core) (on /dev/sda11)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-686-pae (on /dev/sda18)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-amd64 (on /dev/sda19)" \
        )
#G22
GrubOsesG22=("0" \
        )
#G23
GrubOsesG23=("0" \
        "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)" \
        "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda15)" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-686-pae (on /dev/sda18)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-amd64 (on /dev/sda19)" \
        "CentOS Linux 7 (Core) (on /dev/sda6)" \
        "CentOS Linux 7 (Core) (on /dev/sda9)" \
        )
#G25A
GrubOsesG25A=("0" \
        "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)" \
        "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda15)" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-686-pae (on /dev/sda18)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-amd64 (on /dev/sda19)" \
        "Poky (Yocto Project Reference Distro) 2.5 (sumo) (on /dev/sda21)" \
        "Poky (Yocto Project Reference Distro) 2.7.1 (warrior) (on /dev/sda22)" \
        )
#BL51E
GrubOsesBL51E=("0" \
        "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)" \
        "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda15)" \
        "Ubuntu 18.04.3 LTS (18.04) (on /dev/sda16)" \
        "Ubuntu, with Linux 5.0.0-23-generic (on /dev/sda17)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-686-pae (on /dev/sda18)" \
        "Debian GNU/Linux, with Linux 4.19.0-6-amd64 (on /dev/sda19)" \
        )

