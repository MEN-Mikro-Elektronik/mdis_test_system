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
}


function z001_smb_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}
    echo "${LogPrefix} z001_smb fixed on G25A with G229 board"
    smb_test_lx_z001 "${TestCaseLogName}" "${LogPrefix}" "DBZIB" "0x51"
    return $?
}
############################################################################
# Test Z001_SMB IP core with men_lx_z001
#
# parameters:
# $1      name of file with log
# $2      board name (e.g. P511)
# $3      read address (e.g. 0x57)
#
function smb_test_lx_z001 {
    local TestCaseLogName=${1}
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

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' i2cdetect -y -l > "i2c_bus_list_before.log" 2>&1

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_lx_z001
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} ERR_MODPROBE: could not modprobe men_lx_z001" | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_MODPROBE}"
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' i2cdetect -y -l > "i2c_bus_list_after.log" 2>&1

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' cat "i2c_bus_list_before.log" "i2c_bus_list_after.log" | sort | uniq --unique > "i2c_bus_list_test.log" 2>&1
    SMBUS_ID="$(echo ${MenPcPassword} | sudo -S --prompt=$'\r' grep --only-matching "16Z001-[0-1]\+ BAR[0-9]\+ offs 0x[0-9]\+" "i2c_bus_list_test.log")"
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' i2cdump -y "${SMBUS_ID}" "${ReadAddress}" > "i2c_bus_dump_before.log"

    cat "i2c_bus_dump_before.log" | grep "${BoardName}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} ERR_VALUE: i2cdump failed for ${SMBUS_ID}" | tee -a "${TestCaseLogName}" 2>&1

        echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rmmod men_lx_z001
        if [ $? -ne 0 ]; then
            echo "${LogPrefix} ERR_RMMOD: could not rmmod men_lx_z001" | tee -a "${TestCaseLogName}" 2>&1
        fi

        return ${ERR_VALUE}
    fi

    Patt1Def="$(echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cget -y "${SMBUS_ID}" "${ReadAddress}" 0xfc w)"
    Patt2Def="$(echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cget -y "${SMBUS_ID}" "${ReadAddress}" 0xfe w)"
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' i2cset -y "${SMBUS_ID}" "${ReadAddress}" 0xfc "${Patt1Write}" w
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' i2cset -y "${SMBUS_ID}" "${ReadAddress}" 0xfe "${Patt2Write}" w
    Patt1Read="$(echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cget -y "${SMBUS_ID}" "${ReadAddress}" 0xfc w)"
    Patt2Read="$(echo ${MenPcPassword} | sudo -S --prompt=$'\r' i2cget -y "${SMBUS_ID}" "${ReadAddress}" 0xfe w)"
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' i2cdump -y "${SMBUS_ID}" "${ReadAddress}" > "i2c_bus_dump_after.log"
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' i2cset -y "${SMBUS_ID}" "${ReadAddress}" 0xfc "${Patt1Def}" w
    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' i2cset -y "${SMBUS_ID}" "${ReadAddress}" 0xfe "${Patt2Def}" w
    if [[ "${Patt1Read}" != "${Patt1Write}" || \
          "${Patt2Read}" != "${Patt2Write}" ]]; then
        echo "${LogPrefix} ERR_VALUE: read pattern does not match pattern written for ${SMBUS_ID}" | tee -a "${TestCaseLogName}" 2>&1

        echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rmmod men_lx_z001
        if [ $? -ne 0 ]; then
            echo "${LogPrefix} ERR_RMMOD: could not rmmod men_lx_z001" | tee -a "${TestCaseLogName}" 2>&1
        fi

        return "${ERR_VALUE}"
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' rmmod men_lx_z001
    if [ $? -ne 0 ]; then
        echo "${LogPrefix} ERR_RMMOD: could not rmmod men_lx_z001" | tee -a "${TestCaseLogName}" 2>&1
    fi

    return "${ERR_OK}"
}
