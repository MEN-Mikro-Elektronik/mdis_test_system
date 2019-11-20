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

Today=${2}
TestConfiguration="St_Test_Configuration_4"
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

echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G229_Test.sh" ${TestSummaryDirectory}
echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M77_M_Module_Test.sh" ${TestSummaryDirectory} "1" "1"
echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory}
echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M72_M_Module_Test.sh" ${TestSummaryDirectory}
echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_SMB2_Test.sh" ${TestSummaryDirectory} "smb2_1" "G025A03"

echo "Create Test Results summary for Test Configuration 4"
cd "${TestSummaryDirectory}"

SystemInfo="$(uname -a)"
find . -type f -name "${ResultsFileLogName}.tmp" -exec cat {} + > ${ResultsFileLogName}
sed -i "1i${SystemInfo}" ${ResultsFileLogName}
