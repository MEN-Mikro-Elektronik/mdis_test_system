#! /bin/bash

MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/St_Functions.sh
source "${MyDir}"/Mdis_Functions.sh
source "${MyDir}"/Relay_Functions.sh

# This script runs mdis tests

TestSetup="0"
Date="_2020"
VERBOSE_LEVEL="0"
TestId="0"
BuildMdis="0"

while test $# -gt 0 ; do
    case "$1" in
        --test-setup*)
            TEST_SETUP="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            shift
            ;;
        --date*)
            Date="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            shift
            ;;
        --debug-level*)
            VERBOSE_LEVEL="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            shift
            ;;
        --test-id*)
            TestId="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            shift
            ;;
        --build-mdis)
            BuildMdis="1"
            shift
            ;;
        *)
            echo "No valid parameters"
            break
            ;;
        esac
done

if [ "${TestSetup}" -eq "0" ]; then
    if [ "${TestId}" -ne "0" ]; then
        TestConfiguration="St_Test_Id_${TestId}"
    else
        echo "Wrong parameters:"
        echo "TestSetup: ${TestSetup}"
        echo "TestId: ${TestId}"
        exit "${ERR_VALUE}"
    fi
else
    TestConfiguration="St_Test_Setup_${TestSetup}"
fi

echo "test-setup=${TestSetup}"
echo "date=${Date}"
echo "debug-level=${VERBOSE_LEVEL}"
echo "test-id=${TestId}"
echo "build-mdis=${BuildMdis}"

run_as_root echo "VERBOSE_LEVEL=${VERBOSE_LEVEL}" | tee -a "${MyDir}/../Common/Conf.sh"
run_as_root echo "TEST_SETUP=${TEST_SETUP}" | tee -a "${MyDir}/../Common/Conf.sh"

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

create_directory "${Date}" "${LogPrefix}" || exit "${ERR_NOEXIST}"
CmdResult=$?
if [ "${CmdResult}" -ne "${ERR_OK}" ] && [ "${CmdResult}" -ne "${ERR_DIR_EXISTS}" ]; then
    exit "${CmdResult}"
fi
cd "${Date}" || exit "${ERR_NOEXIST}"

OsNameKernel=$(echo "${OsNameKernel}" | tr -dc '[:alnum:]')
create_directory "${OsNameKernel}" "${LogPrefix}"
CmdResult=$?
if [ "${CmdResult}" -ne "${ERR_OK}" ] && [ "${CmdResult}" -ne "${ERR_DIR_EXISTS}" ]; then
    exit ${CmdResult}
fi
cd "${OsNameKernel}" || exit "${ERR_NOEXIST}"

TestSummaryDirectory="${MdisResultsDirectoryPath}/${CommitSha}/${TestConfiguration}/${Date}/${OsNameKernel}"
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

if ! rmmod_all_men_modules
then
    echo "${LogPrefix} Could not rmmmod all MEN modules !"
fi

# Clear dmesg log
run_as_root dmesg --clear

echo "${LogPrefix} Test Setup: ${TestSetup}"
    case "${TestSetup}" in
        0)
            run_test_case "${TestId}" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        1)
            run_test_case "0100" "${TestSummaryDirectory}" "${OsNameKernel}" #F215 board test
            run_test_case "0102" "${TestSummaryDirectory}" "${OsNameKernel}" #F614 board test
            run_test_case "0200" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case "0201" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case "0202" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case "0300" "${TestSummaryDirectory}" "${OsNameKernel}"
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
            #echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_G204_M77_M_Module_Test.sh" "${TestSummaryDirectory}" "1" "1"
            #echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_SMB2_Test.sh" "${TestSummaryDirectory}" "smb2_1" "G025A03"
            ;;
        5)
            #echo "${1}" | sudo -S --prompt=$'\r' "${MyDir}/ST_xxxx_BL51E_Test.sh" "${TestSummaryDirectory}"
            ;;
        6)
            ;;
        *)
            echo "TEST SETUP OR TEST ID IS NOT SET PROPERLY"
            exit 99
            ;;
    esac

if ! rmmod_all_men_modules
then
    echo "${LogPrefix} Could not rmmmod all MEN modules !"
fi

# Save dmesg log
run_as_root bash -c "dmesg > dmesg_log.txt"

echo "Create Test Results summary for TestSetup ${TestSetup}"
cd "${TestSummaryDirectory}" || exit "${ERR_NOEXIST}"

SystemInfo="$(uname -a)"
find . -type f -name "${ResultsFileLogName}.tmp" -exec cat {} + > "${ResultsFileLogName}"
sed -i "1i${SystemInfo}" "${ResultsFileLogName}"
