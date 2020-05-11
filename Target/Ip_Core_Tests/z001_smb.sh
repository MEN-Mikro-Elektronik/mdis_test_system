#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# z001 smb test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function z001_smb_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "-------------------Ip Core z001 Test Case----------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that all necessary drivers have been build and are"
    echo "    available in the system"
    echo "DESCRIPTION:"
    echo "    1.List available SMB devices: i2cdetect -y -l"
    echo "    2.Load m-module drivers: modprobe men_lx_z001"
    echo "    3.List available SMB devices and note one with name begining with 16Z001"
    echo "    4.Read data from SMB device EEPROM"
    echo "    5.Write data to SMB device EEPROM"
    echo "    6.Read data from SMB device EEPROM again"
    echo "    7.Check if data read from EEPROM is equal to data written"
    echo "PURPOSE:"
    echo "    Check if ip core z001 with men_lx_z001 driver is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1070"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1400"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run z001_smb_test
# 
# parameters:
# $1    Log file
# $2    Log prefix
# $3    Board vendor id
# $4    Board device id
# $5    Board subvendor id
# $6    Board number in system
# $7    Optional parameter - test type (optional)
function z001_smb_test {
    local LogFile=${1}
    local LogPrefix=${2}
#    local VenID=${3}
#    local DevID=${4}
#    local SubVenID=${5}
#    local BoardInSystem=${6}
#    local TestType=${7}
    debug_print "${LogPrefix} z001_smb fixed on G25A with G229 board" "${LogFile}"
    smb_test_lx_z001 "${LogFile}" "${LogPrefix}" "DBZIB" "0x51"
    return $?
}

############################################################################
# Test Z001_SMB IP core with men_lx_z001
#
# parameters:
# $1      Log file
# $2      Log prefix
# $2      Board name (e.g. P511)
# $3      Read address (e.g. 0x57)
function smb_test_lx_z001 {
    local LogFile=${1}
    local LogPrefix=${2}
    local BoardName="${3}"
    local ReadAddress="${4}"
    local SMBUS_ID
    local Patt1Def
    local Patt2Def
    local Patt1Write="0x4aff"
    local Patt2Write="0x4550"
    local Patt1Read
    local Patt2Read

    run_as_root i2cdetect -y -l > "i2c_bus_list_before.log" 2>&1

    if ! run_as_root modprobe men_lx_z001
    then
        debug_print "${LogPrefix} ERR_MODPROBE: could not modprobe men_lx_z001" "${LogFile}"
        return "${ERR_MODPROBE}"
    fi

    run_as_root i2cdetect -y -l > "i2c_bus_list_after.log" 2>&1

    run_as_root cat "i2c_bus_list_before.log" "i2c_bus_list_after.log" | sort | uniq --unique > "i2c_bus_list_test.log" 2>&1
    SMBUS_ID="$(run_as_root grep --only-matching "16Z001-[0-1]\+ BAR[0-9]\+ offs 0x[0-9]\+" "i2c_bus_list_test.log")"
    run_as_root i2cdump -y "${SMBUS_ID}" "${ReadAddress}" > "i2c_bus_dump_before.log"

    
    if ! < "i2c_bus_dump_before.log" grep "${BoardName}" > /dev/null
    then
        debug_print "${LogPrefix} ERR_VALUE: i2cdump failed for ${SMBUS_ID}" "${LogFile}"
        if ! run_as_root rmmod men_lx_z001
        then
            debug_print "${LogPrefix} ERR_RMMOD: could not rmmod men_lx_z001" "${LogFile}"
        fi

        return "${ERR_VALUE}"
    fi

    Patt1Def="$(run_as_root i2cget -y "${SMBUS_ID}" "${ReadAddress}" 0xfc w)"
    Patt2Def="$(run_as_root i2cget -y "${SMBUS_ID}" "${ReadAddress}" 0xfe w)"
    run_as_root i2cset -y "${SMBUS_ID}" "${ReadAddress}" 0xfc "${Patt1Write}" w
    run_as_root i2cset -y "${SMBUS_ID}" "${ReadAddress}" 0xfe "${Patt2Write}" w
    Patt1Read="$(run_as_root i2cget -y "${SMBUS_ID}" "${ReadAddress}" 0xfc w)"
    Patt2Read="$(run_as_root i2cget -y "${SMBUS_ID}" "${ReadAddress}" 0xfe w)"
    run_as_root i2cdump -y "${SMBUS_ID}" "${ReadAddress}" > "i2c_bus_dump_after.log"
    run_as_root i2cset -y "${SMBUS_ID}" "${ReadAddress}" 0xfc "${Patt1Def}" w
    run_as_root i2cset -y "${SMBUS_ID}" "${ReadAddress}" 0xfe "${Patt2Def}" w
    if [[ "${Patt1Read}" != "${Patt1Write}" || \
          "${Patt2Read}" != "${Patt2Write}" ]]; then
        debug_print "${LogPrefix} ERR_VALUE: read pattern does not match pattern written for ${SMBUS_ID}" "${LogFile}"

        if ! run_as_root rmmod men_lx_z001
        then
            debug_print "${LogPrefix} ERR_RMMOD: could not rmmod men_lx_z001" "${LogFile}"
        fi
        return "${ERR_VALUE}"
    fi

    if ! run_as_root rmmod men_lx_z001
    then
        debug_print "${LogPrefix} ERR_RMMOD: could not rmmod men_lx_z001" "${LogFile}"
    fi

    return "${ERR_OK}"
}
