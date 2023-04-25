#! /bin/bash
MyDir="$(dirname "$0")"
source "${MyDir}"/St_Functions.sh
source "${MyDir}"/M_Modules_Tests/m11.sh
source "${MyDir}"/M_Modules_Tests/m31.sh
source "${MyDir}"/M_Modules_Tests/m32.sh
source "${MyDir}"/M_Modules_Tests/m33.sh
source "${MyDir}"/M_Modules_Tests/m35n.sh
source "${MyDir}"/M_Modules_Tests/m36n.sh
source "${MyDir}"/M_Modules_Tests/m37n.sh
source "${MyDir}"/M_Modules_Tests/m43n.sh
source "${MyDir}"/M_Modules_Tests/m47.sh
source "${MyDir}"/M_Modules_Tests/m47_pci.sh
source "${MyDir}"/M_Modules_Tests/m57.sh
source "${MyDir}"/M_Modules_Tests/m58.sh
source "${MyDir}"/M_Modules_Tests/m62n.sh
source "${MyDir}"/M_Modules_Tests/m65n.sh
source "${MyDir}"/M_Modules_Tests/m65n_canopen.sh
source "${MyDir}"/M_Modules_Tests/m66.sh
source "${MyDir}"/M_Modules_Tests/m72.sh
source "${MyDir}"/M_Modules_Tests/m77.sh
source "${MyDir}"/M_Modules_Tests/m81.sh
source "${MyDir}"/M_Modules_Tests/m82.sh
source "${MyDir}"/M_Modules_Tests/m99.sh
source "${MyDir}"/M_Modules_Tests/m199.sh
source "${MyDir}"/M_Modules_Tests/m199_pci.sh
source "${MyDir}"/Board_Tests/f215.sh
source "${MyDir}"/Board_Tests/f215_stress.sh
source "${MyDir}"/Board_Tests/f206.sh
source "${MyDir}"/Board_Tests/f614.sh
source "${MyDir}"/Board_Tests/g215.sh
source "${MyDir}"/Board_Tests/g229.sh
source "${MyDir}"/Board_Tests/g229_stress.sh
source "${MyDir}"/Board_Tests/f223.sh
source "${MyDir}"/Board_Tests/f401.sh
source "${MyDir}"/Board_Tests/carriers_a203n.sh
source "${MyDir}"/Board_Tests/carriers_f205.sh
source "${MyDir}"/Board_Tests/carriers_g204.sh
source "${MyDir}"/BoxPC_Tests/bl50_boxpc.sh
source "${MyDir}"/BoxPC_Tests/bl51_boxpc.sh
source "${MyDir}"/BoxPC_Tests/bl70_boxpc.sh
source "${MyDir}"/SMB2_Tests/b_smb2.sh
source "${MyDir}"/SMB2_Tests/b_smb2_eetemp.sh
source "${MyDir}"/SMB2_Tests/b_smb2_led.sh
source "${MyDir}"/SMB2_Tests/b_smb2_pci.sh
source "${MyDir}"/SMB2_Tests/b_smb2_poe.sh
source "${MyDir}"/PanelPC_Tests/dc19_panelpc.sh

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
                echo "No device number specified"
                exit 1
            fi
            ;;
        -module)
            shift
            if test $# -gt 0; then
                ModuleName="$1"
                shift
            else
                echo "No module name specified"
                exit 1
            fi
            ;;
        -moduleno)
            shift
            if test $# -gt 0; then
                ModuleNo="$1"
                shift
            else
                echo "No module number specified"
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
        -tspec)
            shift
            if test $# -gt 0; then
                InternalTestName="$1"
                shift
            else
                echo "No device number specified"
                exit 1
            fi
            ;;
        -bname)
            shift
            if test $# -gt 0; then
                BoardName="$1"
                shift
            else
                echo "No board name specified"
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

if [ -z "${DeviceNo}" ] && [ ! -z "${ModuleNo}" ]
then
    DeviceNo="${ModuleNo}"
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

TestTypeDev=$(echo "${DeviceName}" | head -c1)
case "${TestTypeDev}" in
    m);&
    z)
        TestCaseName="${ScriptName%.*}_${TestCaseId}_${DeviceName}_${DeviceNo}_Test_Case"
        TestCaseLogName="${ScriptName%.*}_${DeviceName}_log.txt"
        ;;
    *)
        TestCaseName="${ScriptName%.*}_${TestCaseId}_${DeviceName}_${DeviceNo}_Test_Case"
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
PrintTerminalResults="1"

if ! run_test_case_dir_create "${TestCaseLogName}" "${TestCaseName}"
then
    echo "${LogPrefix} run_test_case_dir_create: Failed, exit Test Case ${TestCaseId}"
    exit "${CmdResult}"
fi

debug_print "${LogPrefix} Run function:" "${TestCaseLogName}"

case "${TestTypeDev}" in
    c)
        print "${LogPrefix} Carrier board with M-Module test: ${DeviceName}" "${TestCaseLogName}"
        debug_print "${LogPrefix} \"${TestFunc} ${ModuleName} ${ModuleNo} ${TestCaseId} ${TestCaseMainDir}/${TestCaseName} ${TestOs}\"" "${TestCaseLogName}"
        "${TestFunc}" "${ModuleName}" "${ModuleNo}" "${TestCaseId}" "${TestCaseMainDir}/${TestCaseName}" "${TestOs}"
        CmdResult=$?
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
            TestCaseResult="${CmdResult}"
        else
            TestCaseResult=0
        fi
        ;;
    m)
        print "${LogPrefix} M-Module test: ${DeviceName}" "${TestCaseLogName}"
        debug_print "${LogPrefix} \"${TestFunc} ${TestCaseLogName} ${LogPrefix}_${DeviceName} ${DeviceNo} ${TestCaseName}\"" "${TestCaseLogName}"
        "${TestFunc}" "${TestCaseLogName}" "${LogPrefix}_${DeviceName}" "${DeviceNo}" "${TestCaseName}"
        CmdResult=$?
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
            TestCaseResult="${CmdResult}"
        else
            TestCaseResult=0
        fi
        ResultsSummaryTmp="${TestCaseId}_${DeviceName}.tmp"
        PrintTerminalResults="0"
        ;;
    z)
        print "${LogPrefix} Ip Core test: ${DeviceName}" "${TestCaseLogName}"
        debug_print "${LogPrefix} \"${TestFunc} ${TestCaseLogName} ${LogPrefix}_${DeviceName} ${VenID} ${DevID} ${SubVenID} ${DeviceNo} ${InternalTestName}\""\
        "${TestCaseLogName}"
        "${TestFunc}" "${TestCaseLogName}" "${LogPrefix}_${DeviceName}" "${VenID}" "${DevID}" "${SubVenID}" "${DeviceNo}" "${InternalTestName}"
        CmdResult=$?
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
            TestCaseResult="${CmdResult}"
        else
            TestCaseResult=0
        fi
        ResultsSummaryTmp="${TestCaseId}_${DeviceName}.tmp"
        PrintTerminalResults="0"
        ;;
    b);&
    f);&
    d);&
    g)
        print "${LogPrefix} Board test: ${DeviceName}" "${TestCaseLogName}"
        debug_print "${LogPrefix} \"${TestFunc} ${TestCaseId} ${TestCaseMainDir}/${TestCaseName} ${TestOs} ${TestCaseLogName} ${LogPrefix} ${DevicesFile} ${DeviceNo}\"" "${TestCaseLogName}"
        "${TestFunc}" "${TestCaseId}" "${TestCaseMainDir}/${TestCaseName}" "${TestOs}" "${TestCaseLogName}" "${LogPrefix}" "${DeviceNo}" "${BoardName}"
        CmdResult=$?
        if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
            TestCaseResult="${CmdResult}"
        else
            TestCaseResult=0
        fi
        ;;
    *)
        debug_print "${LogPrefix} No valid device name" "${TestCaseLogName}"
        ;;
esac

if [ "${TestCaseResult}" -eq "${ERR_OK}" ]; then
    TestCaseResult="SUCCESS"
else
    TestCaseResult="FAIL"
fi

case "${TestTypeDev}" in
    c)
        "${TestDescription}" "${ModuleName}" "${ModuleNo}" "${TestCaseMainDir}" "" >> "${ResultsSummaryTmp}"
        ;;
    m);&
    z);&
    b);&
    f);&
    g)
        "${TestDescription}" "${DeviceNo}" "${TestCaseLogName}" "${TestCaseMainDir}" >> "${ResultsSummaryTmp}"
        ;;
    *)
        ;;
esac

if [ ${PrintTerminalResults} -eq "1" ]; then
    echo "${LogPrefix} Test_Result for ${TestCaseName}: ${TestCaseResult}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_Result: ${TestCaseResult}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_ID: ${TestCaseId}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_Setup: ${TEST_SETUP}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_Os: ${TestOs}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_Instance: ${DeviceNo}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
else
    echo "${LogPrefix} Test_Result for ${TestCaseName}: ${TestCaseResult}" | tee -a "${TestCaseLogName}" "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_Result: ${TestCaseResult}" | tee -a "${TestCaseLogName}" >> "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_ID: ${TestCaseId}" | tee -a "${TestCaseLogName}" >> "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_Setup: ${TEST_SETUP}" | tee -a "${TestCaseLogName}" >> "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_Os: ${TestOs}" |  tee -a "${TestCaseLogName}" >> "${ResultsSummaryTmp}" 2>&1
    echo "${LogPrefix} Test_Instance: ${DeviceNo}" |  tee -a "${TestCaseLogName}" >> "${ResultsSummaryTmp}" 2>&1
fi

# move to previous directory
cd "${CurrDir}" || exit "${ERR_NOEXIST}"

exit "${CmdResult}"
