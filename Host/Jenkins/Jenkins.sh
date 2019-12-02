#! /bin/bash

MyDir="$(dirname "$0")"
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/Jenkins_Functions.sh"
LogPrefix="[Jenkins]"

# This script checks if hardware is present
# Jenkins run result identification
Today=$(date +%Y_%m_%d_%H_%M_%S)

# read parameters
while test $# -gt 0 ; do
    case "$1" in
        --run-instantly)
                shift
                RunInstantly="1"
                ;;
        *)
                echo "No valid parameters"
                break
                ;;
        esac
done

echo "Test Setup: ${TestSetup}"
case ${TestSetup} in
        1)
          GrubOses=( "${GrubOsesF23P[@]}" )
          ;;
        2)
          GrubOses=( "${GrubOsesF26L[@]}" )
          ;;
        3)
          GrubOses=( "${GrubOsesG23[@]}" )
          ;;
        4)
          GrubOses=( "${GrubOsesG25A[@]}" )
          ;;
        5)
          GrubOses=( "${GrubOsesBL51E[@]}" )
          ;;
        6)
          GrubOses=( "${GrubOsesG25A[@]}" )
          ;;
        *)
                echo "TEST SETUP IS NOT SET"
                exit 99
                ;;
esac
        echo "GrubOses: ${GrubOses}"

JenkinsBackgroundPID=0

trap cleanOnExit SIGINT SIGTERM
function cleanOnExit() {
        echo "** cleanOnExit"
        echo "JenkinsBackgroundPID: ${JenkinsBackgroundPID}"
        if [ ${JenkinsBackgroundPID} -ne 0 ]; then
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
            grub_set_os "0"
        fi
        exit
}

function cleanJenkinsBackgroundJob {
        echo "** cleanOnExit"
        if [ ${JenkinsBackgroundPID} -ne 0 ]; then
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
        fi
}

function runTests {
            # run
            echo "runTests"
            St_Test_Setup_Configuration=""
            case ${TestSetup} in
                    1)
                      St_Test_Setup_Configuration="St_Test_Configuration_1.sh"
                      ;;
                    2)
                      St_Test_Setup_Configuration="St_Test_Configuration_2.sh"
                      ;;
                    3)
                      St_Test_Setup_Configuration="St_Test_Configuration_3.sh"
                      ;;
                    4)
                      St_Test_Setup_Configuration="St_Test_Configuration_4.sh"
                      ;;
                    5)
                      St_Test_Setup_Configuration="St_Test_Configuration_5.sh"
                      ;;
                    6)
                      St_Test_Setup_Configuration="St_Test_Configuration_6.sh"
                      ;;
                    *)
                      echo "TEST SETUP IS NOT SET"
                      exit 99
                      ;;
            esac

            # Make all scripts executable
            run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt=$'\r' chmod +x ${GitTestCommonDirPath}/*"
            run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt=$'\r' chmod +x ${GitTestTargetDirPath}/*"
            run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt=$'\r' chmod +x ${GitTestHostDirPath}/*"

            ./Jenkins_Background.sh &

            # Save background process PID 
            JenkinsBackgroundPID=$!
            echo "${LogPrefix} JenkinsBackgroundPID is ${JenkinsBackgroundPID}"

            # Run Test script - now scripts from remote device should be run 
            make_visible_in_log "TEST CASE - ${St_Test_Setup_Configuration}"
            run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt=$'\r' ${GitTestTargetDirPath}/${St_Test_Setup_Configuration} ${MenPcPassword} ${Today}"
            if [ $? -ne 0 ]; then
                    echo "${LogPrefix} Error while running St_Test_Configuration script"
            fi

            cleanJenkinsBackgroundJob
            # Initialize tested device 
            # run_cmd_on_remote_pc "mkdir $TestCaseDirectoryName"
            # Below command must be run from local device, 
            # Test scripts have not been downloaded into remote yet.
}

# MAIN start here
if [ "${RunInstantly}" == "1" ]; then
            ssh-keygen -R "${MenPcIpAddr}"
            # Check if devices are available
            if ! ping -c 2 "${MenPcIpAddr}"
            then
                    echo "${MenPcIpAddr} is not responding"
                    break
            fi

            cat "${MyDir}/../../Common/Conf.sh" > tmp.sh
            echo "RunInsantly=1" >> tmp.sh
            cat ${MyDir}/Pc_Configure.sh >> tmp.sh
            run_script_on_remote_pc ${MyDir}/tmp.sh
            if [ $? -ne 0 ]; then
                    echo "${LogPrefix} Pc_Configure script failed"
                    exit 
            fi
            rm tmp.sh

            runTests
else
    grub_set_os "0"
    for ExpectedOs in "${GrubOses[@]}"; do
            ssh-keygen -R "${MenPcIpAddr}"
            # Check if devices are available
            if ! ping -c 2 "${MenPcIpAddr}"
            then
                    echo "${MenPcIpAddr} is not responding"
                    break
            fi
            CurrentOs="$(grub_get_os)"
            if [ "${CurrentOs}" == "" ]; then
                    echo "Failed to get OS"
                    break
            fi
            if [ "${CurrentOs}" == "${ExpectedOs}" ]; then
                    if [ "${ExpectedOs}" == "${GrubOses[0]}" ]; then
                            continue
                    fi
                    echo "Unexpected OS \"${CurrentOs}\" while \"${ExpectedOs}\" was expected"
                    break
            fi
            grub_set_os "${ExpectedOs}"
            SetOs="$(grub_get_os)"
            if [ "${SetOs}" != "${ExpectedOs}" ]; then
                    echo "Failed to set OS"
                    break
            fi
            if ! reboot_and_wait
            then
                    echo "${MenPcIpAddr} is not responding"
                    break
            fi
            ssh-keygen -R "${MenPcIpAddr}"

            cat "${MyDir}/../../Common/Conf.sh" ${MyDir}/Pc_Configure.sh > tmp.sh
            run_script_on_remote_pc ${MyDir}/tmp.sh
            if [ $? -ne 0 ]; then
                    echo "${LogPrefix} Pc_Configure script failed"
                    exit 
            fi

            rm tmp.sh
            runTests
    done
fi
cleanOnExit
