#!/bin/bash
MyDir="$(dirname "$0")"
source "${MyDir}/../../Common/Conf.sh"

ResultPath="${1}"
ResultTestSetup=""

declare -A TEST_REQ
declare -A TEST_RESULT_OS

# List of available OS-es
TEST_RESULT_OS["1"]="Ubuntu16046415045generici686"
TEST_RESULT_OS["2"]="Ubuntu18043415060generici686"
TEST_RESULT_OS["3"]="Ubuntu1804453028genericx8664"
TEST_RESULT_OS["4"]="Ubuntu1804453046genericx8664"

declare -a TEST_RESULT_OS_1=(_ _ _ _ _)
declare -a TEST_RESULT_OS_2=(_ _ _ _ _)
declare -a TEST_RESULT_OS_3=(_ _ _ _ _)
declare -a TEST_RESULT_OS_4=(_ _ _ _ _)
declare -a TEST_RESULTS_GROUP=("TEST_RESULT_OS_1" "TEST_RESULT_OS_2" "TEST_RESULT_OS_3" "TEST_RESULT_OS_4")

### @brief script usage --help
function mdis_report_usage {
    echo "Mdis_Report.sh - tool generate MDIS results"
    echo ""
    echo "USAGE"
    echo "    Mdis_Report.sh -h | --help"
    echo "    Mdis_Report.sh <RESULT_PATH> [--test-setup=SETUP]"
    echo ""
    echo "OPTIONS"
    echo "    RESULT_PATH"
    echo "        Path to Mdis_Test result directory"
    echo ""
    echo "    --test-setup=SETUP"
    echo "        Print results for specified test setup"
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
        *)
            echo "No valid parameters"
            break
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
    else
        echo "OS NOT SPECIFIED"
        exit 1
    fi
}

function print_requirements {
    local TestCase=${1}
    local Req=""
    local ReqCnt=1
    while [ "${Req}" != "INVALID" ]
    do  
        ReqCnt=$((ReqCnt+1))
        Req=$(cat "${TestCase}" | grep -A 10 "REQUIREMENT_ID:" | awk NR==${ReqCnt} | tr -d ' ')
        if [ "${Req}" != "RESULTS" ] && [ "${Req}" != "" ]
        then
            TEST_REQ[$((ReqCnt-2))]="${Req}"
        else
            Req="INVALID"
        fi
    done
    echo "$((ReqCnt-1))"
}

function print_results {
    local ResultPath="${1}"
    local ResultTestSetup="${2}"
    local ResultOperatingSystem="${3}"
    local OSCnt=0
    local OSNo=0

    rm results.txt
    touch results.txt

    create_test_cases_map
    if [ -z "${ResultTestSetup}" ]; then
        echo "Id|Requirement|Description(firstline)|Instruction|OS" >> results.txt
        echo "||Purpose|||1|2|3|4|5| Test Setup" >> results.txt
    else
        echo "Id|Requirement|Description(firstline)|Instruction|OS|Test Setup" >> results.txt
        echo "||Purpose|||${ResultTestSetup}" >> results.txt
        ResultTestSetup=$((ResultTestSetup-1))
    fi
    echo "|||" >> results.txt
    #($(echo "${ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    for K in "${!TEST_CASES_MAP[@]}"
    do
        # Obtain results directory
        find "${ResultPath}" -name "${K}.tmp" > "${K}_file_list.log"
        OSCnt=0
        OSNo=$(< "${K}_file_list.log" wc -l)
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
            print_requirements "${file}" > /dev/null
            ReqCnt="$(print_requirements "${file}")"
            TEST_SETUP=$(grep "Test_Setup" "${file}" | awk '{print $3}' | awk '{$1=$1};1')
            TEST_RESULTS=$(grep "Test_Result" "${file}" | awk '{print $2 $3}' | awk '{$1=$1};1')
            if [ -z "${ResultTestSetup}" ]; then
                TEST_RESULTS=$(if echo "${TEST_RESULTS}" | grep "SUCCESS" > /dev/null; then echo "S"; else echo "F"; fi)
            else
                TEST_RESULTS=$(if echo "${TEST_RESULTS}" | grep "SUCCESS" > /dev/null; then echo "SUCCESS"; else echo "FAIL"; fi)
            fi
            TEST_CMD0="./Mdis_Test.sh --run-test=${TEST_ID}"
            TEST_DSC="./Mdis_Test.sh --print-test-brief=${TEST_ID}"
            #TEST_FNC_DESCRIPTION="${TEST_CASES_MAP[${K}]}_test()"
            set_result_os "${TEST_SETUP}" "${TEST_OS_FULL}" "${TEST_RESULTS}"
            rm "${TEST_ID}"_results.txt > /dev/null 2>&1
            if [ -z "${ResultTestSetup}" ]; then
                if [ "${OSCnt}" -eq "${OSNo}" ]; then
                    echo -e "${TEST_ID}|${TEST_REQ0}|${TEST_DESCRIPTION_SHORT}|${TEST_CMD0}|${TEST_RESULT_OS["1"]}|${TEST_RESULT_OS_1[0]}|${TEST_RESULT_OS_1[1]}|${TEST_RESULT_OS_1[2]}|${TEST_RESULT_OS_1[3]}|${TEST_RESULT_OS_1[4]}|${TEST_RESULT_OS_1[5]}" >> "${TEST_ID}"_results.txt
                    echo -e "|${TEST_REQ1}|${TEST_PURPOSE0}|${TEST_DSC}|${TEST_RESULT_OS["2"]}|${TEST_RESULT_OS_2[0]}|${TEST_RESULT_OS_2[1]}|${TEST_RESULT_OS_2[2]}|${TEST_RESULT_OS_2[3]}|${TEST_RESULT_OS_2[4]}|${TEST_RESULT_OS_2[5]}" >> "${TEST_ID}"_results.txt
                     echo -e "|${TEST_REQ2}|${TEST_PURPOSE1}||${TEST_RESULT_OS["3"]}|${TEST_RESULT_OS_3[0]}|${TEST_RESULT_OS_3[1]}|${TEST_RESULT_OS_3[2]}|${TEST_RESULT_OS_3[3]}|${TEST_RESULT_OS_3[4]}|${TEST_RESULT_OS_3[5]}" >> "${TEST_ID}"_results.txt
                    echo -e "|${TEST_REQ3}|||${TEST_RESULT_OS["4"]}|${TEST_RESULT_OS_4[0]}|${TEST_RESULT_OS_4[1]}|${TEST_RESULT_OS_4[2]}|${TEST_RESULT_OS_4[3]}|${TEST_RESULT_OS_4[4]}|${TEST_RESULT_OS_4[5]}" >> "${TEST_ID}"_results.txt
                    echo -e "|${TEST_REQ4}|||${TEST_RESULT_OS["5"]}|${TEST_RESULT_OS_5[0]}|${TEST_RESULT_OS_5[1]}|${TEST_RESULT_OS_5[2]}|${TEST_RESULT_OS_5[3]}|${TEST_RESULT_OS_5[4]}|${TEST_RESULT_OS_5[5]}" >> "${TEST_ID}"_results.txt
                fi
            else
                if [ "${OSCnt}" -eq "${OSNo}" ]; then
                    local LineCntLoop=0
                    local LineCnt=0
                    # At least 3 lines per test cases are printed
                    echo -e "${TEST_ID}|${TEST_REQ["0"]}|${TEST_DESCRIPTION_SHORT}|${TEST_CMD0}|${TEST_RESULT_OS["1"]}|${TEST_RESULT_OS_1[${ResultTestSetup}]}" >> "${TEST_ID}"_results.txt
                    echo -e "|${TEST_REQ["1"]}|${TEST_PURPOSE0}|${TEST_DSC}|${TEST_RESULT_OS["2"]}|${TEST_RESULT_OS_2[${ResultTestSetup}]}" >> "${TEST_ID}"_results.txt
                    echo -e "|${TEST_REQ["2"]}|${TEST_PURPOSE1}||${TEST_RESULT_OS["3"]}|${TEST_RESULT_OS_3[${ResultTestSetup}]}" >> "${TEST_ID}"_results.txt
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
                            echo -e "|${TEST_REQ["$((i+3))"]}|||${TEST_RESULT_OS[$((i+3))]}|${!RealArrayValue}" >> "${TEST_ID}"_results.txt
                        done
                    fi
                fi
            fi
            # Empty requirements array
            unset TEST_REQ
        done < "${K}_file_list.log" 
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
}

# MAIN starts here
print_results "${ResultPath}" "${ResultTestSetup}"

