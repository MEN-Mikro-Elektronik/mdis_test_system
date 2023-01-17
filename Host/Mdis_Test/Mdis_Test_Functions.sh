#! /bin/bash

############################################################################
# echo result so that can be easly found in log 
# 
# parameters:
# $1    command
#
function make_visible_in_log {
    echo -e "\n############################################################################"
    echo "############################################################################"
    echo "$1"
    echo "############################################################################"
    echo "############################################################################"
}

############################################################################
# Run commands on remote tested device
# 
# parameters:
# $1    command
#
function run_cmd_on_remote_pc {
    sshpass -p "${MenPcPassword}" ssh -o StrictHostKeyChecking=no mdis-setup${TEST_SETUP} "${1}"
}

############################################################################
# Run scritps from this machine on remote device, since there is no 
# 
# parameters:
# $1    script
#
function run_script_on_remote_pc {
    sshpass -p "${MenPcPassword}" ssh -o StrictHostKeyChecking=no mdis-setup${TEST_SETUP} \
    bash -s < "${1}"
}

function grub_get_os {
    echo "$(run_cmd_on_remote_pc "grep --perl-regexp --only-matching \"\\s*set default=.*\" ${GrubConfFile} | sed \"s/\\s*set default=\\s*//g\" | sed \"s/\\\"//g\"")"
}

function grub_set_os {
    local ExpOs
    ExpOs="$(echo "${1}" | sed "s/\//\\\\\\\\\//g")"
    run_cmd_on_remote_pc "GrubCfg=\"\$(cat ${GrubConfFile})\" && echo \"\$GrubCfg\" | sed \"s/\\s*set default=.*/set default=\\\"${ExpOs}\\\"/g\" > ${GrubConfFile}"
}

function reboot_and_wait {
    local TryCount=0
    local Return=1
    local ExpOs="$(grub_get_os)"
    local ManualBoot=0
    local Setup

    for Setup in "${ManualOsBootSetups[@]}"; do
        if [ "${Setup}" == "${TEST_SETUP}" ]; then
            ManualBoot=1
            break
        fi
    done

    run_cmd_on_remote_pc "echo \"${MenPcPassword}\" | sudo --stdin --prompt=$'\r' shutdown -r +1"
    if [ "${ManualBoot}" -ne 0 ]; then
        echo
        echo "Please, boot the following OS on target computer:"
        echo "${ExpOs}"
        echo
        echo "Press <ENTER> to continue..."
        read -r -s
    fi
    echo "Waiting for mdis-setup${TEST_SETUP}..."
    if [ "${ManualBoot}" -eq 0 ]; then
        sleep 120
    fi
    while true; do
        if sshpass -p "${MenPcPassword}" ssh mdis-setup${TEST_SETUP} "echo"
        then
            echo "mdis-setup${TEST_SETUP} up and running..."
            Return=0
            break
        else
            TryCount=$((TryCount + 1))
            if [ "${TryCount}" -ge 60 ]; then
                Return=1
                break
            fi
            echo "Waiting for mdis-setup${TEST_SETUP}..."
            sleep 10
        fi
    done

    return "${Return}"
}

function debug_print_host {
    local Msg="${1}"
    if [ "${VERBOSE_LEVEL}" -ge 2 ]; then
        echo "${Msg}"
    fi
}

############################################################################
# Download the test results from the Target PC.
#
#
# parameters:
# $1      target test result directory
# $2      host test directory
# $3      testSetup id
# $4      date
# $5      log prefix
#

function downloadTestResults {
    local TargetPath=${1}
    local HostPath=${2}
    local TestSetupFolder="${TestSetupPrefix}${3}"
    local Date=${4}
    local LogPrefix=${5}

    local TargetFullPath=${TargetPath}"/${TestSetupFolder}/${Date}"
    local HostFullPath="${HostPath}/${TestSetupFolder}"

    echo "${LogPrefix} Creating Results/ log in the host device..."
    mkdir -p ${HostFullPath}

    if [ ! -d ${TestSetupDir} ]; then
        echo "${LogPrefix} Error. Unable to create the folder"
        return "${ERR_DIR_NOT_EXISTS}"
    fi

    echo "${LogPrefix} Retrieving the logs from the Target... folder date: "${Date}
    sshpass -p "${MenPcPassword}" scp -r mdis-setup${3}:${TargetFullPath} ${HostFullPath}

    if [ $? -eq 0 ]; then
        return "${ERR_OK}"
    else
        return "${ERR_DOWNLOAD}"
    fi
}

############################################################################
# Process the test results.
#
#
# parameters:
# $1      host test directory
# $2      testSetup id
# $3      date
# $4      log prefix
#

function processTestResults {
    local HostPath=${1}
    local TestSetupFolder="${TestSetupPrefix}${2}"
    local Date=${3}
    local LogPrefix=${4}

    local HostFullPath="${HostPath}/${TestSetupFolder}/${Date}"

    echo "${LogPrefix} Searching for Results_Summary.log files of each OS."
    resultFileList=$(find ${HostFullPath} -type f -name ${ResultsFileLogName})

    for resultFile in $resultFileList
    do
        echo -n "${LogPrefix} Processing file: "$resultFile "... "
        python3 ${MyDir}/../../Common/test_report_formatter.py -s -i mdis -f $resultFile

        if [ $? -eq 0 ]; then
            echo "[OK]"
        else
            echo "[FAIL]"
        fi
    done
}
