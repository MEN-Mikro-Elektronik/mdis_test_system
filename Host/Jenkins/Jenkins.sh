#! /bin/bash

MyDir="$(dirname "$0")"
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/Jenkins_Functions.sh"
LogPrefix="[Jenkins]"

# This script checks if hardware is present
# Jenkins run result identification
Today=$(date +%Y_%m_%d_%H_%M_%S)


function Test_Setup_1_Configure {
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 0e:0d.0 COMMAND=0x7"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 0e:0e.0 COMMAND=0x7"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 09:00.0 COMMAND=0x7"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 0a:00.0 COMMAND=0x7"
}

function Test_Setup_3_Configure {
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 0e:0d.0 COMMAND=0x7"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 09:00.0 COMMAND=0x7"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 0e:0e.0 COMMAND=0x7"
}

function Test_Setup_6_Configure {
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 02:00.0 COMMAND=0x7"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 0f:00.0 COMMAND=0x7"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 10:00.0 COMMAND=0x7"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= setpci -s 08:00.0 COMMAND=0x7"
}

echo "Test Setup: ${TestSetup}"
case ${TestSetup} in
        1)
          GrubOses=( "${GrubOsesF26L[@]}" )
          ;;
        2)
          GrubOses=( "${GrubOsesF23P[@]}" )
          ;;
        3)
          GrubOses=( "${GrubOsesF26L[@]}" )
          ;;
        4)
          GrubOses=( "${GrubOsesF23P[@]}" )
          ;;
        5)
          GrubOses=( "${GrubOsesG22[@]}" )
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

# MAIN start here
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

        # run

        St_Test_Setup_Configuration=""
        case ${TestSetup} in
                1)
                  Test_Setup_1_Configure
                  St_Test_Setup_Configuration="St_Test_Configuration_1.sh"
                  ;;
                2)
                  St_Test_Setup_Configuration="St_Test_Configuration_2.sh"
                  ;;
                3)
                  Test_Setup_3_Configure
                  St_Test_Setup_Configuration="St_Test_Configuration_3.sh"
                  ;;
                4)
                  St_Test_Setup_Configuration="St_Test_Configuration_4.sh"
                  ;;
                5)
                  St_Test_Setup_Configuration="St_Test_Configuration_5.sh"
                  ;;
                6)
                  Test_Setup_6_Configure
                  St_Test_Setup_Configuration="St_Test_Configuration_6.sh"
                  ;;
                *)
                  echo "TEST SETUP IS NOT SET"
                  exit 99
                  ;;
        esac

        # Make all scripts executable
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= chmod +x ${GitTestCommonDirPath}/*"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= chmod +x ${GitTestTargetDirPath}/*"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= chmod +x ${GitTestHostDirPath}/*"

        ./Jenkins_Background.sh &

        # Save background process PID 
        JenkinsBackgroundPID=$!
        echo "${LogPrefix} JenkinsBackgroundPID is ${JenkinsBackgroundPID}"

        # Run Test script - now scripts from remote device should be run 
        make_visible_in_log "TEST CASE - ${St_Test_Setup_Configuration}"
        run_cmd_on_remote_pc "echo ${MenPcPassword} | sudo -S --prompt= ${GitTestTargetDirPath}/${St_Test_Setup_Configuration} ${MenPcPassword} ${Today}"
        if [ $? -ne 0 ]; then
                echo "${LogPrefix} Error while running St_Test_Configuration script"
        fi

        cleanOnExit

        # Initialize tested device 
        # run_cmd_on_remote_pc "mkdir $TestCaseDirectoryName"
        # Below command must be run from local device, 
        # Test scripts have not been downloaded into remote yet. 
done
