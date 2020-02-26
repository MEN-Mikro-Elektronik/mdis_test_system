MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/../Common/Conf.sh

############################################################################
# Function writes command code into lock file. Command code description can
# be check in Conf.sh
#
# parameters:
# $1    Test case log file name
# $2    Test case name
# $3    Command Code
# $4    Log Prefix
function write_command_code {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    local CommandCode=${3}
    local LogPrefix=${4}

    local CheckFileExistsCmd="[ -f ${LockFileName} ] && echo \"true\" || echo \"false\""
    local FileExist=$(eval "${CheckFileExistsCmd}")

    if [ "${FileExist}" = "true" ]; then
        echo "${LogPrefix} Lock file exists: error ${ERR_LOCK_EXISTS}" | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_LOCK_EXISTS}"
    fi

    touch "${LockFileName}"
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' chown "${MenPcLogin}":"${MenPcLogin}" "${LockFileName}"
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' chmod a+w "${LockFileName}"

    echo -n "${TestCaseName} : ${CommandCode}" > "${LockFileName}"
    echo "${LogPrefix} ${TestCaseName} : ${CommandCode}" | tee -a "${TestCaseLogName}" 2>&1
    return "${ERR_OK}"
}

############################################################################
# Functions reads and returns command code result. 
# See format code, and file name in Conf.sh
#
# parameters:
# $1    Test case log file name
# $2    Test case name
# $3    Log Prefix
function read_command_code_status {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    local LogPrefix=${3}

    echo "${LogPrefix} read_command_code_status"  | tee -a "${TestCaseLogName}" 2>&1
    local LockTestCase=$(cat "${LockFileName}" | awk '{print $1}')
    if [ "${LockTestCase}" != "${TestCaseName}" ]; then
        echo "${LogPrefix} rc: lock_invalid, Test Case mismatch" | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_LOCK_INVALID}"
    fi

    local LockResult
    LockResult=$(cat "${LockFileName}" | awk '{print $5}')

    if [ "${LockResult}" = "${LockFileSuccess}" ]; then
        echo "${LogPrefix} ${LockResult}" | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_OK}"
    elif [ "${LockResult}" = "${LockFileFailed}" ]; then
        echo "${LogPrefix} ${LockResult}" | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_SWITCH}"
    else
        #echo "${LogPrefix} ${LockResult} rc: no input change result yet"| tee -a ${TestCaseLogName} 2>&1
        return "${ERR_LOCK_INVALID}"
    fi
}

############################################################################
# Function requests change on input. To specify which input should be changed,
# special Command Code has to be provided (Conf.sh). As a result function returns
# ERR_OK in case of success, otherwise ERR_SWITCH code is returned.
#
# parameters:
# $1    Test case log file name
# $2    Test case name
# $3    Command Code
# $4    Timeout ( x * 5sec) example: 60 * 5 sec
# $5    LogPrefix
function change_input {
    local TestCaseLogName=${1}
    local TestCaseName=${2}
    local CommandCode=${3}
    local Timeout=${4}
    local LogPrefix=${5}
    local ReleaseCnt=1
    local Result=${ERR_SWITCH}

    echo "${LogPrefix} Change_input, command code: ${CommandCode}" | tee -a "${TestCaseLogName}" 2>&1

    write_command_code "${TestCaseLogName}" "${TestCaseName}" "${CommandCode}" "${LogPrefix}"
    Result=$?
    if [ "${Result}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} Could not write_command_code - some error" | tee -a "${TestCaseLogName}" 2>&1
    else
        while true ; do
            sleep 2 
            # Check if inputs have been changed
            read_command_code_status "${TestCaseLogName}" "${TestCaseName}" "${LogPrefix}"
            Result=$? 
            if [ "${Result}" -eq "${ERR_OK}" ]; then
                rm "${LockFileName}"
                break
            fi
            if [ "${ReleaseCnt}" -eq "${Timeout}" ]; then
                echo "${LogPrefix} Timeout, no response - force break " | tee -a "${TestCaseLogName}" 2>&1
                break
            fi
            ReleaseCnt=$((ReleaseCnt + 1))
        done
    fi

    return "${Result}"
}

