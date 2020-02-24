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
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "------------------------------M11 Test Case-----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    "
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run 11 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m11_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    echo "${LogPrefix} Step1:" | tee -a "${TestCaseLogName}" 2>&1
    m_module_x_test "${TestCaseLogName}" "${TestCaseName}" "${RelayOutput}" "m11" "${ModuleNo}" "" "${LogPrefix}"
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
#
function m11_f205_fix {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    local M11Nr=${3}
    local LogPrefix="[fix_m11]"
    local CurrentPath=$PWD

    echo "${LogPrefix} m11_f205_fix" | tee -a "${TestCaseLogName}" 2>&1
    ## Define wether M-Module ID-PROM is checked
    ## 0 := disable -- ignore IDPROM
    ## 1 := enable
    #ID_CHECK = U_INT32 0
    echo "${LogPrefix} Current Path:" | tee -a "${TestCaseLogName}" 2>&1
    echo "${CurrentPath}" | tee -a "${TestCaseLogName}" 2>&1

    cd ..
    sed -i '/.*m11_1.*/a ID_CHECK = U_INT32 0' system.dsc
    make_install "${LogPrefix}"
    cd "${CurrentPath}"
}

############################################################################
# compare_m11_port_veri_values
#
# parameters:
# $1    Test case log file name
# $2    Test case name
# $3    M11 board number
#
function compare_m11_port_veri_values {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    local M11Nr=${3}
    local LogPrefix="[compare_m11]"

    local ErrorCnt=$(grep -i "error" m11_${M11Nr}_simp_output_connected.txt | wc -l)
    if [ ${ErrorCnt} -ne 0 ]; then
        return "${ERR_VALUE}"
    else
        return "${ERR_OK}"
    fi
}
