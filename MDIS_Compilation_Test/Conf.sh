#! /bin/bash
#

# Credentials for Pc that will be tested - required by sudo cmds
MenPcPassword=""

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
MainTestDirectoryName="MDIS_Compilation_Results"
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

LinuxKernelsDirectoryPath="/media/tests/${LinuxKernelsDirectoryName}"
# parent folder in which linux kernel repo is located
TEST_KERNEL_DIR="${LinuxKernelsDirectoryPath}/linux"
# folder of MDIS package, by default /opt/menlinux
export MEN_LIN_DIR="${MdisSourcesDirectoryInstallPath}"

