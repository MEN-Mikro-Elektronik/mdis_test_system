if [ -f "Conf.sh" ]; then
    source Conf.sh
fi

############################################################################
# Run command as root
#
# parameters:
# $1     command to run
function run_as_root {
    if [ "${#}" -gt "0" ]; then
        echo "${MenPcPassword}" | sudo -S --prompt=$'\r' -- ${@}
    fi
}

############################################################################
# Print into terminal and into log file
#
# parameters:
# $1     Msg to print/log
# $2     Log file name
function print {
    local Msg="${1}"
    local LogFile="${2}"
    echo "${Msg}" | tee -a "${LogFile}" 2>&1
}

############################################################################
# Print debug verbose information into terminal and into log file
#
# parameters:
# $1     Msg to print/log
# $2     Log file name
function debug_print {
    local Msg="${1}"
    local LogFile="${2}"
    if [ "${VERBOSE_LEVEL}" -ge "1" ]; then
        echo "${Msg}" | tee -a "${LogFile}" 2>&1
    fi
}
