#!/bin/bash
#

MyDir="$(dirname "$0")"
# shellcheck source=./Conf.sh
source "${MyDir}/Conf.sh"

CurrentDir=$(pwd)
DATE=$(date '+%Y%m%d%H%M%S')

#
# build test script for a general MDIS project
# to build drivers under all kernels listed in
# TEST_KERNEL_DIR
#

############################################################################
# create main Compilation results directory
#
# parameters:
#       None 
#
function create_main_test_directory {
        echo "create main Compilation results directory"
        local Retval=0
        if [ ! -d "${MainTestDirectoryPath}/${MainTestDirectoryName}" ]; then
                # create and move to Test Case directory 
                mkdir -p "${MainTestDirectoryPath}/${MainTestDirectoryName}"
                Retval=$?
                if [ ${Retval} -ne 0 ]; then
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
        local Retval=0
        if [ ! -d "${MdisResultsDirectoryPath}" ]; then
                # create Results directory
                mkdir -p "${MdisResultsDirectoryPath}"
                Retval=$?
                if [ ${Retval} -ne 0 ]; then
                        echo "ERR: ${ERR_CREATE} - cannot create directory"
                        return "${ERR_CREATE}"
                fi
        else
                echo "${MdisResultsDirectoryPath} directory exists"
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
        local Retval=0
        if [ ! -d "${MainTestDirectoryPath}/${MainTestDirectoryName}/${MdisSourcesDirectoryName}" ]; then
                # create and move to Test Case directory
                download_13MD05_90_repository
                Retval=$?
                if [ ${Retval} -ne 0 ]; then
                        echo "ERR: ${ERR_DOWNLOAD} - cannot download MDIS"
                        return "${ERR_DOWNLOAD}"
                fi
        else
                cd "${MdisSourcesDirectoryPath}" || (echo "Could not enter directory \"${MdisSourcesDirectoryPath}\". Quitting!" && exit 1)
                local CommitId
                CommitId=$(git log --pretty=format:'%H' -n 1)
                local GitBranch
                GitBranch=$(git branch | awk NR==1'{print $2}')

                echo "On Branch: ${GitBranch}"
                echo "CommitId: ${CommitId}"
                echo "Comparision GitBranch: ${GitBranch} with ${GitMdisBranch} "
                if [ "${GitBranch}" != "${GitMdisBranch}" ]; then
                        cd ".."
                        rm -rf "${MdisSourcesDirectoryPath}"
                        if ! download_13MD05_90_repository; then
                                echo "ERR: ${ERR_DOWNLOAD} - cannot download MDIS"
                                return "${ERR_DOWNLOAD}"
                        fi
                else
                        if [ -n "${GitMdisCommitSha}" ]; then 
                                if ! git reset --hard ${GitMdisCommitSha}; then
                                        echo "Wrong SHA detected"
                                        return "${ERR_CONF}"
                                fi
                        else
                                #Go to most current commit 
                                git pull origin
                                git submodule init
                                git submodule update
                        fi
                        cd ".."
                fi
        fi
        return "${ERR_OK}"
}

############################################################################
# downloads repository 
#

function download_13MD05_90_repository {
        ${GitMdisCmd}
        local Retval=0
        Retval=$?
        if [ ${Retval} -ne 0 ]; then
                echo "ERR: ${ERR_CREATE} - cannot download MDIS"
                return "${ERR_CREATE}"
        fi
        cd "${MdisSourcesDirectoryPath}" || (echo "Could not enter directory \"${MdisSourcesDirectoryPath}\". Quitting!" && exit 1)
        local CommitId
        CommitId=$(git log --pretty=format:'%H' -n 1)
        echo "CommitId: ${CommitId}"
        if [ -n "${GitMdisCommitSha}" ]; then 
                git reset --hard ${GitMdisCommitSha}
                Retval=$?
                if [ ${Retval} -ne 0 ]; then
                        echo "Wrong SHA detected"
                        return "${ERR_CONF}"
                fi
        else
                #Go to most current commit 
                git pull origin
                git submodule init
                git submodule update
        fi
        # shellcheck disable=SC2103
        cd ".."
        return "${ERR_OK}"
}

############################################################################
# install MDIS sources 
#
# parameters:
#       None 
#
function install_13MD05_90_sources {

        echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -rf ${MdisSourcesDirectoryInstallPath}

        if [ -d "${MdisSourcesDirectoryPath}" ]; then
                # install sources of MDIS
                # echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -rf /opt/menlinux
                cd "${MdisSourcesDirectoryPath}" || (echo "Could not enter directory \"${MdisSourcesDirectoryPath}\". Quitting!" && exit 1)
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' ./INSTALL.sh --path=${MdisSourcesDirectoryInstallPath} --install-only
        else
                echo "ERR ${ERR_INSTALL} :no sources to install"
                echo "Make sure that sources are in ${MdisResultsDirectoryPath}" 
                return "${ERR_INSTALL}"
        fi
}


###############################################################################
# usage text
#
function usage {
    echo "run_buildtest.sh - test MDIS compilation"
    echo ""
    echo "USAGE"
    echo "    run_buildtest.sh -h | --help"
    echo "    run_buildtest.sh [--download] [--all | --short | --run-failed | --makefile <file>]"
    echo ""
    echo "DESCRIPTION"
    echo "  1. Please specify all required parameters in Conf.sh (Branch, commit id, paths ... )"
    echo "  2. Make sure that Linux kernel sources are available in LinuxKernelsDirectoryPath"
    echo "     specified in Conf.sh file."
    echo "  3. Specify list of all downloaded kernels in kernel_list_release_02.txt."
    echo "  4. In order to compile all drivers in MDIS (dbg, nodgb) and download required"
    echo "     MDIS sources, please run command:"
    echo "     sudo ./run_buildtest.sh --download --all"
    echo "  5. FAILED mak files will be copied into <kernel_ver>_MakefilesListFailed.log"
    echo "     To compile only failed Makefiles with updated sources, please run command:"
    echo "     sudo ./run_buildtest.sh --run-failed"
    echo "  6. In order to compile Makefiles specified by user"
    echo "     please create file MakefilesListShort.log and then please run command:"
    echo "     (Compile on kernels specified in kernel_list_release_02.txt)"
    echo "  7. sudo ./run_buildtest.sh --short"
    echo "  "
    echo "    !!! Please specify all required parameters in Conf.sh file !!!"
    echo "    Please remember to add --download flag when MDIS sources are unavailable"
    echo ""
    echo "OPTIONS"
    echo "    -h, --help"
    echo "        Print help"
    echo ""
    echo "    --download"
    echo "        Download MDIS sources"
    echo ""
    echo "    --all"
    echo "        Run all available .mak on all kernels"
    echo ""
    echo "    --short"
    echo "        Compile only short list of modules"
    echo ""
    echo "    --run-failed"
    echo "        Run only failed Makefiles"
    echo ""
    echo "    --makefile <file>"
    echo "        Use <file> as Makefile for compilation test"
}

###############################################################################
# do_or_die {command-list}
# execute command-list and exit script if that fails
# NOTICE: beware of quotes and the like the might need escaping
do_or_die()
{
    eval "$@" || exit $?
}

###############################################################################
# checkout the given kernel version from the repo
#
function checkout_kernel_version {
  currdir=$(pwd)
  cd "${TEST_KERNEL_DIR}" || (echo "Could not enter directory \"${TEST_KERNEL_DIR}\". Quitting!" && exit 1)
  # wipe leftovers from previous checked out version by forced checkout
  make clean
  make distclean
  make defconfig
  make prepare
  make scripts
  make modules_prepare
  cd "${currdir}" || (echo "Could not enter directory \"${currdir}\". Quitting!" && exit 1)
}


###############################################################################
# build MDIS project against one kernel
#
function build_mdis {
  echo " ============================================"
  echo " building MDIS project using kernel $1"
  echo " ============================================"

  # build MDIS Project...
  make clean
  make 2>&1 | tee "buildlog_$1.log"
}


function automatic_driver_test {

        local GCC_VERSION
        GCC_VERSION=$(gcc --version | awk NR==1'{print $4}')
        local STR_RESULT_DIR="${4}/TestOutput_${1}_GCC_${GCC_VERSION}_${DATE}_${5}"
        local STR_RESULT_FILE="${STR_RESULT_DIR}/TestResults.log"
        local Retval=0
        local Modules
        local Module
        local Version

        rm -rf "${STR_RESULT_DIR}"
        mkdir -p "${STR_RESULT_DIR}"

        # Check if flag for compilation of failed Makefiles is set 
        if [ -n "${6}" ]; then
            if [ "${6}" -eq "1" ]; then
                # Check if failed Makefiles compilation short list exists
                if [ -f "${MakefilesCompilationListShort}" ]; then
                    cp "${MakefilesCompilationListShort}" MakefilesList.tmp
                    MakefilesNumber=$(wc -l <MakefilesList.tmp)
                else
                    echo "There is no short list of makefiles: ${MakefilesCompilationListShort}"
                    return 1
                fi
            elif [ "${6}" -eq "2" ]; then
                # Check if failed Makefiles compilation list exists
                if [ -f "${1}_${MakefilesCompilationListFailed}" ]; then
                    cp "${1}_${MakefilesCompilationListFailed}" "${1}_${MakefilesCompilationListFailed}.bak"
                    cp "${1}_${MakefilesCompilationListFailed}" MakefilesList.tmp
                    echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm "${1}_${MakefilesCompilationListFailed}"
                    MakefilesNumber=$(wc -l <MakefilesList.tmp)
                else
                    echo "There is no list of failed Makefiles"
                    return 1
                fi
            else
                echo "Err"
                return 1
            fi
        else
            if [ -z "${BuildMakefile}" ]; then
                # Check list of all available Makefiles in Makefiles directory
                # Save list into temporary file
                cd "Makefiles/" || (echo "Could not enter directory \"Makefiles/\". Quitting!" && exit 1)
                find . -maxdepth 1 -type f -printf '%P\n' | grep Makefile > ../MakefilesList.tmp
                MakefilesNumber=$(wc -l <../MakefilesList.tmp)
                cd ".."
            else
                if [ -e "${BuildMakefile}" ]; then
                    echo "${BuildMakefile}" > MakefilesList.tmp
                    MakefilesNumber=$(wc -l <MakefilesList.tmp)
                else
                    echo "Makefile \"${BuildMakefile}\" not found. Quitting!"
                    exit 1
                fi
            fi
            if [ -f "${1}_${MakefilesCompilationListFailed}" ]
            then
                cp "${1}_${MakefilesCompilationListFailed}" "${MakefilesCompilationListFailed}.bak"
                echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm "${1}_${MakefilesCompilationListFailed}"
            fi
        fi

        touch "${STR_RESULT_DIR}/TestResults.log"
        touch "${1}_${MakefilesCompilationListFailed}"

        echo "Results:" >> "${STR_RESULT_FILE}"

        local CurrentMakefileNumber=1

        while read -r Makefile <&13;
        do
                # loop through the Makefiles
                echo "${Makefile} compiling  ${CurrentMakefileNumber} of ${MakefilesNumber}" 
                CurrentMakefileNumber=$((CurrentMakefileNumber+1))

                if [ -e "Makefile" ]; then
                        make clean >/dev/null
                fi

                if [ -z "${BuildMakefile}" ]; then
                    cp "Makefiles/${Makefile}" Makefile &>/dev/null
                else
                    cp "${Makefile}" Makefile &>/dev/null
                fi

                #change kernel directory path
                sed -i "/.*MEN_LIN_DIR =.*/c MEN_LIN_DIR = ${2}" Makefile
                sed -i "/.*LIN_KERNEL_DIR =.*/c LIN_KERNEL_DIR = ${3}" Makefile

                #change dbg/nodbgoptions, based on given parameter
                sed -i "/.*ALL_DBGS =.*/c ALL_DBGS = ${5}" Makefile
                
                Retval=$?
                if [ ${Retval} -eq 0 ]
                then 
                        touch "${STR_RESULT_DIR}/${Makefile}.log"
                        make >"${STR_RESULT_DIR}/${Makefile}.log" 2>&1
                        Retval=$?
                        if [ ${Retval} -eq 0 ]
                        then 
                                grep warning: "${STR_RESULT_DIR}/${Makefile}.log" >/dev/null
                                Retval=$?
                                if [ ${Retval} -eq 0 ]
                                then 
                                        echo "${Makefile} PASSED_CONDITIONALY" >> "${STR_RESULT_FILE}"
                                        echo "${Makefile} PASSED_CONDITIONALY" 
                                        echo "${Makefile}" >> "${1}_${MakefilesCompilationListFailed}"
                                else
                                        echo "${Makefile} PASSED" >> "${STR_RESULT_FILE}"
                                        echo "${Makefile} PASSED"
                                fi
                        else
                                echo "${Makefile} FAILED" >> "${STR_RESULT_FILE}"
                                echo "${Makefile} FAILED"
                                echo "${Makefile}" >> "${1}_${MakefilesCompilationListFailed}"
                        fi
                fi

                # Checking version of compiled kernel modules
                mkdir -p "${STR_RESULT_DIR}/ModinfoResults"
                touch "${STR_RESULT_DIR}/ModinfoResults.log"
                Modules=$(find "OBJ/" -name '*.ko' -type f)
                for Module in ${Modules}; do
                        echo ${MenPcPassword} | sudo -S --prompt=$'\r' modinfo "${Module}" > "${STR_RESULT_DIR}/ModinfoResults/${Module##*/}.${Makefile}.log"
                        Version="$(echo ${MenPcPassword} | sudo -S --prompt=$'\r' modinfo "${Module}" | grep -l "^version:")"
                        if [ "${Version}" != "" ]; then
                                echo "${Module##*/}.${Makefile} PASSED" >> "${STR_RESULT_DIR}/ModinfoResults.log"
                        else
                                echo "${Module##*/}.${Makefile} FAILED" >> "${STR_RESULT_DIR}/ModinfoResults.log"
                        fi
                done

        done 13< MakefilesList.tmp
        echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm MakefilesList.tmp

}

############################################################################
############################################################################
############################# MAIN START ###################################
############################################################################
############################################################################

# read parameters
while test $# -gt 0 ; do
   case "$1" in 
        -h|--help)
                usage
                exit 1
                ;;
        --download)
                shift
                export DownloadMDIS="1"
                echo "Download MDIS sources"
                echo "If commit SHA is given in Conf.sh file, then this "
                echo "particular commit will be tested"
                ;;
        --short)
                shift
                export CompileShortList="1"
                echo "Compile only Failed modules"
                ;;
        --run-failed)
                shift
                export CompileShortList="2"
                echo "Compile Failed modules"
                ;;
        --gcc)
                shift
                if test $# -gt 0; then
                        export GCC_Version=$1
                        echo "Compile all kernels on GCC version: ${GCC_Version}"
                else
                        echo "no path specified"
                        exit 1
                fi
                shift
                ;;
        --all)
                shift
                export BuildAllKernelGcc="1"
                echo "Compile all kernels on all available gcc versions"
                echo "Go for tee" 
                ;;
        --makefile)
                shift
                if test $# -gt 0; then
                    export BuildMakefile=$1
                else
                    echo "No Makefile for \"--makefile\" specified"
                    exit 1
                fi
                shift
                ;;
        *)
                break
                ;;
        esac
done

# check if exists, and move into main directory 
echo "Start of Pc_Configure"
create_main_test_directory
Retval=$?
if [ ${Retval} -ne 0 ]; then
        echo "ERR: create_main_test_directory"
        exit "${ERR_CONF}"
fi

cd "${LinuxKernelsDirectoryPath}" || (echo "Could not enter directory \"${LinuxKernelsDirectoryPath}\". Quitting!" && exit 1)

LinuxKernelNameInit=$(head -n 1 "${CurrentDir}/kernel_list_release_02.txt")

ln -sfn "linux-${LinuxKernelNameInit}" linux

cd "${MdisMainDirectoryPath}" || (echo "Could not enter directory \"${MdisMainDirectoryPath}\". Quitting!" && exit 1)

create_result_directory
CmdResult=$?

if [[ ${CmdResult} -ne ${ERR_OK} ]]; then
        echo "ERR: create_result_directory"
        exit "${ERR_CONF}"
fi

if [ "${DownloadMDIS}" == "1" ] ; then
        if ! create_13MD05-90_directory; then
                echo "ERR: create_13MD05-90_directory"
                exit "${ERR_CONF}"
        fi
fi

# MDIS source Install should allways be performed before compilation
install_13MD05_90_sources

# Go to directory where this script is located 
cd "${CurrentDir}" || (echo "Could not enter directory \"${CurrentDir}\". Quitting!" && exit 1)

# Compiling Makefiles ... 
if [ "${BuildAllKernelGcc}" == "1" ] || [ "${CompileShortList}" == "1" ] || [ "${CompileShortList}" == "2" ]; then
        while read -r kern_version <&11;
        do
                currdir="$(pwd)"
                cd "${TEST_KERNEL_DIR}" || (echo "Could not enter directory \"${TEST_KERNEL_DIR}\". Quitting!" && exit 1)
                # shellcheck disable=SC2103
                cd ".."
                rm linux
                ln -sfn "linux-${kern_version}" linux
                cd "${currdir}" || (echo "Could not enter directory \"${currdir}\". Quitting!" && exit 1)

                checkout_kernel_version "${kern_version}"
                echo " ============================================================"
                echo " ==     building MDIS project using kernel ${kern_version}      "
                echo " ============================================================"
                echo " ============================dbg============================="
                automatic_driver_test "${kern_version}" ${MEN_LIN_DIR} ${TEST_KERNEL_DIR} ${MdisResultsDirectoryPath} "dbg" ${CompileShortList}
                Retval_dbg=$?
                echo " ============================nodbg==========================="
                automatic_driver_test "${kern_version}" ${MEN_LIN_DIR} ${TEST_KERNEL_DIR} ${MdisResultsDirectoryPath} "nodbg" ${CompileShortList} 
                Retval_nodbg=$?
                if [ ${Retval_dbg} -ne 0 ] || [ ${Retval_nodbg} -ne 0 ]; then
                        echo "ERR: automatic_driver_test for ${kern_version} FAILED!!!"
                        echo " --------- Test for ${kern_version} FAILED ------------ "
                else
                        echo " --------- Test for ${kern_version} COMPLETE ------------ "
                fi

        done 11< kernel_list_release_02.txt
fi

if [ -e "Makefile" ]; then
        make clean
fi
echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -f Makefile
echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -rf DESC
echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -rf LIB
echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -rf BIN
echo ${MenPcPassword} | sudo -S --prompt=$'\r' rm -rf OBJ
