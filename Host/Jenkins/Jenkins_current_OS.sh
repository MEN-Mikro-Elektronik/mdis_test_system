#! /bin/bash

MyDir="$(dirname "$0")"
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/Jenkins_Functions.sh"
LogPrefix="[Jenkins]"

# This script checks if hardware is present

ssh-keygen -R "${MenPcIpAddr}"

# Jenkins run result identification
Today=$(date +%Y_%m_%d_%H_%M_%S)

cat "${MyDir}/../../Common/Conf.sh" ${MyDir}/Pc_Configure.sh > tmp.sh
run_script_on_remote_pc ${MyDir}/tmp.sh
if [ $? -ne 0 ]; then
        echo "${LogPrefix} Pc_Configure script failed"
        exit 
fi

rm tmp.sh

#run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 02:00.0 COMMAND=0x7"
#run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 08:00.0 COMMAND=0x7"

# Make all scripts executable
run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= chmod +x ${GitTestCommonDirPath}/*"
run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= chmod +x ${GitTestTargetDirPath}/*"
run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= chmod +x ${GitTestHostDirPath}/*"


JenkinsBackgroundPID=0

trap cleanOnExit INT SIGTERM
function cleanOnExit() {
    echo "** cleanOnExit"
    # Kill process
    echo "${LogPrefix} kill process ${JenkinsBackgroundPID}"

    kill  ${JenkinsBackgroundPID}
    if [ $? -ne 0 ]; then
            echo "${LogPrefix} Could not kill cat backgroung process ${JenkinsBackgroundPID}"
    else
            echo "${LogPrefix} process ${JenkinsBackgroundPID} killed"
    fi

    sleep 1
    jobs
    exit 0
}

./Jenkins_Background.sh &

# Save background process PID 
JenkinsBackgroundPID=$!
echo "${LogPrefix} JenkinsBackgroundPID is ${JenkinsBackgroundPID}"

# Run Test script - now scripts from remote device should be run 
make_visible_in_log "TEST CASE - SETUP CONFIGURATION 6"
run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= ${GitTestTargetDirPath}/St_Test_Configuration_6.sh ${MenPcPassword} ${Today}"
if [ $? -ne 0 ]; then
        echo "${LogPrefix} Error while running St_Test_Configuration script"
fi

cleanOnExit()
# Initialize tested device 
# run_cmd_on_remote_pc "mkdir $TestCaseDirectoryName"
# Below command must be run from local device, 
# Test scripts have not been downloaded into remote yet. 

