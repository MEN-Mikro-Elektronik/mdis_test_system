#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/St_Functions.sh

function run_test_case {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"

    case "${TestCaseId}" in
        0100)
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "f215"
            ;;
        0101)
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "f223"
            ;;
        0102)
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "f614"
            ;;
        0200)
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "carrier_g204_m65n"
            ;;
        0201)
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "carrier_f205_m47"
            ;;
        0202)
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "carrier_g204_m33"
            # It is possible to run m-module test case without specifying carrier
            #run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "m33" -dno "1"
            ;;
        0203)
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "carrier_g204_m35n"
            ;;
        0211)
            run_as_root "${MyDir}/Test_x.sh" "${TestSummaryDirectory}" "${TestCaseId}" "${OsNameKernel}" "m62n" "1"
            ;;
        0212)
            run_as_root "${MyDir}/Test_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "m65n" -dno "1"
            ;;
        0300)
            #echo "User has to provide mezz cham dump of the board where z029_can is located"
            #run_as_root "${MyDir}/ST_Module_x.sh" -dir "${TestSummaryDirectory}" -id "${TestCaseId}" -os "${OsNameKernel}" -dname "z029_can" -dfile "${ChamFile}" -ttype "${TestType}"
            ;;
        *)
            echo "Function test case id not set!"
            ;;
    esac
}

