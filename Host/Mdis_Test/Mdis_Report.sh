#!/bin/bash
MyDir="$(dirname "$0")"
source "${MyDir}/../../Common/Conf.sh"

ResultPath="${1}"
ResultTestSetup=""

declare -a TEST_OS
declare -a TEST_REQ
declare -A TEST_RESULT_OS

# List of available OS-es
TEST_RESULT_OS["1"]="Ubuntu1804350023genericx8664"
TEST_RESULT_OS["2"]="Ubuntu18043415060generici686"
TEST_RESULT_OS["3"]="Ubuntu200454026genericx8664"
TEST_RESULT_OS["4"]="DebianGNULinux41906amd64x8664"
TEST_RESULT_OS["5"]="DebianGNULinux41906686paei686"
TEST_RESULT_OS["6"]="CentOSLinux31001062el7x8664x8664"
TEST_RESULT_OS["7"]="CentOSLinux4180147el8x8664x8664"

declare -a TEST_RESULT_OS_1=(_ _ _ _ _)
declare -a TEST_RESULT_OS_2=(_ _ _ _ _)
declare -a TEST_RESULT_OS_3=(_ _ _ _ _)
declare -a TEST_RESULT_OS_4=(_ _ _ _ _)
declare -a TEST_RESULT_OS_5=(_ _ _ _ _)
declare -a TEST_RESULT_OS_6=(_ _ _ _ _)
declare -a TEST_RESULT_OS_7=(_ _ _ _ _)
declare -a TEST_RESULTS_GROUP=("TEST_RESULT_OS_1" "TEST_RESULT_OS_2" "TEST_RESULT_OS_3" "TEST_RESULT_OS_4" "TEST_RESULT_OS_5"  "TEST_RESULT_OS_6" "TEST_RESULT_OS_7")

### @brief script usage --help
function mdis_report_usage {
    echo "Mdis_Report.sh - generate MDIS results in user friendly format"
    echo ""
    echo "USAGE"
    echo "    Mdis_Report.sh -h | --help"
    echo "    Mdis_Report.sh <RESULT_PATH> [--test-setup=SETUP] [--tester-name=NAME]"
    echo ""
    echo "DESCRIPTION"
    echo "    Generate MDIS results for user specified test setup"
    echo ""
    echo "OPTIONS"
    echo "    RESULT_PATH"
    echo "        Path to Mdis_Test result directory."
    echo "        Provide dir to exact test setup result location: ../Test_Setup_1"
    echo ""
    echo "    --test-setup=SETUP"
    echo "        Print results for specified test setup"
    echo ""
    echo "    --tester-name=NAME"
    echo "        Person responsible for testing"
    echo ""
    echo "    -h, --help"
    echo "        Print this help"
}
case "${ResultPath}" in
        -h|--help)
            mdis_report_usage
            exit 0
            ;;
esac

if [ ! -d "${ResultPath}" ]; then
    echo "Invalid result path"
    exit 1
fi

shift

# read parameters
while test $# -gt 0 ; do
    case "$1" in
        -h|--help)
            mdis_report_usage
            exit 0
            ;;
        --test-setup*)
            ResultTestSetup="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            shift
            ;;
        --tester-name*)
            TesterName="$(echo "$1" | sed -e 's/^[^=]*=//g')"
            shift
            ;;
        *)
            echo "No valid parameters"
            echo "run Mdis_Report.sh --help"
            exit 0
            ;;
        esac
done

function set_result_os {
    local TestSetup=${1}
    #index start at 0
    TestSetup=$((TestSetup-1))
    local OSName=${2}
    local Result=${3}

    if [ "${OSName}" = "${TEST_RESULT_OS[1]}" ]; then
        TEST_RESULT_OS_1["${TestSetup}"]="${Result}"
    elif [ "${OSName}" = "${TEST_RESULT_OS[2]}" ]; then
        TEST_RESULT_OS_2["${TestSetup}"]="${Result}"
    elif [ "${OSName}" = "${TEST_RESULT_OS[3]}" ]; then
        TEST_RESULT_OS_3["${TestSetup}"]="${Result}"
    elif [ "${OSName}" = "${TEST_RESULT_OS[4]}" ]; then
        TEST_RESULT_OS_4["${TestSetup}"]="${Result}"
    elif [ "${OSName}" = "${TEST_RESULT_OS[5]}" ]; then
        TEST_RESULT_OS_5["${TestSetup}"]="${Result}"
    elif [ "${OSName}" = "${TEST_RESULT_OS[6]}" ]; then
        TEST_RESULT_OS_6["${TestSetup}"]="${Result}"
    elif [ "${OSName}" = "${TEST_RESULT_OS[7]}" ]; then
        TEST_RESULT_OS_7["${TestSetup}"]="${Result}"
    else
        echo "OS NOT SPECIFIED"
        exit 1
    fi
}

function print_requirements {
    local TestCase=${1}
    local ReqCnt=${2}
    local ReqLineCnt=1
    local Req="VALID"
    while [ "${Req}" != "INVALID" ]
    do  
        ReqLineCnt=$((ReqLineCnt+1))
        Req=$(grep -A 15 "REQUIREMENT_ID:" < "${TestCase}" | awk NR==${ReqLineCnt} )
        if [ "${Req}" != "RESULTS" ] && [ "${Req}" != "" ]
        then
            TEST_REQ[${ReqCnt}]="${Req}"
            ReqCnt=$((ReqCnt+1))
        else
            Req="INVALID"
        fi
    done
    echo "$((ReqLineCnt-1))"
}

function print_results {
    local ResultPath="${1}"
    local ResultTestSetup="${2}"
    local OSCnt=0
    local OSNo=0
    local TestDate=""
    local CommitID=""
    local SourceInfo=""
    if [ -z "${ResultPath}" ] || [ -z "${ResultTestSetup}" ]
    then
        echo "Please specify Result Path for and Result Test Setup"
        exit 1
    fi

    SourceInfo=$(find "${ResultPath}" -name "Source_info.txt" | awk 'NR==1')
    TestDate=$(awk 'NR==1' < "${SourceInfo}")
    CommitID=$(awk 'NR==2' < "${SourceInfo}")
    rm results.txt
    touch results.txt
    echo "Date: ${TestDate}"
    echo "Tester Name: ${TesterName}"
    echo "${CommitID}"

    echo "Get brief test case description (cmd):"
    echo "./Mdis_Test.sh --print-test-brief=<Test_Case_ID>"
    echo ""
    echo "Run test cases on configured environment!"
    echo "./Mdis_Test.sh --run-test=<Test_Case_ID>"
    echo "./Mdis_Test.sh --run-setup=<Test_Setup>                 #On all configured OSes"
    echo "./Mdis_Test.sh --run-instantly --run-setup=<Test_Setup> #Single OS"
    echo ""

    create_test_cases_map

    echo "Id|Requirement|Description(firstline)|OS|Test Setup" >> results.txt
    echo "||Purpose||${ResultTestSetup}" >> results.txt
    ResultTestSetup=$((ResultTestSetup-1))

    echo "|||" >> results.txt
    #($(echo "${ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    for K in "${!TEST_CASES_MAP[@]}"
    do
        # Obtain results directory
        find "${ResultPath}" -name "${K}.tmp" > "${K}_file_list.log"

        while IFS= read -r file
        do
            local TEST_SETUP_FILE
            TEST_SETUP_FILE=$(grep "Test_Setup:" "${file}" | awk '{print $3}')
            if [ "${TEST_SETUP_FILE}" -eq $((ResultTestSetup+1)) ]
            then
                echo "${file}" >> "${K}_${TEST_SETUP_FILE}_file_list.log"
            fi
        done < "${K}_file_list.log"
        ReqCnt=0
        TEST_SETUP_FILE=$((ResultTestSetup+1))
        if test -f "${K}_${TEST_SETUP_FILE}_file_list.log"
        then
            mv "${K}_${TEST_SETUP_FILE}_file_list.log" "${K}_file_list.log"
            #TestCaseCnt=$(grep -c "${K}.tmp" "${K}_file_list.log")
            #echo "TestCaseCnt: ${TestCaseCnt}"
            OSCnt=0
            #OSNo=$(< "${K}_file_list.log" wc -l)
            OSItr=0

            while IFS= read -r file
            do
                OSItr=$((OSItr+1))
                TEST_OS["${OSItr}"]=$( grep "Test_Os" "${file}" | awk '{print $3}' | awk '{$1=$1};1' )
            done < "${K}_file_list.log"

            OSNo=$(echo "${TEST_OS[@]}" | tr ' ' '\n' | sort -u | wc -l)
            unset TEST_OS

            while IFS= read -r file
            do
                OSCnt=$((OSCnt+1))
                TEST_DESCRIPTION_SHORT=$(grep "DESCRIPTION:" -A 1 "${file}" | awk 'NR==2' | awk '{$1=$1};1')
                TEST_PURPOSE0=$(grep "PURPOSE:" -A 2 "${file}" | awk 'NR==2' | awk '{$1=$1};1' )
                TEST_PURPOSE1=$(grep "PURPOSE:" -A 2 "${file}" | awk 'NR==3' | awk '{$1=$1};1' )
                TEST_PURPOSE1=$(if ! echo "${TEST_PURPOSE1}" | grep "REQUIREMENT_ID" > /dev/null; then echo "${TEST_PURPOSE1}"; fi)
                TEST_PURPOSE1=$(if ! echo "${TEST_PURPOSE1}" | grep "RESULT" > /dev/null; then echo "${TEST_PURPOSE1}"; fi)
                TEST_ID=$(grep "Test_ID" "${file}" | awk '{print $3}' | awk '{$1=$1};1')
                TEST_OS_FULL=$(grep "Test_Os" "${file}" | awk '{print $3}' | awk '{$1=$1};1')
                print_requirements "${file}" "${ReqCnt}" > /dev/null
                TEST_REQ=($(echo "${TEST_REQ[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
                ReqCnt=$(echo "${TEST_REQ[@]}" | tr ' ' '\n' | wc -l)
                TEST_SETUP=$(grep "Test_Setup" "${file}" | awk '{print $3}' | awk '{$1=$1};1')
                TEST_RESULTS=$(grep "Test_Result" "${file}" | awk '{print $2 $3}' | awk '{$1=$1};1')
                TEST_INSTANCE=$(grep "Test_Instance" "${file}" | awk '{print $3}' | awk '{$1=$1};1')
                TEST_RESULTS=$(if echo "${TEST_RESULTS}" | grep "SUCCESS" > /dev/null; then echo "SUCCESS"; else echo "FAIL"; fi)
                #TEST_FNC_DESCRIPTION="${TEST_CASES_MAP[${K}]}_test()"
                set_result_os "${TEST_SETUP}" "${TEST_OS_FULL}" "${TEST_RESULTS}"
                if [ "${OSCnt}" -eq "${OSNo}" ]; then
                    local LineCntLoop=0
                    local LineCnt=0
                    # At least 3 lines per test cases are printed
                    echo -e "${TEST_ID}|${TEST_REQ["0"]}|${TEST_DESCRIPTION_SHORT}|${TEST_RESULT_OS["1"]}|${TEST_RESULT_OS_1[${ResultTestSetup}]}" >> "${TEST_ID}"_"${TEST_INSTANCE}"_results.txt
                    echo -e "|${TEST_REQ["1"]}|${TEST_PURPOSE0}|${TEST_RESULT_OS["2"]}|${TEST_RESULT_OS_2[${ResultTestSetup}]}" >> "${TEST_ID}"_"${TEST_INSTANCE}"_results.txt
                    echo -e "|${TEST_REQ["2"]}|${TEST_PURPOSE1}|${TEST_RESULT_OS["3"]}|${TEST_RESULT_OS_3[${ResultTestSetup}]}" >> "${TEST_ID}"_"${TEST_INSTANCE}"_results.txt
                    # loop through all test Requirements / all operating system
                    ReqCnt=$((ReqCnt))
                    OSCnt=$((OSCnt))
                    if [ "${ReqCnt}" -lt "${OSCnt}" ]; then
                        LineCnt=$((OSCnt))
                    else
                        LineCnt=$((ReqCnt))
                    fi
                    if [ "${LineCnt}" -gt 3 ]; then
                        LineCntLoop=$((LineCnt-3))
                        for i in $(seq 1 ${LineCntLoop})
                        do
                            local GroupArrayIdx=$((i+3))
                            local RealArrayName="TEST_RESULT_OS_${GroupArrayIdx}"
                            local RealArrayIdx="${ResultTestSetup}"
                            local RealArrayValue=${RealArrayName}[RealArrayIdx]
                            echo -e "|${TEST_REQ["$((i+2))"]}||${TEST_RESULT_OS[$((i+3))]}|${!RealArrayValue}" >> "${TEST_ID}"_"${TEST_INSTANCE}"_results.txt
                        done
                    fi
                OSCnt=0
                fi
            done < "${K}_file_list.log"
            # Empty requirements array
            unset TEST_REQ
        fi
    rm "${K}_file_list.log"
    done | sort -n -k3

    while IFS= read -r -d '' ResultFile
    do
        echo "${ResultFile}" >> results_file_list.txt
    done <  <(find . -name "*_results.txt" -print0)

    sort -n -k3 -o results_file_list.txt  results_file_list.txt

    while read -r ResultFileList; do
        cat "${ResultFileList}" >> results.txt
        echo "|||" >> results.txt
    done <results_file_list.txt

    rm results_file_list.txt

    column -n results.txt -t -s "|"

    while IFS= read -r -d '' ResultFile
    do
        rm "${ResultFile}"
    done <  <(find . -name "*_results.txt" -print0)
    rm results.txt
}

# MAIN starts here
print_results "${ResultPath}" "${ResultTestSetup}"

