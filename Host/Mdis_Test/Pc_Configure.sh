#! /bin/bash

# This script will perform configuration on Target
#       -check if MDIS sources exists, download otherwise
#       -check if Test Cases repository exists, download otherwise

############################################################################
# create main directory
#
# parameters:
#       None 
#
function create_main_test_directory {
    echo "create_main_test_directory"
    if [ ! -d "${MainTestDirectoryPath}/${MainTestDirectoryName}" ]; then
        # create and move to Test Case directory 
        if ! mkdir -p "${MainTestDirectoryPath}/${MainTestDirectoryName}"
        then
            echo "ERR: ${ERR_CREATE} - cannot create directory"
            return "${ERR_CREATE}"
        fi
    else
        echo "${MainTestDirectoryPath}/${MainTestDirectoryName} directory exists"
    fi
    return "${ERR_OK}"
}

############################################################################
# create result directory
#
# parameters:
#       None 
#
function create_result_directory {
    echo "create_result_directory"
    if [ ! -d "${MdisResultsDirectoryPath}" ]; then
        # create Results directory
        if ! mkdir "${MdisResultsDirectoryPath}"
        then
            echo "ERR: ${ERR_CREATE} - cannot create directory"
            return "${ERR_CREATE}"
        fi
    else
        echo "${MdisResultsDirectoryName} directory exists"
    fi
    return "${ERR_OK}"
}
############################################################################
# create directory with Test_case sources
# overwrite if sources are present
# if no, perform steps as below:
#       - create directory
#       - download repository with sources
#
# parameters:
#       None 
#
function create_test_case_sources_directory {
    # remove if exists 
    if [ -d "${MainTestDirectoryPath}/${MainTestDirectoryName}/${TestSourcesDirectoryName}" ]; then
        echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rm -rf "${MainTestDirectoryPath}/${MainTestDirectoryName}/${TestSourcesDirectoryName}"
    fi

    if ! ${GitTestSourcesCmd}
    then
        echo "ERR: ${ERR_CREATE} - cannot download Test Sources"
        return "${ERR_CREATE}"
    fi
    return "${ERR_OK}"
}

############################################################################
# create directory with MDIS sources
# function checks if directory exists and sources are valid 
# if no, perform steps as below:
#       - create directory
#       - download repository with sources
#
# parameters:
#       None 
#
function create_13MD05-90_directory {
    # create and download 
    if [ ! -d "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" ]; then
        # create and move to Test Case directory
        if ! download_13MD05_90_repository
        then
            echo "ERR: ${ERR_DOWNLOAD} - cannot download Mdis"
            return "${ERR_DOWNLOAD}"
        fi
    else
        cd "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" || return "${ERR_CONF}"
        local CommitId
        local GitBranch
        CommitId="$(git log --pretty=format:'%H' -n 1)"
        GitBranch="$(git branch | awk NR==1'{print $2}')"
        echo "On Branch: ${GitBranch}"
        echo "CommitId: ${CommitId}"
        echo "Comparision GitBranch: ${GitBranch} with ${GitMdisBranch} "
        if [ "${GitBranch}" != "${GitMdisBranch}" ]; then
            cd ..
            echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rm -rf "${MdisSourcesDirectoryName}"
            if ! download_13MD05_90_repository
            then
                echo "ERR: ${ERR_DOWNLOAD} - cannot download Mdis"
                return "${ERR_DOWNLOAD}"
            fi
        else
            if [ ! -z "${GitMdisCommitSha}" ]; then 
                if ! git reset --hard "${GitMdisCommitSha}"
                then
                    echo "Wrong SHA detected"
                    return "${ERR_CONF}"
                fi
            else
                #Go to most current commit 
                git pull origin
            fi
            cd ..
        fi
    fi
    return "${ERR_OK}"
}

############################################################################
# copy external MDIS sources into MDIS installation directory
#
# parameters:
#       None
#
function copy_external_sources {
    if [ -d "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" ]; then
        # check if external sources directory exists
        if [ -d "${MdisExternalDirectoryPath}" ]; then
            echo "${MenPcPassword}" | sudo -S --prompt=$'\r' cp -r "${MdisExternalDirectoryPath}"/* "${MainTestDirectoryPath}"/"${MainTestDirectoryName}"/"${MdisSourcesDirectoryName}"/
        fi
    fi
    return "${ERR_OK}"
}

############################################################################
# downloads repository 
#

function download_13MD05_90_repository {
    if ! ${GitMdisCmd}
    then
        echo "ERR: ${ERR_CREATE} - cannot download MDIS"
        return "${ERR_CREATE}"
    fi
    cd "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" || return "${ERR_CREATE}"
    local CommitId
    CommitId="$(git log --pretty=format:'%H' -n 1)"
    echo "CommitId: ${CommitId}"
    if [ ! -z "${GitMdisCommitSha}" ]; then 
        if ! git reset --hard "${GitMdisCommitSha}"
        then
            echo "Wrong SHA detected"
            return "${ERR_CONF}"
        fi
    else
        #Go to most current commit 
        git pull origin
        git submodule init
        git submodule update
    fi
    cd ..
    return "${ERR_OK}"
}

############################################################################
# install MDIS sources 
#
# parameters:
#       None 
#
function install_13MD05_90_sources {
    if [ -d "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" ]; then
        local CurrentKernel
        local SystemName
        local IsYocto
        CurrentKernel="$(uname --kernel-release)"
        SystemName="$(hostnamectl | grep "Operating System" | awk '{ print $3 }')"
        IsRedHat="$(hostnamectl | grep "Operating System" | grep -c "Red Hat")"
        IsYocto="$(hostnamectl | grep "Operating System" | grep -c "Yocto")"
        echo "IsYocto: ${IsYocto}"
        if [ "${SystemName}" == "CentOS" ] || [ "${IsRedHat}" == "1" ]; then
            echo "${MenPcPassword}" | sudo --stdin --prompt=$'\r' ln --symbolic --no-dereference --force "/usr/src/kernels/${CurrentKernel}" "/usr/src/linux"
        elif [ "${IsYocto}" == "1" ]; then
            echo "${MenPcPassword}" | sudo --stdin --prompt=$'\r' ln --symbolic --no-dereference --force "/usr/src/kernel" "/usr/src/linux"
            # make prepare
            # make scripts
        else
            echo "${MenPcPassword}" | sudo --stdin --prompt=$'\r' ln --symbolic --no-dereference --force "/usr/src/linux-headers-${CurrentKernel}" "/usr/src/linux"
        fi
        # install sources of MDIS
        if [ "${RUN_INSTANTLY}" != "1" ]; then
            echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rm -rf /opt/menlinux
            echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rm -f /lib/modules/"$(uname -r)"/misc/men_*.ko
            echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rm -f /etc/mdis/*.bin
            cd "${MainTestDirectoryPath}"/"${MainTestDirectoryName}"/"${MdisSourcesDirectoryName}" || return "${ERR_INSTALL}"
            echo "${MenPcPassword}" | sudo -S --prompt=$'\r' ./INSTALL.sh --install-only
        else
            if [ ! -d /opt/menlinux ]; then
                echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rm -f /lib/modules/"$(uname -r)"/misc/men_*.ko
                echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rm -f /etc/mdis/*.bin
                cd "${MainTestDirectoryPath}"/"${MainTestDirectoryName}"/"${MdisSourcesDirectoryName}" || return "${ERR_INSTALL}"
                echo "${MenPcPassword}" | sudo -S --prompt=$'\r' ./INSTALL.sh --install-only
            fi
        fi
    else
        echo "ERR ${ERR_INSTALL} :no sources to install" 
        return "${ERR_INSTALL}"
    fi
}

############################################################################
############################################################################
############################# MAIN START ###################################
############################################################################
############################################################################

# check if exists, and move into main directory 
echo "Start of Pc_Configure"

if ! create_main_test_directory
then
    echo "ERR: create_main_test_directory"
    exit "${ERR_CONF}"
fi

cd "${MainTestDirectoryPath}/${MainTestDirectoryName}" || exit "${ERR_CONF}"


if ! create_result_directory
then
    echo "ERR: create_result_directory"
    exit "${ERR_CONF}"
fi


if ! create_13MD05-90_directory
then
    echo "ERR: create_13MD05-90_directory"
    exit "${ERR_CONF}"
fi

copy_external_sources


if ! create_test_case_sources_directory
then
    echo "ERR: create_test_case_sources_directory"
    exit "${ERR_CONF}"
fi


if ! install_13MD05_90_sources
then
    echo "ERR: install_13MD05_90_sources"
    exit "${ERR_CONF}"
fi

exit "${ERR_OK}"

