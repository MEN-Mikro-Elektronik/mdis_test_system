#!/usr/bin/env bash
### @file make_release_package.sh
### @brief Automatically generate release package for 13MD05-90
### @remark This script should be run in 13MD05-90 git repository main directory

################################################################################
# FUNCTIONS
################################################################################

### @brief Get 13MD05-90 repository URL
### @return Origin URL is echoed
getOriginUrl() {
	git remote get-url origin 2>"/dev/null"
}

### @brief Get 13MD05-90 repository root directory
### @return Root directory is echoed
getMainDir() {
	git rev-parse --show-toplevel 2>"/dev/null"
}

### @brief Get commit hash from repository
### @return Commit hash string is echoed
### @return Empty string is echoed on error
getRepoCommit() {
	local commitString
	local hashString

	hashString="$(git rev-parse HEAD 2>"/dev/null")"
	if [[ "${hashString}" =~ ^[[:xdigit:]]{40}$ ]]; then
		commitString="${hashString}"
	fi
	
	echo "${commitString}"
}

################################################################################
# MAIN
################################################################################

declare -r INSTALL_DIR="/tmp/menlinux"
declare -r MAIN_DIR="${PWD}"
declare -r ORIGIN_URL="https://github.com/MEN-Mikro-Elektronik/13MD05-90"
declare -r PACKAGE_NAME="13MD05-90"

if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
	echo "This script cannot be sourced."
	echo "Quitting!"
	return "1"
fi

if [ "${ORIGIN_URL}" != "$(getOriginUrl)" ] || \
	[ "${MAIN_DIR}" != "$(getMainDir)" ]; then
	echo "You must run this script while in 13MD05-90 git repository main directory!" 1>&2
	exit "1"
fi

if [ "$(basename "${MAIN_DIR}")" != "${PACKAGE_NAME}" ]; then
	echo "You should run this script wiile in \"$PACKAGE_NAME\" direcotry!" 1>&2
	exit "1"
fi

echo -n "Installing MDIS to temporary directory \"${INSTALL_DIR}\"..."
if ! "${PWD}/INSTALL.sh" --install-only --path="${INSTALL_DIR}" >/dev/null; then
	echo "ERROR"
	echo "Could not install MDIS!" 1>&2
	exit "1"
fi
echo "OK"

if ! cd ".." >/dev/null 2>&1; then
	echo "Could not enter parent directory!" 1>&2
	exit "1"
fi

echo -n "Creating .tar.gz package..."
if ! tar -c -z -f "${INSTALL_DIR}/${PACKAGE_NAME}.tar.gz" --exclude=".git*" "${PACKAGE_NAME}"; then
	echo "ERROR"
	echo "Could not create package!" 1>&2
	exit "1"
fi
echo "OK"
echo "\"${PACKAGE_NAME}.tar.gz\" created in \"${INSTALL_DIR}/\""

echo -n "Creating .zip package..."
if ! zip -q -r --exclude=\*.git\* "${INSTALL_DIR}/${PACKAGE_NAME}.zip" "${PACKAGE_NAME}"; then
	echo "ERROR"
	echo "Could not create package!" 1>&2
	exit "1"
fi
echo "OK"
echo "\"${PACKAGE_NAME}.zip\" created in \"${INSTALL_DIR}/\""
