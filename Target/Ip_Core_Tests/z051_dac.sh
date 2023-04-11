#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z055_uart test description
#
# parameters:
# $1    Module number
# $2    Module log path
function z051_dac_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "---------------------------Ip Core z051 DAC----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "    Two HDCL interaces on board are connected with each other"
    echo "DESCRIPTION:"
    echo "    Load ip core driver and run simple test programs"
    echo "    1.Load driver men_ll_z51"
    echo "    2.Run z51_simp program to set outputs of channels 1 and/or 2"
    echo "    4.Check the results - result log shall contain no errors or warnings"
    echo "      Device shall be opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if ip core z051_dac is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1180"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# Function checks if DAC is working correctly - write
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    DeviceName
function z051_dac_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local DeviceName=${3}

    debug_print "${LogPrefix} Set DAC output with Sawtooth wave(s)" "${LogFile}"

    if ! do_modprobe men_ll_z51
    then
        debug_print "${LogPrefix} ERR_MODPROBE :could not modprobe men_ll_z51" "${LogFile}"
        return "${ERR_MODPROBE}"
    fi

    # Test Setting a Sawtooth wave -- check if device was opened, and closed successfully
    local channel=2 # Channels (value 2 selects 0 AND 1)
    local value=-1  # Output value (-1 for sawtooth wave)
    local delay=0   # Output delay
    local step=1    # Sawtooth step width
    local time=1000 # Time to generate wave for (ms)
    if ! run_as_root z51_simp "${DeviceName} ${channel} ${value} ${delay} ${step} ${time}"  >> "z51_simp_${DeviceName}.txt" 2>&1
    then
        debug_print "${LogPrefix} ERR_RUN :could not run z51_simp "${DeviceName} ${channel} ${value} ${delay} ${step} ${time}" "${LogFile}"
        return "${ERR_VALUE}"
    fi
    return "${ERR_OK}"
}
