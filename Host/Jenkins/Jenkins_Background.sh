#! /bin/bash

MyDir="$(dirname "$0")"
source "$MyDir/../../Common/Conf.sh"
source "$MyDir/Jenkins_Functions.sh"
LogPrefix="[Background_Job]"

# This script checks 
#       if tests are running correctly, 
#       if there is any action required from target side - example change inputs

CheckFileExistsCmd="[ -f ${LockFileName} ] && echo \"true\" || echo \"false\""
FileExist=$(run_cmd_on_remote_pc "${CheckFileExistsCmd}")


# Remove lock file if exists 
# This is executed before Test Case is started 
echo "${LogPrefix} Lock file should not exists. This field should be \"false\": ${FileExist}"
if [ "${FileExist}" = "true" ]; then
        run_cmd_on_remote_pc "rm ${LockFileName}"
fi

while true; do
        sleep 2
        # Check if there is sth to do 
        FileExist=$(run_cmd_on_remote_pc "${CheckFileExistsCmd}")
        if [ "${FileExist}" = "true" ]; then
                # Read from lock file, which input should be changed
                echo "${LogPrefix} Lock file exists: change input ${LockFileData}"  
                CommandCode=$(read_command_code_lock_file)
                ######################
                # Change inputs here #
                ######################
                if [ ${CommandCode} -ge ${IN_0_ENABLE} ]; then
                        change_input_BL51E ${CommandCode} ${LogPrefix}
                        if [ $? -eq ${ERR_OK} ]; then
                                #echo "${LogPrefix} Success: ${CommandCode} set on remote switch"
                                write_command_code_lock_file_result ${LockFileSuccess} ${LogPrefix}
                        else
                                #echo "${LogPrefix} Failed: ${CommandCode} set on remote switch"
                                write_command_code_lock_file_result ${LockFileFailed} ${LogPrefix}
                        fi
                fi
        fi
done

