#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m35N test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m35n_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M35n Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "    M35n adapter is plugged into m35n m-module"
    echo "    Some m35n adapter banana plugs are connected into relay (0V/12V)"
    echo "DESCRIPTION:"
    echo "    1.Check values read from m35n"
    echo "      Load m-module drivers: 'modprobe men_ll_m34'"
    echo "      Run command: 'm34_simp m35_${ModuleNo} 14' and save command output"
    echo "      Change relay output"
    echo "      Run command: 'm34_simp m35_${ModuleNo} 14' and save command output"
    echo "      Output values of m34_simp commands should differ, for +12V should"
    echo "      be greated than 0xFD00"
    echo "    2.Check m35n interrupts"
    echo "      Run command: 'm34_blkread m35_${ModuleNo} -r=14 -b=1 -i=3 -d=1'"
    echo "      and save command output"
    echo "      Verify if m34_blkread command output is valid - does not contain errors"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m35n test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
# $4    Test case came
function m35n_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    echo "${LogPrefix} Step1:" | tee -a "${TestCaseLogName}" 2>&1
    m_module_x_test "${TestCaseLogName}" "${TestCaseName}" "${RelayOutput}" "m35" "${ModuleNo}" "simp" "${LogPrefix}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        Step1="${CmdResult}"
    fi

    echo "${LogPrefix} Step2:" | tee -a "${TestCaseLogName}" 2>&1
    m_module_x_test "${TestCaseLogName}" "${TestCaseName}" "${RelayOutput}" "m35" "${ModuleNo}" "blkread" "${LogPrefix}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        Step2="${CmdResult}"
    fi

    if [ "${Step1}" = "${ERR_OK}" ] && [ "${Step2}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}

############################################################################
# compare_m35_simp_values,
# Value on chanel 0 is checked. 
# If Chanel is disconnected from power source, value should be 0x0000 
# If Chanel is connected with 12V, value should be 0xffff
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function compare_m35_simp_values {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} compare_m35_simp_values"
    local ValueChannelStateConnected
    local ValueChannelStateDisconnected
    ValueChannelStateConnected=$(grep "ch0 = " m35_"${ModuleNo}"_simp_output_connected.txt | awk NR==1'{print $3}')
    ValueChannelStateDisconnected=$(grep  "ch0 = "  m35_"${ModuleNo}"_simp_output_disconnected.txt | awk NR==1'{print $3}')

    ValueChannelStateConnected=$(echo "${ValueChannelStateConnected}" | sed 's/0x//')
    ValueChannelStateDisconnected=$(echo "${ValueChannelStateDisconnected}" | sed 's/0x//')

    ValueChannelStateConnected=$((16#${ValueChannelStateConnected}))
    ValueChannelStateDisconnected=$((16#${ValueChannelStateDisconnected}))

    echo "${LogPrefix} ValueChannelStateConnected: ${ValueChannelStateConnected}"
    echo "${LogPrefix} ValueChannelStateDisconnected: ${ValueChannelStateDisconnected}"

    if [ "${ValueChannelStateDisconnected}" -ge "1500" ]; then
        echo "${LogPrefix} ValueChannelStateDisconnected is not ~ 0 "  | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    if [ "${ValueChannelStateConnected}" -lt "65000" ]; then
        echo "${LogPrefix} ValueChannelStateConnected is not ~ 0xffff "  | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}

############################################################################
# compare_m35_blkread_values,
# Value on chanel 0 is checked. 
# If Chanel is disconnected from power source, value should be 0
# If Chanel is connected with 12V, value should be greater than 0
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function compare_m35_blkread_values {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    echo "${LogPrefix} compare_m35_blkread_values"
    local ValueChannelStateDisconnected
    ValueChannelStateDisconnected=$(grep -P "^[0-9a-f]+\+[0-9a-f]+:" m35_"${ModuleNo}"_blkread_output_disconnected.txt | head -n 1 | awk '{print $2}' | grep -oP "^[0-9]+")

    echo "${LogPrefix} ValueChannelStateDisconnected: ${ValueChannelStateDisconnected}"

    if [ "${ValueChannelStateDisconnected}" == "" ] || [ "${ValueChannelStateDisconnected}" -ne "0" ]; then
        echo "${LogPrefix} ValueChannelStateDisconnected is not 0 "  | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}

