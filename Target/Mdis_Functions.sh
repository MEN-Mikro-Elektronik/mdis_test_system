#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}"/../Common/Conf.sh

############################################################################
# Run system_scan.sh, then perform make and make install.
# If error occurs stop and exit with proper error code
#
# parameters:
# $1    Log Prefix
function scan_and_install {
    local LogPrefix="${1} "
    echo "${LogPrefix}function scan_and_install"
    local CmdResult="${ERR_UNDEFINED}"

    # scan the hardware
    if ! run_as_root /opt/menlinux/scan_system.sh /opt/menlinux --assume-yes --internal-swmodules > scan_system_output.txt 2>&1
    then
        echo "${LogPrefix}ERR_SCAN :scan_system script error"
        return "${ERR_SCAN}"
    fi

    make_install "${LogPrefix}"
}

############################################################################
# Perform make and make install.
# If error occurs stop and exit with proper error code
#
# parameters:
# $1    Log Prefix
function make_install {
    local LogPrefix="${1} "
    echo "${LogPrefix}make_install"

    if ! run_as_root make > make_output.txt 2>&1 
    then
        echo "ERR 3 :make error" 
        exit "${ERR_MAKE}"
    fi

    if ! run_as_root make install > make_install_output.txt 2>&1
    then
        echo "${LogPrefix}ERR 4 :make install error"
        exit "${ERR_INSTALL}"
    fi
}


############################################################################
# Get mdis sources commit sha
#
# parameters:
#       None
function get_mdis_sources_commit_sha {
    local CurrDir
    CurrDir=$(pwd)
    cd "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" || exit "${ERR_NOEXIST}"
    local CommitIdShortened
    CommitIdShortened=$(git log --pretty=format:'%h' -n 1)
    local SystemName
    SystemName=$(hostnamectl | grep "Operating System" | awk '{ print $3"_"$4 }')
    cd "${CurrDir}" || exit "${ERR_NOEXIST}"

    echo "${CommitIdShortened}"
}

############################################################################
# mdis_prepare - perform:
#       - scan system
#       - make
#       - make install
#
# parameters:
# $1    Directory name
# $1    Log Prefix
function mdis_prepare {
    local DirectoryName="${1}"
    local LogPrefix="${2}"
    cd "${DirectoryName}" || exit "${ERR_NOEXIST}"

    # Scan, make and make install 
    if ! scan_and_install "${LogPrefix}"
    then
        return "${CmdResult}"
    fi

    # Check if any errors exists in output files
    if ! error_check "${LogPrefix}"
    then
        return "${CmdResult}"
    fi

    # Check this files:
    # make_output.txt
    # make_install_output.txt 2>&1

    # Check if any errors exists in output files
    if ! warning_check "make_output.txt"
    then
        return "${CmdResult}"
    fi

    if ! warning_check "make_install_output.txt"
    then
        return "${CmdResult}"
    fi
}

############################################################################
# Run_test_case_common_end_actions - perform: 
#       - Clean files 
#       - Remove all modprobed men modules

# parameters:
# $1    TestCaseLogName
# $2    TestCaseName
# $3    Log Prefix
function run_test_case_common_end_actions {
    local TestCaseLogName="${1}"
    local TestCaseName="${2}"
    local LogPrefix="${3}"

    # remove unnecessary files
    if ! clean_test_case_files
    then
        debug_print "${LogPrefix} clean_test_case_files error" "${TestCaseLogName}"
        return "${ERR_VALUE}"
    fi

    debug_print "${LogPrefix} case ${TestCaseName} finished" "${TestCaseLogName}"

    return "${ERR_OK}"
}

############################################################################
# Find and remove all men_xx loaded drivers
#
# parameters:
#       None
function rmmod_all_men_modules {
    local MenLsmodModuleCnt
    MenLsmodModuleCnt=$(lsmod | grep ^men_ | awk '{print $1}' | wc -l)
    for i in $(seq 1 ${MenLsmodModuleCnt});
    do
        #echo "$i rmmod $(lsmod | grep men_ | awk NR==1'{print $1}')"
        if ! run_as_root rmmod "$(lsmod | grep ^men_ | awk NR==1'{print $1}')"
        then
            echo "ERR_RMMOD :cannot rmmod module $(lsmod | grep ^men_ | awk NR==1'{print $1}')"
            return "${ERR_RMMOD}"
        fi
    done
}

############################################################################
# Remove directories that have been created during make
#
# parameters:
#       None
function clean_test_case_files {
    run_as_root rm -rf BIN/
    run_as_root rm -rf DESC/
    run_as_root rm -rf LIB/
    run_as_root rm -rf OBJ/
    #echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -rf /etc/mdis/*
    #echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -rf /lib/modules/linux_src ../misc/*
}
############################################################################
# Check if warning exists in files.. 
#
# parameters:
# $1    File name
function warning_check {
    local FileName="${1}"

    if < "${FileName}" grep "warning:" >/dev/null
    then
        echo "Warning Check FAILED!"
        return "${ERR_WARNING}"
    fi

    return "${ERR_OK}"
}

############################################################################
# Check if error exists in files.. 
#
# parameters:
# $1    File name
function error_check {
    local FileName="${1}"
    if grep -i "error:" "${FileName}" >/dev/null
    then
        echo "Error Check FAILED!"
        return "${ERR_MAKE}"
    fi

    return "${ERR_OK}"
}

