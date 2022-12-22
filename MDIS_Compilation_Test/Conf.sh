#! /bin/bash
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


# Credentials for Pc that will be tested - required by sudo cmds
MenPcPassword=""

# Credentials, address, and command to download Git repository with 13MD05-90 sources
GitMdisBranch="mad-dev"
GitMdisCmd="git clone --recursive -b ${GitMdisBranch} https://github.com/MEN-Mikro-Elektronik/13MD05-90.git"
# This is optional if specific commit have to be tested !
# If Commit sha is not defined, then the most recent commit on branch is used. 
# Example: 
# GitMdisCommitSha="15fe1dd75ed20209e5a6165876ac4d6953987f55"
GitMdisCommitSha=""

# Directory names that are used during tests
# Directory structure as below:
#       MDIS_Compilation_Test/
#       |-- 13MD05-90
#       |-- 13MD05-90_Install
#       `-- Results
#               |--Commit_xxxx
#               `--Commit_xxxx
#
MainTestDirectoryPath="/media/tests/MDIS_Test"
MdisSourcesDirectoryName="13MD05-90" 
MdisSourcesDirectoryInstall="13MD05-90_Install"
MainTestDirectoryName="MDIS_Compilation"
MdisResultsDirectoryName="Results"
LinuxKernelsDirectoryName="Linux_Kernels"

MakefilesCompilationListShort="MakefilesListShort.log"
MakefilesCompilationListFailed="MakefilesListFailed.log"

MdisMainDirectoryPath="${MainTestDirectoryPath}/${MainTestDirectoryName}"
MdisSourcesDirectoryPath="${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}"
MdisResultsDirectoryPath="${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisResultsDirectoryName}"
MdisSourcesDirectoryInstallPath="${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryInstall}"

# PLEASE check below paths before running compilation tests
# Below paths should be provided by user  

LinuxKernelsDirectoryPath="${MainTestDirectoryPath}/${LinuxKernelsDirectoryName}"
# parent folder in which linux kernel repo is located
TEST_KERNEL_DIR="${LinuxKernelsDirectoryPath}/linux"
# folder of MDIS package, by default /opt/menlinux
export MEN_LIN_DIR="${MdisSourcesDirectoryInstallPath}"

