#!/bin/bash

MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/../Common/Conf.sh

############################################################################
# Function writes command code into lock file. Command code description can
# be check in Conf.sh
#
# parameters:
# $1    Log file
# $2    Test case name
# $3    Command Code
# $4    Log prefix
function write_command_code {
    local LogFile=${1}
    local TestCaseName=${2}
    local CommandCode=${3}
    local LogPrefix=${4}

    local CheckFileExistsCmd="[ -f ${LockFileName} ] && echo \"true\" || echo \"false\""
    local FileExist
    FileExist=$(eval "${CheckFileExistsCmd}")

    if [ "${FileExist}" = "true" ]; then
        debug_print "${LogPrefix} Lock file exists: error ${ERR_LOCK_EXISTS}" "${LogFile}"
        return "${ERR_LOCK_EXISTS}"
    fi

    touch "${LockFileName}"
    run_as_root chown "${MenPcLogin}":"${MenPcLogin}" "${LockFileName}"
    run_as_root chmod a+w "${LockFileName}"

    echo -n "${TestCaseName} : ${CommandCode}" > "${LockFileName}"
    debug_print "${LogPrefix} ${TestCaseName} : ${CommandCode}" "${LogFile}"
    return "${ERR_OK}"
}

############################################################################
# Functions reads and returns command code result
# See format code, and file name in Conf.sh
#
# parameters:
# $1    Log file
# $2    Test case name
# $3    Log prefix
function read_command_code_status {
    local LogFile=${1}
    local TestCaseName=${2}
    local LogPrefix=${3}

    debug_print "${LogPrefix} read_command_code_status" "${LogFile}"
    local LockTestCase
    LockTestCase=$(< "${LockFileName}" awk '{print $1}')
    if [ "${LockTestCase}" != "${TestCaseName}" ]; then
        print "${LogPrefix} rc: lock_invalid, Test Case mismatch" "${LogFile}"
        return "${ERR_LOCK_INVALID}"
    fi

    local LockResult
    LockResult=$(< "${LockFileName}" awk '{print $5}')

    if [ "${LockResult}" = "${LockFileSuccess}" ]; then
        debug_print "${LogPrefix} ${LockResult}" "${LogFile}"
        return "${ERR_OK}"
    elif [ "${LockResult}" = "${LockFileFailed}" ]; then
        debug_print "${LogPrefix} ${LockResult}" "${LogFile}"
        return "${ERR_SWITCH}"
    else
        print "${LogPrefix} ${LockResult} rc: no input change result yet" "${LogFile}"
        return "${ERR_LOCK_INVALID}"
    fi
}

############################################################################
# Function requests change on input. To specify which input should be changed,
# special Command Code has to be provided (Conf.sh). As a result function returns
# ERR_OK in case of success, otherwise ERR_SWITCH code is returned.
#
# parameters:
# $1    Log file
# $2    Test case name
# $3    Command Code
# $4    Log prefix
function change_input {
    local LogFile=${1}
    local TestCaseName=${2}
    local CommandCode=${3}
    local LogPrefix=${4}
    local ReleaseCnt=1
    local Result=${ERR_SWITCH}

    debug_print "${LogPrefix} Change_input, command code: ${CommandCode}" "${LogFile}"

    write_command_code "${LogFile}" "${TestCaseName}" "${CommandCode}" "${LogPrefix}"
    Result=$?
    if [ "${Result}" -ne "${ERR_OK}" ]; then
        debug_print "${LogPrefix} Could not write_command_code - some error" "${LogFile}"
    else
        while true ; do
            sleep 2 
            # Check if inputs have been changed
            read_command_code_status "${LogFile}" "${TestCaseName}" "${LogPrefix}"
            Result=$? 
            if [ "${Result}" -eq "${ERR_OK}" ]; then
                rm "${LockFileName}"
                break
            fi
            if [ "${ReleaseCnt}" -eq "${INPUT_SWITCH_TIMEOUT}" ]; then
                print "${LogPrefix} Timeout, no response - force break " "${LogFile}"
                break
            fi
            ReleaseCnt=$((ReleaseCnt + 1))
        done
    fi

    return "${Result}"
}

