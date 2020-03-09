#!/bin/bash
MyDir="$(dirname "$0")"
source "${MyDir}/../../Common/Conf.sh"

declare -A TEST_RESULT_OS
# List of available OS-es
TEST_RESULT_OS["1"]="Ubuntu16046415045generici686"
TEST_RESULT_OS["2"]="Ubuntu18043415060generici686"
# others... 

declare -a TEST_RESULT_OS_1=(_ _ _ _ _)
declare -a TEST_RESULT_OS_2=(_ _ _ _ _)
declare -a TEST_RESULT_OS_3=(_ _ _ _ _)
declare -a TEST_RESULT_OS_4=(_ _ _ _ _)
declare -a TEST_RESULT_OS_5=(_ _ _ _ _)
# others... 

rm results.txt
touch results.txt
echo "Id|Description(firstline)|Instruction|OS|" >> results.txt
echo "|Purpose|[Reference] (last line)||1|2|3|4|5|others..." >> results.txt

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
    else
        echo "OS NOT SPECIFIED"
        exit 1
    fi
}

function print_test {
    local OSCnt=0
    local OSNo=0
    # Add brief test case description
    for K in "${!TEST_CASES_MAP[@]}"
    do
        #sort -rn -k3
        # Obtain results directory
        find "$(pwd)" -name "${K}.tmp" > "${K}_file_list.log"
        OSCnt=0
        OSNo=$(< "${K}_file_list.log" wc -l)
        while IFS= read -r file
        do
            OSCnt=$((OSCnt+1))
            TEST_DESCRIPTION_SHORT=$(grep "DESCRIPTION:" -A 1 "${file}" | awk 'NR==2' | awk '{$1=$1};1')
            TEST_PURPOSE0=$(grep "PURPOSE:" -A 2 "${file}" | awk 'NR==2' | awk '{$1=$1};1' )
            TEST_PURPOSE1=$(grep "PURPOSE:" -A 2 "${file}" | awk 'NR==3' | awk '{$1=$1};1' )
            TEST_PURPOSE1=$(if ! echo "${TEST_PURPOSE1}" | grep "RESULTS" > /dev/null; then echo "${TEST_PURPOSE1}"; fi)
            TEST_ID=$(grep "Test_ID" "${file}" | awk '{print $3}' | awk '{$1=$1};1')
            TEST_OS_FULL=$(grep "Test_Os" "${file}" | awk '{print $3}' | awk '{$1=$1};1')
            TEST_SETUP=$(grep "Test_Setup" "${file}" | awk '{print $3}' | awk '{$1=$1};1')
            TEST_RESULTS=$(grep "Test_Result" "${file}" | awk '{print $2 $3}' | awk '{$1=$1};1')
            TEST_RESULTS=$(if echo "${TEST_RESULTS}" | grep "SUCCESS" > /dev/null; then echo "S"; else echo "F"; fi)
            TEST_CMD0="Mdis_Test.sh --run-test=${TEST_ID}"
            TEST_FNC_DESCRIPTION="${TEST_CASES_MAP[${K}]}_test()"
            set_result_os "${TEST_SETUP}" "${TEST_OS_FULL}" "${TEST_RESULTS}"
            if [ "${OSCnt}" -eq "${OSNo}" ]; then
              echo -e "${TEST_ID}|${TEST_DESCRIPTION_SHORT}|${TEST_CMD0}|${TEST_RESULT_OS["1"]}|${TEST_RESULT_OS_1[0]}|${TEST_RESULT_OS_1[1]}|${TEST_RESULT_OS_1[2]}|${TEST_RESULT_OS_1[3]}|${TEST_RESULT_OS_1[4]}|${TEST_RESULT_OS_1[5]}" >> results.txt
              echo -e "|${TEST_PURPOSE0}|${TEST_FNC_DESCRIPTION}|${TEST_RESULT_OS["2"]}|${TEST_RESULT_OS_2[0]}|${TEST_RESULT_OS_2[1]}|${TEST_RESULT_OS_2[2]}|${TEST_RESULT_OS_2[3]}|${TEST_RESULT_OS_2[4]}|${TEST_RESULT_OS_2[5]}" >> results.txt
              echo -e "|${TEST_PURPOSE1}||${TEST_RESULT_OS["3"]}|${TEST_RESULT_OS_3[0]}|${TEST_RESULT_OS_3[1]}|${TEST_RESULT_OS_3[2]}|${TEST_RESULT_OS_3[3]}|${TEST_RESULT_OS_3[4]}|${TEST_RESULT_OS_3[5]}" >> results.txt
            fi
            echo "|||" >> results.txt
        done < "${K}_file_list.log"
    rm "${K}_file_list.log"
    done
}

print_test
column -n results.txt -t -s "|"
