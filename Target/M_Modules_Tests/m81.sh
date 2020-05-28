#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m81 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m81_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M81 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Load module driver and run M-Module example programs"
    echo "    1.Load m-module drivers: modprobe driver men_ll_m27"
    echo "    2.Run m27_simp m81_${ModuleNo}"
    echo "    3.Compare m27_simp results with reference results, verify if m27_simp log"
    echo "      does not contain errors"
    echo "PURPOSE:"
    echo "    Check if M-module m81 is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1830"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1930"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m81 test 
# 
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m81_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} Step1: modprobe men_ll_m27" "${LogFile}"
    if ! run_as_root modprobe men_ll_m27
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_m27" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Run m27_simp test
    debug_print "${LogPrefix} Step2: run m27_simp m81_${ModuleNo}" "${LogFile}"
    if ! run_as_root $(m27_simp m81_"${ModuleNo}" > m27_simp_m81_"${ModuleNo}".log &)
    then
        debug_print "${LogPrefix} Could not run m27_simp " "${LogFile}"
    fi

    # Kill bacground processess m27_simp
    m27_simp_PID=$(pgrep m27_simp)
    sleep 25

    if ! run_as_root kill -9 "${m27_simp_PID}" > /dev/null 2>&1
    then
        if pgrep m27_simp
        then
            debug_print "${LogPrefix} Could not kill m27_simp PID: ${m27_simp_PID}" "${LogFile}"
        fi
    fi

    local Result="${ERR_VALUE}"
    compare_m27_simp_values "${LogFile}" "${LogPrefix}" "${ModuleNo}"
    Result=$?
    debug_print "${LogPrefix} compare_m27_simp_values result: ${Result}" "${LogFile}"
    return "${Result}"
}

############################################################################
# compare_m27_simp_values
# output shall be the same as:
# toggle channels
# channel:   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
# Set/Reset: SR SR SR SR SR SR SR SR SR SR SR SR SR SR SR SR 
#
# set all channels alternately (1,0,1,..)
# 
# read all channels
# channel:   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
# read data:  S  R  S  R  S  R  S  R  S  R  S  R  S  R  S  R 
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function compare_m27_simp_values {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    debug_print "${LogPrefix} compare_m27_simp_values " "${LogFile}"
    grep "^set all channels alternately (1,0,1,..)" m27_simp_m81_"${ModuleNo}".log > /dev/null && \
    grep "^read all channels" m27_simp_m81_"${ModuleNo}".log > /dev/null && \
    grep "^channel:   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15" m27_simp_m81_"${ModuleNo}".log > /dev/null && \
    grep "^read data:  S  R  S  R  S  R  S  R  S  R  S  R  S  R  S  R" m27_simp_m81_"${ModuleNo}".log > /dev/null && \
    if [ $? -ne 0 ]; then
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
