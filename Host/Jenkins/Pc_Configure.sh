#! /bin/bash


# This script will perform configuration on Target
#       -check if MDIS sources exists, download otherwise
#       -check if Test Cases repository exists, download otherwise
#
#

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
                mkdir "${MainTestDirectoryPath}/${MainTestDirectoryName}"
                if [ $? -ne 0 ]; then
                        echo "ERR: ${ERR_CREATE} - cannot create directory"
                        return ${ERR_CREATE}
                fi
        else
                echo "${MainTestDirectoryPath}/${MainTestDirectoryName} directory exists"
        fi

        return ${ERR_OK}
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
                mkdir "${MdisResultsDirectoryPath}"
                if [ $? -ne 0 ]; then
                        echo "ERR: ${ERR_CREATE} - cannot create directory"
                        return ${ERR_CREATE}
                fi
        else
                echo "${MdisResultsDirectoryName} directory exists"
        fi

        return ${ERR_OK}
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
                rm -rf "${MainTestDirectoryPath}/${MainTestDirectoryName}/${TestSourcesDirectoryName}"
        fi

        ${GitTestSourcesCmd}
        if [ $? -ne 0 ]; then
                echo "ERR: ${ERR_CREATE} - cannot download Test Sources"
                return ${ERR_CREATE}
        fi
        return ${ERR_OK}
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
                download_13MD05_90_repository
                if [ $? -ne 0 ]; then
                        echo "ERR: ${ERR_DOWNLOAD} - cannot download Mdis"
                        return ${ERR_DOWNLOAD}
                fi
        else
                cd "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}"
                local CommitId="$(git log --pretty=format:'%H' -n 1)"
                local GitBranch="$(git branch | awk NR==1'{print $2}')"
                echo "On Branch: ${GitBranch}"
                echo "CommitId: ${CommitId}"
                echo "Comparision GitBranch: ${GitBranch} with ${GitMdisBranch} "
                if [ "${GitBranch}" != "${GitMdisBranch}" ]; then
                        cd .. 
                        rm -rf ${MdisSourcesDirectoryName}
                        download_13MD05_90_repository
                        if [ $? -ne 0 ]; then
                                echo "ERR: ${ERR_DOWNLOAD} - cannot download Mdis"
                                return ${ERR_DOWNLOAD}
                        fi
                else
                        if [ ! -z "${GitMdisCommitSha}" ]; then 
                                git reset --hard ${GitMdisCommitSha}
                                if [ $? -ne 0 ]; then
                                        echo "Wrong SHA detected"
                                        return ${ERR_CONF}
                                fi
                        else
                                #Go to most current commit 
                                git pull origin
                        fi
                        cd .. 
                fi
        fi
        return ${ERR_OK}
}

############################################################################
# downloads repository 
#

function download_13MD05_90_repository {
        ${GitMdisCmd}
        if [ $? -ne 0 ]; then
                echo "ERR: ${ERR_CREATE} - cannot download MDIS"
                return ${ERR_CREATE}
        fi
        cd "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}"
        local CommitId="$(git log --pretty=format:'%H' -n 1)"
        echo "CommitId: ${CommitId}"
        if [ ! -z "${GitMdisCommitSha}" ]; then 
                git reset --hard ${GitMdisCommitSha}
                if [ $? -ne 0 ]; then
                        echo "Wrong SHA detected"
                        return ${ERR_CONF}
                fi
        else
                #Go to most current commit 
                git pull origin
                git submodule update
        fi
        cd ..
        return ${ERR_OK}
}

############################################################################
# install MDIS sources 
#
# parameters:
#       None 
#
function install_13MD05_90_sources {

        if [ -d "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" ]; then
                local CurrentKernel="$(uname --kernel-release)"
                local SystemName="$(hostnamectl | grep "Operating System" | awk '{ print $3 }')"
                local IsYocto="$(hostnamectl | grep "Operating System" | grep "Yocto" | wc -l)"
                echo "IsYocto: ${IsYocto}"
                if [ "${SystemName}" == "CentOS" ]; then
                        echo "${MenPcPassword}" | sudo --stdin --prompt="" ln --symbolic --no-dereference --force "/usr/src/kernels/${CurrentKernel}" "/usr/src/linux"
                elif [ "${IsYocto}" == "1" ]; then
                        echo "${MenPcPassword}" | sudo --stdin --prompt="" ln --symbolic --no-dereference --force "/usr/src/kernel" "/usr/src/linux"
                        # make prepare
                        # make scripts
                else
                        echo "${MenPcPassword}" | sudo --stdin --prompt="" ln --symbolic --no-dereference --force "/usr/src/linux-headers-${CurrentKernel}" "/usr/src/linux"
                fi
                # install sources of MDIS
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -rf /opt/menlinux
                cd ${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName} 
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' ./INSTALL.sh --install-only
        else
                echo "ERR ${ERR_INSTALL} :no sources to install" 
                return ${ERR_INSTALL}
        fi
}

############################################################################
############################################################################
############################# MAIN START ###################################
############################################################################
############################################################################

# check if exists, and move into main directory 
echo "Start of Pc_Configure"
create_main_test_directory
if [ $? -ne 0 ]; then
        echo "ERR: create_main_test_directory"
        exit ${ERR_CONF}
fi

cd "${MainTestDirectoryPath}/${MainTestDirectoryName}"

create_result_directory
CmdResult=$?
echo "${CmdResult}"
if [ ${CmdResult} -ne ${ERR_OK} ]; then
        echo "ERR: create_result_directory"
        exit ${ERR_CONF}
fi

create_13MD05-90_directory
if [ $? -ne 0 ]; then
        echo "ERR: create_13MD05-90_directory"
        exit ${ERR_CONF}
fi

create_test_case_sources_directory
if [ $? -ne 0 ]; then
        echo "ERR: create_test_case_sources_directory"
        exit ${ERR_CONF}
fi

install_13MD05_90_sources
if [ $? -ne 0 ]; then
        echo "ERR: install_13MD05_90_sources"
        exit ${ERR_CONF}
fi

exit ${ERR_OK}

