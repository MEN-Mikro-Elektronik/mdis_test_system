#! /bin/bash

MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/St_Functions.sh
#source "${MyDir}"/Test_Cases.sh
source "${MyDir}"/Mdis_Functions.sh
source "${MyDir}"/Relay_Functions.sh

# This script runs all available test cases for given systen configuration.
# Test cases are described in document: 13MD05-90_xx_xx-JPE-TestReport
# 
# Test should be located in dir -- Test_Summary_commit_xxxx_setup_xx_date

# parameters:
# $1     Men password
# $2     Unique test ID - date
TestSetup=${1}
BuildMdis=${2}
Today=${3}
TestConfiguration="St_Test_Configuration_${TestSetup}"
CommitSha="$(get_mdis_sources_commit_sha)"
OsNameKernel="$(get_os_name_with_kernel_ver)"
LogPrefix="[St_Test_Conf]"

echo "${LogPrefix} Testing:  ${TestConfiguration}"
echo "${LogPrefix} Commit SHA: ${CommitSha}"
echo "${LogPrefix} Os Name:  ${OsNameKernel}"

cd "${MdisResultsDirectoryPath}" || exit "${ERR_NOEXIST}"

CommitSha="Commit_${CommitSha}"

create_directory "${CommitSha}" "${LogPrefix}"
CmdResult=$?
if [ "${CmdResult}" -ne "${ERR_OK}" ] && [ "${CmdResult}" -ne "${ERR_DIR_EXISTS}" ]; then
        exit "${CmdResult}"
fi
cd "${CommitSha}" || exit "${ERR_NOEXIST}"

create_directory "${TestConfiguration}" "${LogPrefix}"
CmdResult=$?
if [ "${CmdResult}" -ne "${ERR_OK}" ] && [ "${CmdResult}" -ne "${ERR_DIR_EXISTS}" ]; then
        exit "${CmdResult}"
fi
cd "${TestConfiguration}" || exit "${ERR_NOEXIST}"

create_directory "${Today}" "${LogPrefix}" || exit "${ERR_NOEXIST}"
CmdResult=$?
if [ "${CmdResult}" -ne "${ERR_OK}" ] && [ "${CmdResult}" -ne "${ERR_DIR_EXISTS}" ]; then
        exit "${CmdResult}"
fi
cd "${Today}" || exit "${ERR_NOEXIST}"

OsNameKernel=$(echo "${OsNameKernel}" | tr -dc '[:alnum:]')
create_directory "${OsNameKernel}" "${LogPrefix}"
CmdResult=$?
if [ "${CmdResult}" -ne "${ERR_OK}" ] && [ "${CmdResult}" -ne "${ERR_DIR_EXISTS}" ]; then
        exit ${CmdResult}
fi
cd "${OsNameKernel}" || exit "${ERR_NOEXIST}"

TestSummaryDirectory="${MdisResultsDirectoryPath}/${CommitSha}/${TestConfiguration}/${Today}/${OsNameKernel}"
cd "${MainTestDirectoryPath}" || exit "${ERR_NOEXIST}"

if [ "${BuildMdis}" -eq "1" ]; then
    mdis_prepare "${TestSummaryDirectory}" "${LogPrefix}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} run_test_case_common_actions: Failed - exit"
        exit "${CmdResult}"
    else
        echo "${LogPrefix} run_test_case_common_actions: Success"
    fi
fi

echo "${1}" | sudo -S --prompt=$'\r' dmesg --clear

echo "${LogPrefix} Test Setup: ${TestSetup}"
case "${TestSetup}" in
        1)
          run_test_case "0100" "${TestSummaryDirectory}" "${OsNameKernel}" #F215 board test
          run_test_case "0102" "${TestSummaryDirectory}" "${OsNameKernel}" #F614 board test
          run_test_case "0200" "${TestSummaryDirectory}" "${OsNameKernel}"
          run_test_case "0201" "${TestSummaryDirectory}" "${OsNameKernel}"
          run_test_case "0202" "${TestSummaryDirectory}" "${OsNameKernel}"
          run_test_case "0203" "${TestSummaryDirectory}" "${OsNameKernel}"
          ;;
        2)
          run_test_case "0103" "${TestSummaryDirectory}" "${OsNameKernel}" #g229 board test
          run_test_case "0104" "${TestSummaryDirectory}" "${OsNameKernel}" #g215 board test
          ;;
        3)
          run_test_case "0101" "${TestSummaryDirectory}" "${OsNameKernel}" #f223 board test
          run_test_case "0204" "${TestSummaryDirectory}" "${OsNameKernel}"
          run_test_case "0205" "${TestSummaryDirectory}" "${OsNameKernel}"
          run_test_case "0206" "${TestSummaryDirectory}" "${OsNameKernel}"
          run_test_case "0207" "${TestSummaryDirectory}" "${OsNameKernel}"
          run_test_case "0208" "${TestSummaryDirectory}" "${OsNameKernel}"
          ;;
        4)
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M77_M_Module_Test.sh" "${TestSummaryDirectory}" "1" "1"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_SMB2_Test.sh" "${TestSummaryDirectory}" "smb2_1" "G025A03"
          ;;
        5)
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_BL51E_Test.sh" "${TestSummaryDirectory}"
          ;;
        6)
          ;;
        *)
          echo "TEST SETUP IS NOT SET"
          exit 99
        ;;
esac

echo "${1}" | sudo -S --prompt=$'\r' bash -c "dmesg > dmesg_log.txt"

echo "Create Test Results summary for TestSetup ${TestSetup}"
cd "${TestSummaryDirectory}" || exit "${ERR_NOEXIST}"

SystemInfo="$(uname -a)"
find . -type f -name "${ResultsFileLogName}.tmp" -exec cat {} + > "${ResultsFileLogName}"
sed -i "1i${SystemInfo}" "${ResultsFileLogName}"
