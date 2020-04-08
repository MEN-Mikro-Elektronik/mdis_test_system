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
    echo "    1.Load m-module drivers: modprobe men_ll_m11"
    echo "    2.Run example/verification program:"
    echo "      m11_port_veri m11_${ModuleNo} and save the command output"
    echo "    3.Verify if m11_port_veri command output is valid - does not contain errors"
    echo "PURPOSE:"
    echo "    Check if M-module m11 is working correctly"
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
# $1    Log file
# $2    Log prefix
# $3    M-Module number
# $4    Test Case Name
function m11_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestCaseName=${4}
    local RelayOutput="${IN_0_ENABLE}"

    debug_print "${LogPrefix} Step1:" "${LogFile}"
    m_module_x_test "${LogFile}" "${TestCaseName}" "${RelayOutput}" "m11" "${ModuleNo}" "" "${LogPrefix}"
    MResult=$?

    if [ "${MResult}" = "${ERR_OK}" ]; then
        return "${ERR_OK}"
    else
        return "${ERR_VALUE}"
    fi
}


############################################################################
# fix for m11 M-Module if plugged into f205 carrier.
#
# parameters:
# $1    Log file
# $2    Log prefix
function m11_f205_fix {
    local LogFile=${1}
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
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function compare_m11_port_veri_values {
    local LogFile=${1}
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
