#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m11 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m11_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "------------------------------M11 Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    m11_${ModuleNo}"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m11 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
# $4    Test Case Name
function m11_test {
    local LogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    print "${LogPrefix} m11_test in progress..." "${LogFile}"
    debug_print "${LogPrefix} Step1:" "${LogName}"
    m_module_x_test "${LogName}" "${TestCaseName}" "${RelayOutput}" "m11" "${ModuleNo}" "" "${LogPrefix}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        Step1="${CmdResult}"
    fi

    if [ "${Step1}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}


############################################################################
# fix for m11 M-Module if plugged into f205 carrier.
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
function m11_f205_fix {
    local LogName=${1}
    local LogPrefix=${2}
    local CurrentPath=$PWD

    debug_print "${LogPrefix} m11_f205_fix" "${LogFile}"
    ## Define wether M-Module ID-PROM is checked
    ## 0 := disable -- ignore IDPROM
    ## 1 := enable
    #ID_CHECK = U_INT32 0
    debug_print "${LogPrefix} Current Path:" "${LogFile}"
    debug_print "${CurrentPath}" "${LogFile}"

    cd ..
    sed -i '/.*m11_1.*/a ID_CHECK = U_INT32 0' system.dsc
    make_install "${LogPrefix}"
    cd "${CurrentPath}" || exit "${ERR_NOEXIST}"
}

############################################################################
# compare_m11_port_veri_values
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function compare_m11_port_veri_values {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local ErrorCnt="0"
    ErrorCnt=$(grep -ic "error" m11_"${ModuleNo}"_simp_output_connected.txt)
    if [ "${ErrorCnt}" -ne 0 ]; then
        return "${ERR_VALUE}"
    else
        return "${ERR_OK}"
    fi
}
