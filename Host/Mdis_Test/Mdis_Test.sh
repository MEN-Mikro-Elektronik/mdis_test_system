#! /bin/bash

MyDir="$(dirname "$0")"
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/Mdis_Test_Functions.sh"
LogPrefix="[Mdis_Test]"
# This script checks if hardware is present
# Mdis Test run result identification
Today=$(date +%Y_%m_%d_%H_%M_%S)

BuildMdis="1"

### @brief script usage --help
function mdis_test_usage {
    echo "Mdis_Test.sh - tool to functionally test mdis"
    echo ""
    echo "USAGE"
    echo "    Mdis_Test.sh -h | --help"
    echo "    Mdis_Test.sh [--run-instantly] [--verbose=LEVEL] [--print-tests]"
    echo "                 [--run-test=ID] [--run-setup=TEST_SETUP]"
    echo ""
    echo "OPTIONS"
    echo "    --run-instantly"
    echo "        Run all tests specified in Test Setup which is saved in Conf.sh on"
    echo "        curent Target OS"
    echo ""
    echo "    --verbose=LEVEL"
    echo "        Print additional debug info. Possible values for LEVEL are:"
    echo "        0 - default (only general information is written into terminal)"
    echo "        1 - verbose output"
    echo ""
    echo "    --print-test-list"
    echo "        Print list of all possible test cases with brief description"
    echo ""
    echo "    --print-test-brief=ID"
    echo "        Print brief test case description"
    echo ""
    echo "    --run-test=ID"
    echo "        Run specified test (default on all available OS-es)"
    echo ""
    echo "    --run-setup=TEST_SETUP"
    echo "        Run all tests on specified Test Setup (default on all available OS-es)"
    echo ""
    echo "    -h, --help"
    echo "        Print this help"
}

function print_test_list {
    create_test_cases_map
    create_test_setup_test_cases_map "1"
    create_test_setup_test_cases_map "2"
    create_test_setup_test_cases_map "3"
    create_test_setup_test_cases_map "4"
    create_test_setup_test_cases_map "5"
    create_test_setup_test_cases_map "6"
    create_test_setup_test_cases_map "7"
    create_test_setup_test_cases_map "8"
    create_test_setup_test_cases_map "9"
    create_test_setup_test_cases_map "10"
    create_test_setup_test_cases_map "11"

    echo "" > /tmp/test_cases_list.txt
    for K in "${!TEST_CASES_MAP[@]}"
    do
        local TestSetupList=""
        ID=$(printf "%d\n" ${K})

        if [ "${TEST_SETUP_1_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="1,"
        fi
        if [ "${TEST_SETUP_2_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="2,"
        fi
        if [ "${TEST_SETUP_3_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="3,"
        fi
        if [ "${TEST_SETUP_4_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="4,"
        fi
        if [ "${TEST_SETUP_5_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="5,"
        fi
        if [ "${TEST_SETUP_6_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="6,"
        fi
        if [ "${TEST_SETUP_7_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="7,"
        fi
        if [ "${TEST_SETUP_8_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="8,"
        fi
        if [ "${TEST_SETUP_9_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="9,"
        fi
        if [ "${TEST_SETUP_10_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="10,"
        fi
        if [ "${TEST_SETUP_11_TEST_CASES[${K}]}" = "true" ]; then
            TestSetupList+="11,"
        fi
        if [ "${TestSetupList}" = "" ]; then
            TestSetupList+="not used"
        fi
        local Purpose=""
        Purpose=$(print_test_purpose "${ID}")
        echo -e "${ID}\t ${TEST_CASES_MAP[${K}]}\t ${Purpose}\t ${TestSetupList}" >> /tmp/test_cases_list.txt
    done

    sort -n -k1 -o /tmp/test_cases_list.txt  /tmp/test_cases_list.txt
    echo -e "ID\t Description\t Purpose\t Test Setup\n$(</tmp/test_cases_list.txt)" > /tmp/test_cases_list.txt
    column -n /tmp/test_cases_list.txt -ts $'\t'
}

function print_test_purpose {
    local TestId="${1}"
    local Purpose=""
    if [ -z "${TEST_CASES_MAP[${TestId}]}" ]
    then
        echo "Invalid Test ID"
        exit
    fi
    TestPath=$(realpath ../../Target)
    if [ ! -d "${TestPath}" ]
    then
        echo "Dir ${TestPath} does not exists"
        exit
    fi

    if [ "${TestId}" -lt "100" ]
    then
        Board=$(echo "${TEST_CASES_MAP[${TestId}]}")
        source ${TestPath}/SMB2_Tests/${Board}.sh
        Purpose=$(${Board}_description "" "" "")
    elif [ "${TestId}" -lt "200" ]
    then
        Board=$(echo "${TEST_CASES_MAP[${TestId}]}")
        source ${TestPath}/Board_Tests/${Board}.sh
        Purpose=$(${Board}_description "" "" "")
    elif [ "${TestId}" -lt "300" ]
    then
        Module=$(echo "${TEST_CASES_MAP[${TestId}]}" | sed 's/carrier_g204_//')
        source ${TestPath}/Board_Tests/carriers_g204.sh
        source ${TestPath}/M_Modules_Tests/${Module}.sh
        Purpose=$(carrier_g204_TPL_description "${Module}" "<x>" "")
    elif [ "${TestId}" -lt "400" ]
    then
        Module=$(echo "${TEST_CASES_MAP[${TestId}]}" | sed 's/carrier_f205_//')
        source ${TestPath}/Board_Tests/carriers_f205.sh
        source ${TestPath}/M_Modules_Tests/${Module}.sh
        Purpose=$(carrier_f205_TPL_description "${Module}" "<x>" "")
    elif [ "${TestId}" -lt "600" ]
    then
        Board=$(echo "${TEST_CASES_MAP[${TestId}]}")
        source ${TestPath}/BoxPC_Tests/${Board}.sh
        Purpose=$(${Board}_description "" "" "")
    elif [ "${TestId}" -lt "800" ]
    then
        Board=$(echo "${TEST_CASES_MAP[${TestId}]}")
        source ${TestPath}/PanelPC_Tests/${Board}.sh
        Purpose=$(${Board}_description "" "" "")
    fi
    Purpose0=$(echo "${Purpose}" | grep "PURPOSE:" -A 2 | awk 'NR==2' | awk '{$1=$1};1' )
    Purpose1=$(echo "${Purpose}" | grep "PURPOSE:" -A 2 | awk 'NR==3' | awk '{$1=$1};1' )
    Purpose1=$(if ! echo "${Purpose1}" | grep "REQUIREMENT_ID" > /dev/null; then echo "${Purpose1}"; fi)
    Purpose1=$(if ! echo "${Purpose1}" | grep "RESULT" > /dev/null; then echo "${Purpose1}"; fi)
    Purpose="${Purpose0} ${Purpose1}"
    echo "${Purpose}"
}

function print_test_brief {
    local TestId="${1}"
    create_test_cases_map
    if [ -z "${TEST_CASES_MAP[${TestId}]}" ]
    then
        echo "Invalid Test ID"
        exit
    fi
    TestPath=$(realpath ../../Target)
    if [ ! -d "${TestPath}" ]
    then
        echo "Dir ${TestPath} does not exists"
        exit
    fi

    echo ""
    if [ "${TestId}" -lt "100" ]
    then
        Board=$(echo "${TEST_CASES_MAP[${TestId}]}")
        source ${TestPath}/SMB2_Tests/${Board}.sh
        ${Board}_description "" "" "" "long_description"
    elif [ "${TestId}" -lt "200" ]
    then
        Board=$(echo "${TEST_CASES_MAP[${TestId}]}")
        source ${TestPath}/Board_Tests/${Board}.sh
        ${Board}_description "" "" "" "long_description"
    elif [ "${TestId}" -lt "300" ]
    then
        Module=$(echo "${TEST_CASES_MAP[${TestId}]}" | sed 's/carrier_g204_//')
        source ${TestPath}/Board_Tests/carriers_g204.sh
        source ${TestPath}/M_Modules_Tests/${Module}.sh
        carrier_g204_TPL_description "${Module}" "<x>" "" "long_description"
    elif [ "${TestId}" -lt "400" ]
    then
        Module=$(echo "${TEST_CASES_MAP[${TestId}]}" | sed 's/carrier_f205_//')
        source ${TestPath}/Board_Tests/carriers_f205.sh
        source ${TestPath}/M_Modules_Tests/${Module}.sh
        carrier_f205_TPL_description "${Module}" "<x>" "" "long_description"
    elif [ "${TestId}" -lt "600" ]
    then
        Board=$(echo "${TEST_CASES_MAP[${TestId}]}")
        source ${TestPath}/BoxPC_Tests/${Board}.sh
        ${Board}_description "" "" "" "long_description"
    elif [ "${TestId}" -lt "800" ]
    then
        Board=$(echo "${TEST_CASES_MAP[${TestId}]}")
        source ${TestPath}/PanelPC_Tests/${Board}.sh
        ${Board}_description "" "" "" "long_description"
    fi
}

VERBOSE_LEVEL="0"
TEST_SETUP="0"
# read parameters
while test $# -gt 0 ; do
    case "$1" in
        -h|--help)
            mdis_test_usage
            exit 0
            ;;
        --run-instantly)
            shift
            RUN_INSTANTLY="1"
            ;;
        --verbose*)
            VERBOSE_LEVEL="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            shift
            ;;
        --print-test-list)
            print_test_list
            exit 0
            ;;
        --print-test-brief*)
            TEST_ID="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            print_test_brief "${TEST_ID}"
            exit 0
            ;;
        --run-test*)
            RUN_TEST_ID="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            shift
            ;;
        --run-setup*)
            TEST_SETUP="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            shift
            ;;
        *)
            echo "No valid parameters"
            echo "./Mdis_Test.sh --help"
            exit 0
            break
            ;;
        esac
done

echo "VERBOSE_LEVEL=${VERBOSE_LEVEL}" | tee -a "${MyDir}/../../Common/Conf.sh"
echo "TEST_SETUP=${TEST_SETUP}" | tee -a "${MyDir}/../../Common/Conf.sh"

echo "Test Setup: ${TEST_SETUP}"
case ${TEST_SETUP} in
    0)
        GrubOses=( "0" ) #What oses should be run?
        ;;
    1)
        GrubOses=( "${GrubOsesF26L[@]}" )
        ;;
    2)
        GrubOses=( "${GrubOsesF23P[@]}" )
        ;;
    3)
        GrubOses=( "${GrubOsesG23[@]}" )
        ;;
    4)
        GrubOses=( "${GrubOsesG25A[@]}" )
        ;;
    5)
        GrubOses=( "${GrubOsesF23P[@]}" )
        ;;
    6)
        GrubOses=( "${GrubOsesCB70[@]}" )
        ;;
    7)
        GrubOses=( "${GrubOsesA25[@]}" )
        ;;
    8)
        GrubOses=( "${GrubOsesBL50[@]}" )
        ;;
    9)
        GrubOses=( "${GrubOsesBL51E[@]}" )
        ;;
    10)
        GrubOses=( "${GrubOsesBL70[@]}" )
        ;;
    11)
        GrubOses=( "${GrubOsesDC19[@]}" )
        ;;
    *)
        echo "TEST SETUP IS NOT SET"
        exit 99
        ;;
esac

echo "GrubOses: ${GrubOses}"

MdisTestBackgroundPID=0

trap cleanOnExit SIGINT SIGTERM
function cleanOnExit() {
    echo "${LogPrefix} ** cleanOnExit - signal"
    if [ ${MdisTestBackgroundPID} -ne 0 ]; then
        # Kill process
        echo "${LogPrefix} kill process ${MdisTestBackgroundPID}"

        if ! kill ${MdisTestBackgroundPID} 2>/dev/null
        then
            echo "${LogPrefix} Could not kill cat backgroung process ${MdisTestBackgroundPID}"
        else
            echo "${LogPrefix} process ${MdisTestBackgroundPID} killed"
        fi
        sleep 1
        jobs
    fi
    grub_set_os "0"
    exit
}

function cleanMdisTestBackgroundJob {
    echo "${LogPrefix} ** cleanOnExit"
    if [ ${MdisTestBackgroundPID} -ne 0 ]; then
        # Invoking kill -0 only checks if the process is still running.
        if kill -0 ${MdisTestBackgroundPID} >/dev/null 2>&1; then
            # Kill process
            echo "${LogPrefix} kill process ${MdisTestBackgroundPID}"

            if ! kill  ${MdisTestBackgroundPID}
            then
                echo "${LogPrefix} Could not kill cat backgroung process ${MdisTestBackgroundPID}"
            else
                echo "${LogPrefix} process ${MdisTestBackgroundPID} killed"
                wait ${MdisTestBackgroundPID}
                MdisTestBackgroundPID=0
            fi
            sleep 1
            jobs
        fi
    fi
}

function runTests {
    # run
    St_Test_Configuration="St_Test_Configuration_x.sh"
    echo "run:"
    echo "${St_Test_Configuration} ${TEST_SETUP}"

    # Make all scripts executable
    run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt=$'\r' chmod +x ${GitTestCommonDirPath}/*"
    run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt=$'\r' chmod +x ${GitTestTargetDirPath}/*"
    run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt=$'\r' chmod +x ${GitTestHostDirPath}/*"

    ./Mdis_Test_Background.sh &

    # Save background process PID
    MdisTestBackgroundPID=$!
    echo "${LogPrefix} MdisTestBackgroundPID is ${MdisTestBackgroundPID}"

    # Run Test script - now scripts from remote device should be run
    make_visible_in_log "TEST CASE - ${St_Test_Configuration} ${TEST_SETUP}"
    if ! run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt=$'\r' ${GitTestTargetDirPath}/${St_Test_Configuration} --test-setup=${TEST_SETUP}\
                                                                                                                               --date=${Today}\
                                                                                                                               --debug-level=${VERBOSE_LEVEL}\
                                                                                                                               --build-mdis\
                                                                                                                               --test-id=${RUN_TEST_ID}"
    then
        echo "${LogPrefix} Error while running St_Test_Configuration_x.sh script"
    fi

    cleanMdisTestBackgroundJob
    # Initialize tested device 
    # run_cmd_on_remote_pc "mkdir $TestCaseDirectoryName"
    # Below command must be run from local device, 
    # Test scripts have not been downloaded into remote yet.
}

# MAIN start here
create_test_cases_map
if [ "${RUN_INSTANTLY}" == "1" ]; then
    ssh-keygen -R "${MenPcIpAddr}"
    # Check if devices are available
    if ! ping -c 2 "${MenPcIpAddr}"
    then
        echo "${MenPcIpAddr} is not responding"
    fi

    cat "${MyDir}/../../Common/Conf.sh" > tmp.sh
    echo "RUN_INSTANTLY=\"1\"" >> tmp.sh
    cat "${MyDir}"/Pc_Configure.sh >> tmp.sh

    if ! run_script_on_remote_pc "${MyDir}"/tmp.sh
    then
        echo "${LogPrefix} Pc_Configure script failed"
        exit
    fi
    rm tmp.sh

    runTests
else
    grub_set_os "0"
    for ExpectedOs in "${GrubOses[@]}"; do
        ssh-keygen -R "${MenPcIpAddr}"
        # Check if devices are available
        if ! ping -i 5 -c 4  "${MenPcIpAddr}"
        then
            echo "${MenPcIpAddr} is not responding"
            break
        fi
        CurrentOs="$(grub_get_os)"
        if [ "${CurrentOs}" == "" ]; then
            echo "Failed to get OS"
            break
        fi
        if [ "${CurrentOs}" == "${ExpectedOs}" ]; then
            if [ "${ExpectedOs}" == "${GrubOses[0]}" ]; then
                continue
            fi
            echo "Unexpected OS \"${CurrentOs}\" while \"${ExpectedOs}\" was expected"
            break
        fi
        grub_set_os "${ExpectedOs}"
        SetOs="$(grub_get_os)"
        if [ "${SetOs}" != "${ExpectedOs}" ]; then
            echo "Failed to set OS"
            break
        fi
        if ! reboot_and_wait
        then
            echo "${MenPcIpAddr} is not responding"
            break
        fi
        ssh-keygen -R "${MenPcIpAddr}"

        cat "${MyDir}/../../Common/Conf.sh" "${MyDir}"/Pc_Configure.sh > tmp.sh
        if ! run_script_on_remote_pc "${MyDir}"/tmp.sh
        then
            echo "${LogPrefix} Pc_Configure script failed"
            exit
        fi

        rm tmp.sh
        runTests
    done
fi
# Retrieve the test results
downloadTestResults "${MdisResultsDirectoryPath}" "${MyDir}/${MainTestDirectoryName}" "${TEST_SETUP}" "${Today}" "${LogPrefix}"

# Process the test results
processTestResults "${MyDir}/${MainTestDirectoryName}" "${TEST_SETUP}" "${Today}" "${LogPrefix}"

cleanOnExit
