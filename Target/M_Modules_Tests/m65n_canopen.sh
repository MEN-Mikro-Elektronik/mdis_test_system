#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m65n test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m65n_canopen_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M65N Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "    M65N adapter is plugged into M65N m-module"
    echo "DESCRIPTION:"
    echo "    1.Load m-module drivers: modprobe men_ll_canopen"
    echo "    2.Run example/verification program:"
    echo "      canopen_signal m65_${ModuleNo}a and save the command output"
    echo "    3.Verify if canopen_signal command output is valid - does not contain"
    echo "      errors"
    echo "    4.Run example/verification program:"
    echo "      canopen_signal m65_${ModuleNo}b and save the command output"
    echo "    5.Verify if canopen_signal command output is valid - does not contain"
    echo "      errors"
    echo "PURPOSE:"
    echo "    Check if M-module m65n is working correctly with canopen driver"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1706"
    echo "    MEN_13MD0590_SWR_1707"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1910"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# m65n_test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m65n_canopen_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local pattern="\
Set SDO-Timeout value to 0bb8\
Set signal PDO via event\
\
Get SDO-Timeout value = 00000bb8\
Get signal PDO via event = 00000001\
\
Starting CANopen stack ... \
success\
Performing SDO write ...\
Access to Ind. 0x6200, Sub. 001 of local OD\
\
Reading all events of driver's event queue:\
Waiting for driver signal\
\
 Event Tag = 0x5a\
 Event Data[0] = 0x00\
 Event Data[1] = 0x00\
 Event Data[2] = 0x00\
 Event Data[3] = 0x00\
\
Performing SDO read ...\
Reading all events of driver's event queue:\
waiting for signal form driver\
\
 Event Tag = 0x5b\
 Event Data[0] = 0x00\
 Event Data[1] = 0x00\
 Event Data[2] = 0x00\
 Event Data[3] = 0x00\
\
SDO read value form node-Id 000 of Ind 0x1400 Sub 001\
Value = 00000278\
\
Shutdown CAN stack\
\
Program finished"

    debug_print "${LogPrefix} Step1: modprobe men_ll_canopen" "${LogFile}"
    if ! run_as_root modprobe men_ll_canopen
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_canopen" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    debug_print "${LogPrefix} Step2: run canopen_signal m65_${ModuleNo}a" "${LogFile}"
    if ! run_as_root canopen_signal m65_"${ModuleNo}"a  > canopen_signal_a.log
    then
        debug_print "${LogPrefix} Could not run canopen_signal "\
          | tee -a "${LogFile}" 2>&1
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    if ! diff <(echo "${pattern}") <(cat "canopen_signal_a.log") canopen_signal_a.log
    then
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    debug_print "${LogPrefix} Step4: run canopen_signal m65_${ModuleNo}b" "${LogFile}"
    if ! run_as_root canopen_signal m65_"${ModuleNo}"a  > canopen_signal_b.log
    then
        debug_print "${LogPrefix} Could not run canopen_signal "\
          | tee -a "${LogFile}" 2>&1
    fi

    debug_print "${LogPrefix} Step5: check for errors" "${LogFile}"
    if ! diff <(echo "${pattern}") <(cat "canopen_signal_b.log") canopen_signal_b.log
    then
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
