#!/usr/bin/env bash
### @file generate_doxygen_documentation.sh
### @brief Automatically generate Doxygen documentation for MDIS
### @remark This script should be run in 13MD05-90 git repository main directory

################################################################################
# FUNCTIONS
################################################################################

### @brief Get 13MD05-90 repository URL
### @return Origin URL is echoed
getOriginUrl() {
        git remote get-url origin 2> "/dev/null"
}

### @brief Get 13MD05-90 repository root directory
### @return Root directory is echoed
getMainDir() {
        git rev-parse --show-toplevel 2> "/dev/null"
}

### @brief Get documentation directories
### @return Directories are echoed
getDocDirs() {
        find . -name DOC -type d \( -exec test -f '{}'/Doxyfile \; -and -exec test -d '{}'/html \; \) -printf '%P\n' 2> "/dev/null"
}

### @brief Get Doxygen version for documentation generation
### @param $1 String containing version
### @return Version string is echoed
### @return Empty string is echoed on error
getVersion() {
        local versionString

        if [[ "${1}" =~ (^|[[:space:]]+)version:([[:digit:]]+(\.[[:digit:]]+)*)($|[[:space:]]+) ]]; then
                versionString="${BASH_REMATCH[2]}"
        fi

        echo "${versionString}"
}

### @brief Get documentation generation order
### @param $1 String containing order
### @return Order string is echoed
### @return Empty string is echoed on error
getOrder() {
        local orderString

        if [[ "${1}" =~ (^|[[:space:]]+)order:([[:digit:]]+)($|[[:space:]]+) ]]; then
                orderString="${BASH_REMATCH[2]}"
        fi

        echo "${orderString}"
}

### @brief Get directory path for documentation relative to installation
### directory
### @param $1 Documentation directory string
### @return Directory string is echoed
### @return Empty string is echoed on error
getDir() {
        local directoryString

        if [[ "${1}" =~ ^[^/]+/(.+)$ ]]; then
                directoryString="${BASH_REMATCH[1]}"
        fi

        echo "${directoryString}"
}

### @brief Set MEN environment variables
### @param $1 MDIS installation directory
setMenVars() {
        if [ "${1}" != "" ]; then
                export MEN_DOXYGENTMPL="${1}/DOXYGENTMPL"
                export MEN_COM_INC="${1}/INCLUDE/COM"
                export MEN_MDIS_DRV_SRC="${1}/DRIVERS/MDIS_LL"
        else
                echo "MEN environment variables have not been set!" 1>&2
        fi
}

### @brief Get commit hash from Doxyfile
### @param $1 Path to Doxyfile
### @return Commit hash string is echoed
### @return Empty string is echoed on error
getDoxyCommit() {
        local commitString
        local hashString

        if [ -f "${1}" ]; then
                hashString="$(grep "^#MDIS_COMMIT=" "${1}")"
                if [[ "${hashString}" =~ ^\#MDIS_COMMIT=([[:xdigit:]]{40})$ ]]; then
                        commitString="${BASH_REMATCH[1]}"
                fi
        fi

        echo "${commitString}"
}

### @brief Set commit hash in Doxyfile
### @param $1 Path to Doxyfile
### @param $2 Commit hash string
### @return 0 if no error
### @return non-zero on error
setDoxyCommit() {
        if [ -f "${1}" ]; then
                if ! sed -i "s/^#MDIS_COMMIT=.*$/#MDIS_COMMIT=${2}/" "${1}"; then
                        echo "Unable to set commit hash in ${1}" 1>&2
                        return "1"
                fi
        fi

        return "0"
}

### @brief Get commit hash from repository
### @return Commit hash string is echoed
### @return Empty string is echoed on error
getRepoCommit() {
        local commitString
        local hashString

        hashString="$(git rev-parse HEAD 2> "/dev/null")"
        if [[ "${hashString}" =~ ^[[:xdigit:]]{40}$ ]]; then
                commitString="${hashString}"
        fi
        
        echo "${commitString}"
}


################################################################################
# MAIN
################################################################################

declare -r INSTALL_DIR="/opt/menlinux"
declare -r MAIN_DIR="${PWD}"
declare -r DEFAULT_VER="1.3.2"
declare -r ORIGIN_URL="https://github.com/MEN-Mikro-Elektronik/13MD05-90"
declare -A doxyList=( \
        ["MDISforLinux/LIBSRC/OSS/DOC"]="order:0 version:1.3.2" \
        ["MDISforLinux/LIBSRC/USR_OSS/DOC"]="order:1 version:1.3.2" \
        ["MDISforLinux/LIBSRC/MDIS_API/DOC"]="order:2 version:1.3.2" \
        ["13Y007-06/DRIVERS/MDIS_LL/F14BC/DOC"]="version:1.3" \
        ["13Y002-06/DRIVERS/MDIS_LL/F14_MON/DOC"]="version:1.3" \
        ["13PP04-06/DRIVERS/MDIS_LL/PP04/DOC"]="version:1.3" \
        ["13Z017-06/DRIVERS/MDIS_LL/Z017/DOC"]="version:1.3" \
        ["13Z051-06/DRIVERS/MDIS_LL/Z051/DOC"]="version:1.3" \
        ["13Z061-06/DRIVERS/MDIS_LL/Z061_PWM/DOC"]="version:1.3" \
        ["13Z082-06/DRIVERS/MDIS_LL/Z082/DOC"]="version:1.3" \
        ["13Z140-06/DRIVERS/MDIS_LL/Z140/DOC"]="version:1.3" \
#        ["MDISforLinux/LIBSRC/SMB2/COM/DOC"]="version:1.3" \
        ["13Y004-06/LIBSRC/SMB2_API/DOC"]="version:1.3" \
        ["13Y004-06/LIBSRC/SMB2_SHC/DOC"]="version:1.3" \
        ["MDISforLinux/TOOLS/FPGA_LOAD/DOC"]="version:1.3" \
        )
declare -a orderList

if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
        echo "This script cannot be sourced."
        echo "Quitting!"
        return "-1"
fi

if [ "${ORIGIN_URL}" != "$(getOriginUrl)" ] || \
        [ "${MAIN_DIR}" != "$(getMainDir)" ]; then
        echo "You must run this script while in 13MD05-90 git repository main directory!" 1>&2
        exit "-1"
fi

setMenVars "${INSTALL_DIR}"

for dir in $(getDocDirs); do
        if [ "${doxyList["${dir}"]}" == "" ]; then
                doxyList+=(["${dir}"]="")
        fi
done

declare -a tmpList
for doc in "${!doxyList[@]}"; do
        order="$(getOrder "${doxyList["${doc}"]}")"
        if [ "${order}" == "" ]; then
                order="not-important"
        fi
        tmpList+=("order:${order} ${doc}")
done
IFS=$'\n'
tmpList=($(sort -n <<< "${tmpList[*]}"))
unset IFS
for doc in "${tmpList[@]}"; do
        if [[ "${doc}" =~ ^order:(([[:digit:]]+)|(not-important))[[:space:]](.*)$ ]]; then
                orderList+=("${BASH_REMATCH[4]}")
        fi
done
unset tmpList

#if ! ./INSTALL.sh --install-only; then
#        echo "Installation returned error" 1>&2
#        exit "-1"
#fi

for doc in "${orderList[@]}"; do
        ver="$(getVersion "${doxyList["${doc}"]}")"
        if [ "${ver}" == "" ]; then
                ver="${DEFAULT_VER}"
        fi
        order="$(getOrder "${doxyList["${doc}"]}")"
        if ! cd "${MAIN_DIR}"; then
                echo "Unable to cd to ${MAIN_DIR}" 1>&2
                exit "-1"
        fi
        if ! cd "${doc}"; then
                echo "Unable to cd to ${doc}" 1>&2
                exit "-1"
        fi
        rcommit="$(getRepoCommit)"
        if [ "${rcommit}" == "" ]; then
                echo "Unabel to get commit hash for ${doc}" 1>&2
                continue
        fi
        dcommit="$(getDoxyCommit "Doxyfile")"
        if [ "${rcommit}" != "${dcommit}" ] || \
                [ "${order}" != "" ]; then
                dir="$(getDir "${doc}")"
                if ! cd "${INSTALL_DIR}/${dir}"; then
                        echo "Unable to cd to ${INSTALL_DIR}/${dir}" 1>&2
                        exit "-1"
                fi
                mv --force "html" "html.old" 2> "/dev/null"
#                if [ -d "html" ]; then
#                        rm -rf "html" 2> "/dev/null"
#                fi
                echo "Running doxygen in $(pwd)"
                if ! doxygen-${ver}; then
                        echo "Doxygen returned error" 1>&2
                        continue
                fi
                if ! diff --brief "${MAIN_DIR}/${doc}/html" "html" > "/dev/null" 2>&1; then
                        echo "Updating documentation for ${doc}" 1>&2
                        if ! rsync --recursive --delete "html" "${MAIN_DIR}/${doc}/"; then
                                echo "Unable to copy html to ${MAIN_DIR}/${doc}/" 1>&2
                                exit "-1"
                        else
                                echo "OK" 1>&2
                        fi
                fi
                ls ./*.tag > "/dev/null" 2>&1
                if [[ "${?}" != "2" ]]; then
                        echo "Copying tags" 1>&2
                        if ! rsync ./*.tag "${MAIN_DIR}/${doc}/"; then
                                echo "Unable to copy *.tag to ${MAIN_DIR}/${doc}/" 1>&2
                                exit "-1"
                        else
                                echo "OK" 1>&2
                        fi
                fi
                if ! setDoxyCommit "${MAIN_DIR}/${doc}/Doxyfile" "${rcommit}"; then
                        exit "-1"
                fi
        else
                echo "${doc} is up to date" 1>&2
        fi
done
