#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m72 test description
#
# parameters:
# $1    Module number
# $2    Module log path
function z029_can_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "-------------------------Ip Core z029 CAN Test Case---------------------------"
}

############################################################################
# IP core have to be tested on certain carrier, so user has to specify
# exact location of ip core in the system
#
# parameters:
# $1    Test case log name
# $2    Log prefix
# $3    Board vendor id
# $4    Board device id
# $5    Board subvendor id
# $6    Board number in system
# $7    Optional parameter - test type (optional)
function z029_can_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local VenID=${3}
    local DevID=${4}
    local SubVenID=${5}
    local BoardInSystem=${6}
    local TestType=${7}

    MezzChamDevName="MezzChamDevName.txt"
    obtain_device_list_chameleon_device "${VenID}" "${DevID}" "${SubVenID}" "${MezzChamDevName}" "${BoardInSystem}" "${TestCaseLogName}" "${LogPrefix}"
    can_test_ll_z15 "${TestCaseLogName}" "${LogPrefix}" "${MezzChamDevName}"
    CmdResult=$?
    if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
        echo "${LogPrefix} can_test_ll_z15 err: ${CmdResult} "\
          | tee -a "${TestCaseLogName}" 2>&1
    else
        echo "${LogPrefix} can_test_ll_z15 success "\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

#    local TestType=$(echo ${DeviceName} | head -c1)
#        case "${TestType}" in
#            singleCan)
#                can_test_ll_z15 "${TestCaseLogName}" "${LogPrefix}" "${MezzChamDescriptionFile}"
#                CmdResult=$?
#                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
#                    echo "${LogPrefix} can_test_ll_z15 err: ${CmdResult} "\
#                      | tee -a "${TestCaseLogName}" 2>&1
#                else
#                    echo "${LogPrefix} can_test_ll_z15 success "\
#                      | tee -a "${TestCaseLogName}" 2>&1
#                fi
#                ;;
#            doubleCan)
#                can_test_ll_z15_loopback "${TestCaseLogName}" "${LogPrefix}" "${MezzChamDescriptionFile}"
#                if [ "${CmdResult}" -ne "${ERR_OK}" ]; then
#                    echo "${LogPrefix} can_test_ll_z15_loopback err: ${CmdResult} "\
#                      | tee -a "${TestCaseLogName}" 2>&1
#                else
#                    echo "${LogPrefix} can_test_ll_z15_loopback success "\
#                      | tee -a "${TestCaseLogName}" 2>&1
#                fi
#                ;;
#            *)
#                echo "${LogPrefix} No valid device name"| tee -a "${TestCaseLogName}" 2>&1
#            ;;
#        esac
    return "${CmdResult}"
}

############################################################################
# Test CAN with men_ll_z15 IpCore
#
# parameters:
# $1      name of file with log 
# $2      mezzaine chameleon device description file
function can_test_ll_z15 {
    local LogFileName=${1}
    local LogPrefix=${2}
    local MezzChamDevDescriptionFile=${3}

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_z15
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  ERR_VALUE :could not modprobe men_ll_z15" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi 

    local CanNumber=$(grep "^can" ${MezzChamDevDescriptionFile} | wc -l)
    if [ "${CanNumber}" -ne "2" ]; then
        echo "${LogPrefix}  There are ${CanNumber} CAN interfaces" | tee -a "${LogFileName}"
    else
        local CAN1=$(grep "^can" ${MezzChamDevDescriptionFile} | awk NR==1'{print $1}')
        local CAN2=$(grep "^can" ${MezzChamDevDescriptionFile} | awk NR==2'{print $1}')
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' mscan_pingpong ${CAN1} ${CAN2} >> mscan_pingpong_${CAN1}_${CAN2}.txt 2>&1
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  mscan_pingpong on ${CAN1} ${CAN2} error" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    else
        local CanResult=$(grep "TEST RESULT:" mscan_pingpong_${CAN1}_${CAN2}.txt | awk NR==1'{print $3}')
        if [ "${CanResult}" -ne "${ERR_OK}" ]; then
            return "${ERR_RUN}"
        fi
        return "${ERR_OK}"
    fi
}

############################################################################
# Test CAN with men_ll_z15 IpCore (loopback)
#
# parameters:
# $1      name of file with log 
# $2      mezzaine chameleon device description file
function can_test_ll_z15_loopback {
    local LogFileName=${1}
    local LogPrefix=${2}
    local MezzChamDevDescriptionFile=${3}

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_z15
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  ERR_VALUE :could not modprobe men_ll_z15" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    local CanNumber=$(grep "^can" ${MezzChamDevDescriptionFile} | wc -l)
    if [ "${CanNumber}" -ne "1" ]; then
        echo "${LogPrefix}  There are ${CanNumber} CAN interfaces"  | tee -a "${LogFileName}"
    else
        local CAN1=$(grep "^can" ${MezzChamDevDescriptionFile} | awk NR==1'{print $1}')
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' mscan_loopb "${CAN1}" >> mscan_loopb_${CAN1}.txt 2>&1
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  mscan_loopb on ${CAN1} error" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    else
        local CanResult=$(grep "TEST RESULT:" mscan_loopb_${CAN1}.txt | awk NR==1'{print $3}')
        if [ "${CanResult}" -ne "${ERR_OK}" ]; then
            return "${ERR_RUN}"
        fi
        return "${ERR_OK}"
    fi
}

############################################################################
# Test CAN with men_ll_z15 IpCore (loopback) version 2
#
# parameters:
# $1      name of file with log 
# $2      CAN device name
function can_test_ll_z15_loopback2 {
    local LogFileName=$1
    local CANDevice=$2
    local LogPrefix="[Can_test]"

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_z15
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  ERR_VALUE :could not modprobe men_ll_z15" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    fi

    echo "${MenPcPassword}" | sudo -S --prompt=$'\r' mscan_loopb ${CANDevice} >> mscan_loopb_"${CANDevice}".txt 2>&1
    if [ $? -ne 0 ]; then
        echo "${LogPrefix}  mscan_loopb on ${CANDevice} error" | tee -a "${LogFileName}"
        return "${ERR_VALUE}"
    else
        local CanResult=$(grep "TEST RESULT:" mscan_loopb_${CANDevice}.txt | awk NR==1'{print $3}')
        if [ "${CanResult}" -ne "${ERR_OK}" ]; then
            return "${ERR_RUN}"
        fi
        return "${ERR_OK}"
    fi
}
