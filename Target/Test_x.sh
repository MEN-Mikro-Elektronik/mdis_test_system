#! /bin/bash
MyDir="$(dirname "$0")"
source "${MyDir}"/St_Functions.sh
source "${MyDir}"/M_Modules_Tests/m33.sh
source "${MyDir}"/M_Modules_Tests/m35n.sh
source "${MyDir}"/M_Modules_Tests/m47.sh
source "${MyDir}"/M_Modules_Tests/m65n.sh
source "${MyDir}"/M_Modules_Tests/m72.sh
source "${MyDir}"/Board_Tests/f215.sh
source "${MyDir}"/Board_Tests/f614.sh
source "${MyDir}"/Board_Tests/g215.sh
source "${MyDir}"/Board_Tests/g229.sh
source "${MyDir}"/Board_Tests/f223.sh
source "${MyDir}"/Board_Tests/carriers.sh

CurrDir=$(pwd)

############################################################################
# This script might be used to run simple m-module test,
# User has to define m_module description and test function.
# example: m65n_description (), m65n_test (), and pass parameter "m65n" with
# m-module number into this script
# 
# parameters $1 test case main directory
#            $2 unique test case ID
#            $3 OS name
#            $4 Module name
#            $5 Module num

#TestCaseMainDir="${1}"
#TestCaseId="${2}"
#LogPrefix="[${2}]"
#TestOs="${3}"
#DeviceName="${4}"
#DeviceNo="${5}"
#TestType=""
#DevicesFile=""

# read parameters
while test $# -gt 0 ; do
    case "$1" in
        -dir)
            shift
            if test $# -gt 0; then
                TestCaseMainDir="$1"
                shift
            else
                echo "No main dir specified"
                exit 1
            fi
            ;;
        -id)
            shift
            if test $# -gt 0; then
                TestCaseId="$1"
                shift
            else
                echo "No test id specified"
                exit 1
            fi
            ;;
        -os)
            shift
            if test $# -gt 0; then
                TestOs="$1"
                shift
            else
                echo "No test OS specified"
                exit 1
            fi
            ;;
        -dname)
            shift
            if test $# -gt 0; then
                DeviceName="$1"
                shift
            else
                echo "No device name specified"
                exit 1
            fi
            ;;
        -dno)
            shift
            if test $# -gt 0; then
                DeviceNo="$1"
                shift
            else
                echo "No mezz cham dev file specified"
                exit 1
            fi
            ;;
        -venid)
            shift
            if test $# -gt 0; then
                VenID="$1"
                shift
            else
                echo "No DevVenId number specified"
                exit 1
            fi
            ;;
        -devid)
            shift
            if test $# -gt 0; then
                DevID="$1"
                shift
            else
                echo "No DevVenId number specified"
                exit 1
            fi
            ;;
        -subvenid)
            shift
            if test $# -gt 0; then
                SubVenID="$1"
                shift
            else
                echo "No DevVenId number specified"
                exit 1
            fi
            ;;
        -ttype)
            shift
            if test $# -gt 0; then
                InternalTestName="$1"
                shift
            else
                echo "No device number specified"
                exit 1
            fi
            ;;
        *)
            break
            ;;
        esac
done

TestDescription="${DeviceName}_description"
TestFunc="${DeviceName}_test"
LogPrefix="[${TestCaseId}]"

if [ -z "${TestCaseMainDir}" ] || [ -z "${TestCaseId}" ] || [ -z "${TestOs}" ] || [ -z "${DeviceName}" ]
then
    echo "TestCaseMainDir: ${TestCaseMainDir}"
    echo "TestCaseId: ${TestCaseId}"
    echo "LogPrefix: ${LogPrefix}"
    echo "TestOs: ${TestOs}"
    echo "DeviceName: ${DeviceName}"
    echo "DeviceNo: ${DeviceNo}"
    echo "(no obligatory) DeviceFile: ${DevicesFile}"
    echo "(no obligatory) InternalTestName: ${InternalTestName}"
    echo "Lack of params - exit"
    exit "${ERR_NOEXIST}"
fi

FunctionExists=$(type -t "${TestDescription}")
if [ "${FunctionExists}" != "function" ]
then
    echo "${LogPrefix} Function ${TestDescription} does not exists - exit"
    exit "${ERR_NOEXIST}"
fi

FunctionExists=$(type -t "${TestFunc}")
if [ "${FunctionExists}" != "function" ]
then
    echo "${LogPrefix} Function ${TestDescription} does not exists - exit"
    exit "${ERR_NOEXIST}"
fi

cd "${MainTestDirectoryPath}/${MainTestDirectoryName}" || exit "${ERR_NOEXIST}"
ScriptName=${0##*/}

TestTypeDev=$(echo ${DeviceName} | head -c1)
case "${TestTypeDev}" in
    m);&
    z)
        TestCaseName="${ScriptName%.*}_${TestCaseId}_${DeviceName}_Test_Case"
        TestCaseLogName="${ScriptName%.*}_${DeviceName}_log.txt"
        ;;
    *)
        TestCaseName="${ScriptName%.*}_${TestCaseId}_Test_Case"
        TestCaseLogName="${ScriptName%.*}_log.txt"
        ;;
esac

ResultsSummaryTmp="${TestCaseId}.tmp"

# Move to correct Test_Summary directory
cd "${TestCaseMainDir}" || exit "${ERR_NOEXIST}"

###############################################################################
###############################################################################
######################## Start of Test Case ###################################
###############################################################################
###############################################################################

TestCaseResult=${ERR_UNDEFINED}
CmdResult=${ERR_UNDEFINED}

if ! run_test_case_dir_create "${TestCaseLogName}" "${TestCaseName}"
then
    echo "${LogPrefix} run_test_case_dir_create: Failed, exit Test Case ${TestCaseId}"
    exit "${CmdResult}"
else
    echo "${LogPrefix} run_test_case_dir_create: Success"
fi

echo "${LogPrefix} Run function:" | tee -a "${TestCaseLogName}" 2>&1

case "${TestTypeDev}" in
    c)
        echo "${LogPrefix} Carrier board with M-Module test" | tee -a "${TestCaseLogName}" 2>&1
        echo "${LogPrefix} \"${TestFunc} ${TestCaseId} ${TestCaseMainDir}/${TestCaseName} ${TestOs}\""\
            | tee -a "${TestCaseLogName}" 2>&1
        "${TestFunc}" "${TestCaseId}" "${TestCaseMainDir}/${TestCaseName}" "${TestOs}"
        CmdResult=$?
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
            TestCaseResult="${CmdResult}"
        else
            TestCaseResult=0
        fi
        ;;
    m)
        echo "${LogPrefix} M-Module test" | tee -a "${TestCaseLogName}" 2>&1
        echo "${LogPrefix} \"${TestFunc} ${TestCaseLogName} ${LogPrefix}_${DeviceName} ${DeviceNo} ${TestCaseName}\""\
            | tee -a "${TestCaseLogName}" 2>&1
        "${TestFunc}" "${TestCaseLogName}" "${LogPrefix}_${DeviceName}" "${DeviceNo}" "${TestCaseName}"
        CmdResult=$?
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
            TestCaseResult="${CmdResult}"
        else
            TestCaseResult=0
        fi
        ResultsSummaryTmp="${TestCaseId}_${DeviceName}.tmp"
        ;;
    z)
        echo "${LogPrefix} Ip Core test" | tee -a "${TestCaseLogName}" 2>&1
        echo "${LogPrefix} \"${TestFunc} ${TestCaseLogName} ${LogPrefix}_${DeviceName} ${VenID} ${DevID} ${SubVenID} ${DeviceNo} ${InternalTestName}\""\
            | tee -a "${TestCaseLogName}" 2>&1
        "${TestFunc}" "${TestCaseLogName}" "${LogPrefix}_${DeviceName}" "${VenID}" "${DevID}" "${SubVenID}" "${DeviceNo}" "${InternalTestName}"
        CmdResult=$?
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
            TestCaseResult="${CmdResult}"
        else
            TestCaseResult=0
        fi
        ResultsSummaryTmp="${TestCaseId}_${DeviceName}.tmp"
        ;;
    f);&
    g)
        echo "${LogPrefix} Board test" | tee -a "${TestCaseLogName}" 2>&1
        echo "${LogPrefix} \"${TestFunc} ${TestCaseId} ${TestCaseMainDir}/${TestCaseName} ${TestOs} ${TestCaseLogName} ${LogPrefix} ${DevicesFile} ${DeviceNo}\""\
            | tee -a "${TestCaseLogName}" 2>&1
        "${TestFunc}" "${TestCaseId}" "${TestCaseMainDir}/${TestCaseName}" "${TestOs}" "${TestCaseLogName}" "${LogPrefix}" "${DeviceNo}"
        CmdResult=$?
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
            TestCaseResult="${CmdResult}"
        else
            TestCaseResult=0
        fi
        ;;
    *)
        echo "${LogPrefix} No valid device name"| tee -a "${TestCaseLogName}" 2>&1
        ;;
esac

if [ "${TestCaseResult}" -eq "${ERR_OK}" ]; then
    TestCaseResult="SUCCESS"
else
    TestCaseResult="FAIL"
fi

"${TestDescription}" "${DeviceNo}" "${TestCaseLogName}">> "${ResultsSummaryTmp}"
echo "${LogPrefix} Test_Result:${TestCaseResult}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${LogPrefix} Test_ID: ${TestCaseId}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${LogPrefix} Test_Setup: ${TestSetup}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
echo "${LogPrefix} Test_Os: ${TestOs}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1

# move to previous directory
cd "${CurrDir}" || exit "${ERR_NOEXIST}"

exit "${CmdResult}"
