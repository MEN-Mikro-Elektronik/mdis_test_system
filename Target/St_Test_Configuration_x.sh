#! /bin/bash

MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/St_Functions.sh"

# This script runs all available test cases for given systen configuration.
# Test cases are described in document: 13MD05-90_xx_xx-JPE-TestReport
# 
# Test should be located in dir -- Test_Summary_commit_xxxx_setup_xx_date

# parameters:
# $1     Men password
# $2     Unique test ID - date
TestSetup=${1}
Today=${3}
TestConfiguration="St_Test_Configuration_${TestSetup}"
CommitSha="$(get_mdis_sources_commit_sha)"
OsNameKernel="$(get_os_name_with_kernel_ver)"

echo "Testing:  ${TestConfiguration}"
echo "Commit SHA: ${CommitSha}"
echo "Os Name:  ${OsNameKernel}"

cd "${MdisResultsDirectoryPath}"

CommitSha="Commit_${CommitSha}"

create_directory "${CommitSha}"
CmdResult=$?
if [ ${CmdResult} -ne "${ERR_OK}" ] && [ ${CmdResult} -ne ${ERR_DIR_EXISTS} ]; then
        exit ${CmdResult}
fi
cd "${CommitSha}"

create_directory "${TestConfiguration}"
CmdResult=$?
if [ ${CmdResult} -ne ${ERR_OK} ] && [ ${CmdResult} -ne ${ERR_DIR_EXISTS} ]; then
        exit ${CmdResult}
fi
cd "${TestConfiguration}"

create_directory "${Today}"
CmdResult=$?
if [ ${CmdResult} -ne ${ERR_OK} ] && [ ${CmdResult} -ne ${ERR_DIR_EXISTS} ]; then
        exit ${CmdResult}
fi
cd "${Today}"

OsNameKernel=$(echo "${OsNameKernel}" | tr -dc '[:alnum:]')
create_directory "${OsNameKernel}"
CmdResult=$?
if [ ${CmdResult} -ne ${ERR_OK} ] && [ ${CmdResult} -ne ${ERR_DIR_EXISTS} ]; then
        exit ${CmdResult}
fi
cd "${OsNameKernel}"

TestSummaryDirectory="${MdisResultsDirectoryPath}/${CommitSha}/${TestConfiguration}/${Today}/${OsNameKernel}"
cd "${MainTestDirectoryPath}"

mdis_prepare ${TestSummaryDirectory}
CmdResult=$?
if [ ${CmdResult} -ne ${ERR_OK} ]; then
        echo "run_test_case_common_actions: Failed - exit"
        exit ${CmdResult}
else
        echo "run_test_case_common_actions: Success"
fi

echo ${1} | sudo -S --prompt=$'\r' dmesg --clear

echo "Test Setup: ${TestSetup}"
case ${TestSetup} in
        1)
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory}
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M35_M_Module_Test.sh" ${TestSummaryDirectory}
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_F215_Interface_Test.sh" ${TestSummaryDirectory}
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_M66_M31_M_Module_Test.sh" ${TestSummaryDirectory}
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G215_Interface_Test.sh" ${TestSummaryDirectory}
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M33_M_Module_Test.sh" ${TestSummaryDirectory}
          ;;
        2)
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_F223_Test.sh" ${TestSummaryDirectory}
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M77_M_Module_Test.sh" ${TestSummaryDirectory} "1" "1" #M77Nr, G204Nr
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory}
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory} "2" #second device instance
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_M43_M11_M_Module_Test.sh" ${TestSummaryDirectory}
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_SMB2_Test.sh" ${TestSummaryDirectory} "smb2_1" "F026L00"
          ;;
        3)
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M77_M_Module_Test.sh" ${TestSummaryDirectory} "1" "3"
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory}
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M36N_M_Module_Test.sh" ${TestSummaryDirectory}
          ;;
        4)
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G229_Test.sh" ${TestSummaryDirectory}
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M77_M_Module_Test.sh" ${TestSummaryDirectory} "1" "1"
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory}
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M72_M_Module_Test.sh" ${TestSummaryDirectory}
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_SMB2_Test.sh" ${TestSummaryDirectory} "smb2_1" "G025A03"
          ;;
        5)
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_BL51E_Test.sh" ${TestSummaryDirectory}
          ;;
        6)
          echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M65_M_Module_Test.sh" ${TestSummaryDirectory}
          ;;
        *)
          echo "TEST SETUP IS NOT SET"
          exit 99
        ;;
esac

echo ${1} | sudo -S --prompt=$'\r' bash -c "dmesg > dmesg_log.txt"

echo "Create Test Results summary for TestSetup ${TestSetup}"
cd "${TestSummaryDirectory}"

SystemInfo="$(uname -a)"
find . -type f -name "${ResultsFileLogName}.tmp" -exec cat {} + > ${ResultsFileLogName}
sed -i "1i${SystemInfo}" ${ResultsFileLogName}
