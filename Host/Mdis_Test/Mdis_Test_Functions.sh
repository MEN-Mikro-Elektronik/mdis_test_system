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
    ln -sfn ${Date} ${HostFullPath}/latest

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
