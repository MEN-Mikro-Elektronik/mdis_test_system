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
function z050_bioc_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "---------------------------Ip Core z050 BIOC ----------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "    BIOC output channels need to be connected to the input channels for getting feedback"
    echo "DESCRIPTION:"
    echo "    Load ip core driver and run simple test programs"
    echo "    1.Load driver men_ll_z50"
    echo "    2.Run z50_simp program to set outputs of channels"
    echo "    3.Check the results - Input channels need to match outputs set"
    echo "      Device shall be opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if ip core z050_bioc is working correctly"
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

function z050_io_bioc_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}

    z050_bioc_description ${ModuleNo} ${ModuleLogPath}
}

############################################################################
# Function checks if BIO Ip core is working correctly
#
function z050_bioc_run_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}

    MezzChamDevName="MezzChamDevName.txt"
    obtain_device_list_chameleon_device "${VenID}" "${DevID}" "${SubVenID}" "${MezzChamDevName}" "${BoardInSystem}" "${LogFile}" "${LogPrefix}"

    # TODO: Hardcoded bioc number for F401 multifunction board
    DeviceName=$(grep "^bioc_2" "${MezzChamDevName}" | awk '{print $1}')

    debug_print "${LogPrefix} Step2: run z50_simp ${DeviceName}" "${LogFile}"
    if ! run_as_root z50_simp "${DeviceName}"  >> "z50_simp_${DeviceName}.txt" 2>&1
    then
        debug_print "${LogPrefix} ERR_RUN :could not run z50_simp ${DeviceName}" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    debug_print "${LogPrefix} Step3: Check Results" "${LogFile}"
    cat z50_simp_${DeviceName}.txt | grep 'Out:' > "z50_simp_${DeviceName}_outLines.txt"
    while read -r line; do
        inVal=$(echo "${line}" | awk -F': ' '{print substr($3,0,9)}')
        outVal=$(echo "${line}" | awk -F': ' '{print substr($4,0,9)}')
        if [ "${inVal}" != "${outVal}" ]; then
            debug_print "${LogPrefix} ERR_VALUE: Input $inVal does not match output set $outVal"
            return "${ERR_VALUE}"
        fi
    done < "z50_simp_${DeviceName}_outLines.txt"

    return "${ERR_OK}"
}

############################################################################
# Entry point for testing IP Core Z050 BIOC in MEMORY-MAPPED FPGA
#
function z050_bioc_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}

    debug_print "${LogPrefix} Step1: modprobe men_ll_z50" "${LogFile}"
    if ! do_modprobe men_ll_z50
    then
        debug_print "${LogPrefix} ERR_MODPROBE :could not modprobe men_ll_z50" "${LogFile}"
        return "${ERR_MODPROBE}"
    fi

    z050_bioc_run_test ${LogFile} ${LogPrefix} ${VenID} ${DevId} ${SubVenID} ${BoardInSystem} ${TestType}

    return "$?"
}

############################################################################
# Entry point for testing IP Core Z050 BIOC in IO-MAPPED FPGA
#
function z050_io_bioc_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}

    debug_print "${LogPrefix} Step1: modprobe men_ll_z50_io" "${LogFile}"
    if ! do_modprobe men_ll_z50_io
    then
        debug_print "${LogPrefix} ERR_MODPROBE :could not modprobe men_ll_z50_io" "${LogFile}"
        return "${ERR_MODPROBE}"
    fi

    z050_bioc_run_test "${LogFile}" "${LogPrefix}" "${VenID}" "${DevID}" "${SubVenID}" "${BoardInSystem}" "${TestType}"

    return "$?"
}
