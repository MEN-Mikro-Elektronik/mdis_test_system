#! /bin/bash

MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/St_Functions.sh
source "${MyDir}"/Mdis_Functions.sh
source "${MyDir}"/Relay_Functions.sh

# This script runs mdis tests

TEST_SETUP="0"
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

if [ "${TEST_SETUP}" -eq "0" ]; then
    if [ "${TestId}" -ne "0" ]; then
        TestConfiguration="St_Test_Id_${TestId}"
    else
        echo "Wrong parameters:"
        echo "TestSetup: ${TEST_SETUP}"
        echo "TestId: ${TestId}"
        exit "${ERR_VALUE}"
    fi
else
    TestConfiguration="St_Test_Setup_${TEST_SETUP}"
fi

echo "test-setup=${TEST_SETUP}"
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

create_directory "${Date}" "${LogPrefix}"
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

echo "${LogPrefix} Test Setup: ${TEST_SETUP}"
    case "${TEST_SETUP}" in
        0)
            run_test_case_id "${TestId}" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        1)
            run_test_case_board "100" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # F215 board test
            run_test_case_board "104" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # G215 board test
            run_test_case_module "m65n_canopen" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m65n" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m77" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m33" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m47" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        2)
            run_test_case_board "102" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # F614 @ F23P
            run_test_case_board "101" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # F223
            run_test_case_module "m43n" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m11" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m66" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m31" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m32" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m58" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m37n" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m62n" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m57" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        3)
            run_test_case_module "m35n" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m36n" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        4)
            run_test_case_board "1" "1" "${TestSummaryDirectory}" "${OsNameKernel}" "G025A03" # SMB2_TEST @ G25A03
            run_test_case_board "103" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m81" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m72" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        5)
            run_test_case_board "105" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # F206 board with Z055 HDLC core
            run_test_case_module "m82" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m82" "G204" "2" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m99" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m199" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        6)
            run_test_case_board "1" "1" "${TestSummaryDirectory}" "${OsNameKernel}" "CB70-00" # SMB2_TEST @ CB70
            run_test_case_board "2" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ CB70
            ;;
        7)
            # Manual tests
            ;;
        8)
            run_test_case_board "1" "1" "${TestSummaryDirectory}" "${OsNameKernel}" "SC24-08" # SMB2_TEST @ BL50
            run_test_case_board "2" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL50
            run_test_case_board "3" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL50
            run_test_case_board "4" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL50
            run_test_case_board "500" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # BL50 fpga ip core tests
            ;;
        9)
            run_test_case_board "1" "1" "${TestSummaryDirectory}" "${OsNameKernel}" "SC31-01" # SMB2_TEST @ BL51
            run_test_case_board "2" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL51
            run_test_case_board "3" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL51
            run_test_case_board "4" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL51
            run_test_case_board "501" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # BL51 fpga ip core tests
            ;;
        10)
            run_test_case_board "1" "1" "${TestSummaryDirectory}" "${OsNameKernel}" "SC25-00" # SMB2_TEST @ BL70
            run_test_case_board "2" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL70
            run_test_case_board "3" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL70
            run_test_case_board "4" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL70
            run_test_case_board "5" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL70
            run_test_case_board "502" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # BL70 fpga ip core tests
            ;;
        11)
            run_test_case_board "102" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # F614 @ F23P
            echo "Dummy test setup"
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

echo "Create Test Results summary for TEST_SETUP ${TEST_SETUP}"
cd "${TestSummaryDirectory}" || exit "${ERR_NOEXIST}"

SystemInfo="$(uname -a)"
SystemInfoVerbose="$(cat /etc/os-release)"
GCCInfo="$(gcc --version)"

echo "${SystemInfo}" > System_info.txt
echo "${SystemInfoVerbose}" >> System_info.txt
echo "${GCCInfo}" >> System_info.txt
echo "${Date}" > Source_info.txt
echo "${CommitSha}" >> Source_info.txt

find . -type f -name "${ResultsFileLogName}.tmp" -exec cat {} + > "${ResultsFileLogName}"
sed -i "1i${SystemInfo}" "${ResultsFileLogName}"
