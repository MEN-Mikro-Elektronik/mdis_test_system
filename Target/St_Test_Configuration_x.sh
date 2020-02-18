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

mdis_prepare "${TestSummaryDirectory}" "${LogPrefix}"
CmdResult=$?
if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} run_test_case_common_actions: Failed - exit"
        exit "${CmdResult}"
else
        echo "${LogPrefix} run_test_case_common_actions: Success"
fi

echo "${1}" | sudo -S --prompt=$'\r' dmesg --clear

echo "${LogPrefix} Test Setup: ${TestSetup}"
case "${TestSetup}" in
        1)
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "ID_3000"  "${OsNameKernel}" "m65n" "1"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "ID_3010"  "${OsNameKernel}" "m33" "1"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "ID_3020"  "${OsNameKernel}" "m47" "1"
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory}
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M35_M_Module_Test.sh" ${TestSummaryDirectory}
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_F215_Interface_Test.sh" ${TestSummaryDirectory}
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G215_Interface_Test.sh" ${TestSummaryDirectory}
          ;;
        2)
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_F205_M57_M_Module_Test.sh" "${TestSummaryDirectory}" "1"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_M32_M58_M_Module_Test.sh" "${TestSummaryDirectory}"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_M37_M62_M_Module_Test.sh" "${TestSummaryDirectory}"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_F223_Test.sh" "${TestSummaryDirectory}"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_M66_M31_M_Module_Test.sh" "${TestSummaryDirectory}"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_M43_M11_M_Module_Test.sh" "${TestSummaryDirectory}"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_SMB2_Test.sh" "${TestSummaryDirectory}" "smb2_1" "F026L00"
          ;;
        3)
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M77_M_Module_Test.sh" "${TestSummaryDirectory}" "1" "3"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" "${TestSummaryDirectory}"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M36N_M_Module_Test.sh" "${TestSummaryDirectory}"
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M77_M_Module_Test.sh" ${TestSummaryDirectory} "1" "1" #M77Nr, G204Nr
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory}
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory} "2" #second device instance
          ;;
        4)
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G229_Test.sh" "${TestSummaryDirectory}"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M77_M_Module_Test.sh" "${TestSummaryDirectory}" "1" "1"
          #echo ${1} | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M82_M_Module_Test.sh" ${TestSummaryDirectory}
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M72_M_Module_Test.sh" "${TestSummaryDirectory}"
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_SMB2_Test.sh" "${TestSummaryDirectory}" "smb2_1" "G025A03"
          ;;
        5)
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_BL51E_Test.sh" "${TestSummaryDirectory}"
          ;;
        6)
          echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M65_M_Module_Test.sh" "${TestSummaryDirectory}"
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
