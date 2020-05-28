#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m36 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m36n_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "------------------------------M36n Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Load module driver and run M-Module example programs"
    echo "    1.Load m-module drivers: modprobe men_ll_m36"
    echo "    2.Run example/verification program:"
    echo "      m36_simp m36_${ModuleNo} and save the command output"
    echo "    3.Change relay output"
    echo "    4.Run example/verification program:"
    echo "      m36_simp m36_${ModuleNo} and save the command output"
    echo "    5.Output values of m36_simp commands should differ"
    echo "PURPOSE:"
    echo "    Check if M-module m36 is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1490"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1840"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m36n test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
# $4    Test case name
function m36n_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    debug_print "${LogPrefix} Step1:" "${LogFile}"
    m_module_x_test "${LogFile}" "${TestCaseName}" "${RelayOutput}" "m36n" "${ModuleNo}" "" "${LogPrefix}"
    CmdResult=$?

    if [ "${CmdResult}" == "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}
############################################################################
# compare_m36_simp_values,
# 
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function compare_m36_simp_values {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} compare_m36_simp_values" "${LogFile}"

    local ValueChannelStateConnected
    local ValueChannelStateDisconnected
    ValueChannelStateConnected=$(< m36n_"${ModuleNo}"_simp_output_connected.txt awk NR==6'{print $4}')
    ValueChannelStateDisconnected=$(< m36n_"${ModuleNo}"_simp_output_disconnected.txt awk NR==6'{print $4}')

    debug_print "${LogPrefix} ValueChannelStateConnected: ${ValueChannelStateConnected}" "${LogFile}"
    debug_print "${LogPrefix} ValueChannelStateDisconnected: ${ValueChannelStateDisconnected}" "${LogFile}"

    # replace '.' with ','
    #ValueChannelStateConnected=$(echo ${ValueChannelStateConnected} | sed 's/\./,/')
    #ValueChannelStateDisconnected=$(echo ${ValueChannelStateDisconnected} | sed 's/\./,/')

    debug_print "${LogPrefix} ValueChannelStateConnected: ${ValueChannelStateConnected} V" "${LogFile}"
    debug_print "${LogPrefix} ValueChannelStateDisconnected: ${ValueChannelStateDisconnected} V" "${LogFile}"

    local ValueLow="0.2"
    local ValueHigh="9.8"

    if (( $(echo "${ValueChannelStateDisconnected} > ${ValueLow}" |bc -l) )); then
        debug_print "${LogPrefix} ValueChannelStateConnected is not ~ 0 " "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if (( $(echo "${ValueChannelStateConnected} < ${ValueHigh}" |bc -l) )); then
        debug_print "${LogPrefix} ValueChannelStateConnected is not ~ 10 Volts " "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
