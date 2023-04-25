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
    TestConfiguration="${TestSetupPrefix}${TEST_SETUP}"
fi

echo "test-setup=${TEST_SETUP}"
echo "date=${Date}"
echo "debug-level=${VERBOSE_LEVEL}"
echo "test-id=${TestId}"
echo "build-mdis=${BuildMdis}"

echo "VERBOSE_LEVEL=${VERBOSE_LEVEL}" | tee -a "${MyDir}/../Common/Conf.sh"
echo "TEST_SETUP=${TEST_SETUP}" | tee -a "${MyDir}/../Common/Conf.sh"

CommitSha="$(get_mdis_sources_commit_sha)"
OsNameKernel="$(get_os_name_with_kernel_ver)"
LogPrefix="[St_Test_Conf]"

echo "${LogPrefix} Testing:  ${TestConfiguration}"
echo "${LogPrefix} Commit SHA: ${CommitSha}"
echo "${LogPrefix} Os Name:  ${OsNameKernel}"

create_directory "${MdisResultsDirectoryPath}" "${LogPrefix}"

cd "${MdisResultsDirectoryPath}" || exit "${ERR_NOEXIST}"

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

TestSummaryDirectory="${MdisResultsDirectoryPath}/${TestConfiguration}/${Date}/${OsNameKernel}"
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

# Check if OS was compiled with CONFIG_DEBUG_KMEMLEAK flag
IsMemLeakOS=$(echo "${OsNameKernel}" | grep -c "kmemleak")

# Clear dmesg log
run_as_root dmesg --clear

echo "${LogPrefix} Test Setup: ${TEST_SETUP}"
    case "${TEST_SETUP}" in
        0)
            run_test_case_id "${TestId}" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        1)
            run_test_case_module "m43n" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m11" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m58" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m32" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m57" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m62n" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_board "105" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # F206 board with Z055 HDLC core
            run_test_case_board "106" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # F401 board with Z051 DAC core
            ;;
        2)
            run_test_case_module "m35n" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m36n" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        3)
            if [ "${IsMemLeakOS}" -gt 0 ]; then
                run_test_case_board "151" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # G229 stress test
            else
                run_test_case_board "1" "1" "${TestSummaryDirectory}" "${OsNameKernel}" "G028" # SMB2_TEST @ G28
                run_test_case_board "103" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
                run_test_case_module "m81" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
                run_test_case_module "m72" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            fi
            ;;
        4)
            run_test_case_board "100" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # F215 board test
            run_test_case_board "104" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # G215 board test
            run_test_case_module "m82" "G204" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m82" "G204" "2" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m99" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m199" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m199_pci" "F205" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        5)
            run_test_case_board "1" "1" "${TestSummaryDirectory}" "${OsNameKernel}" "CB70-" # SMB2_TEST @ CB70
            run_test_case_board "2" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ CB70
            ;;
        6)
            run_test_case_module "m33_sw" "A203N" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m47_sw" "A203N" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            run_test_case_module "m99_sw" "A203N" "1" "${TestSummaryDirectory}" "${OsNameKernel}"
            ;;
        7)
            run_test_case_board "1" "1" "${TestSummaryDirectory}" "${OsNameKernel}" "SC31-" # SMB2_TEST @ BL51
            run_test_case_board "2" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL51
            run_test_case_board "3" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL51
            run_test_case_board "4" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # SMB2_TEST @ BL51
            run_test_case_board "501" "1" "${TestSummaryDirectory}" "${OsNameKernel}" # BL51 fpga ip core tests
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

# Dump all test result data
find . -type f -name "Test_x_*.txt" -exec cat {} + > "${ResultsFileLogName}"
sed -i "1i${SystemInfo}" "${ResultsFileLogName}"

# Once the test has finished, deleting unneeded folders.
# There is no special interesting in binary files.
rm -rf BIN/
rm -rf OBJ/
rm -rf LIB/
rm -rf DESC/
