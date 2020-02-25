#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/St_Functions.sh

### @brief Run command as root
### @param $@ Command to run, command arguments
function run_as_root {
    if [ "${#}" -gt "0" ]; then
        echo "${MenPcPassword}" | sudo -S --prompt=$'\r' -- "${@}"
    fi
}

function run_test_case {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    case "${TestCaseId}" in
        0100)
            run_as_root "${MyDir}/ST_Module_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "f215"
            ;;
        0101)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "g215"
            ;;
        0102)
            run_as_root "${MyDir}/ST_Module_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "f223"
            ;;
        0103)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "g229"
            ;;
        0200)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m11" "1"
            ;;
        0201)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m31" "1"
            ;;
        0202)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m32" "1"
            ;;
        0203)
            run_as_root "${MyDir}/ST_Module_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "m33" -dno "1"
            ;;
        0204)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m35n" "1"
            ;;
        0205)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m36n" "1"
            ;;
        0206)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m37n" "1"
            ;;
        0207)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m43n" "1"
            ;;
        0208)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m47" "1"
            ;;
        0209)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m57" "1"
            ;;
        0210)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m58" "1"
            ;;
        0211)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m62n" "1"
            ;;
        0212)
            run_as_root "${MyDir}/ST_Module_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "m65n" -dno "1"
            ;;
        0213)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m66" "1"
            ;;
        0214)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m72" "1"
            ;;
        0215)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m77n" "1"
            ;;
        0216)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m81" "1"
            ;;
        0217)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m82" "1"
            ;;
        0218)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m99" "1"
            ;;
        0219)
            run_as_root "${MyDir}/ST_Module_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m199" "1"
            ;;
        0300)
            echo "Ip core test is empty"
            #echo "User has to provide mezz cham dump of the board where z029_can is located"
            #run_as_root "${MyDir}/ST_Module_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "z029_can" -dfile "${ChamFile}" -ttype "${TestType}"
            ;;
        *)
            echo "Function test case id not set!"
            ;;
    esac
}

