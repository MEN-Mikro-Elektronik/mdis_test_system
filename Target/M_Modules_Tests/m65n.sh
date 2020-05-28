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
function m65n_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M65N Test Case--------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "    M65N adapter is plugged into M65N m-module"
    echo "DESCRIPTION:"
    echo "    Load module driver and run M-Module example programs"
    echo "    1.Load m-module drivers: modprobe men_ll_icanl2"
    echo "    2.Run example/verification program:"
    echo "      icanl2_veri m65_${ModuleNo}a m65_${ModuleNo}b -n=2 and save the command"
    echo "      output"
    echo "    3.Verify if icanl2_veri command output is valid - does not contain"
    echo "      errors (find line 'TEST RESULT: 0 errors)"
    echo "PURPOSE:"
    echo "    Check if M-module m65n is working correctly"
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
# fix for m65n M-Module if there is canopen driver in system
#
# parameters:
# $1    Log file
# $2    Log prefix
function m65n_canopen_fix {
    local LogFile=${1}
    local LogPrefix=${2}
    local CurrentPath=$PWD

    debug_print "${LogPrefix} m65n_canopen_fix" "${LogFile}"

    debug_print "${LogPrefix} Current Path:" "${LogFile}"
    debug_print "${CurrentPath}" "${LogFile}"

    cd ../..
    sed -i 's/HW_TYPE = STRING CANOPEN/HW_TYPE = STRING ICANL2/' system.dsc
    sed -i 's/_WIZ_MODEL = STRING M65_COP/_WIZ_MODEL = STRING M65_L2/' system.dsc
    sed -i 's/CANOPEN\/DRIVER\/COM\/driver.mak/ICANL2\/DRIVER\/COM\/driver.mak/' Makefile
    sed -i 's/CANOPEN\/EXAMPLE\/CANOPEN_SIMP\/COM\/program.mak/ICANL2\/EXAMPLE\/ICANL2_SIMP\/COM\/program.mak/' Makefile
    sed -i 's/CANOPEN\/EXAMPLE\/CANOPEN_SIGNAL\/COM\/program.mak/ICANL2\/EXAMPLE\/ICANL2_CYC\/COM\/program.mak/' Makefile
    sed -i 's/CANOPEN\/EXAMPLE\/CANOPEN_PDO\/COM\/program.mak/ICANL2\/EXAMPLE\/ICANL2_SIGNAL\/COM\/program.mak/' Makefile
    sed -i 's/CANOPEN\/TOOLS\/CANOPEN_BUS_SCAN\/COM\/program.mak/ICANL2\/TEST\/ICANL2_VERI\/COM\/program.mak/' Makefile
    sed -i '/CANOPEN\/TEST\/CANOPEN_DESIGN_TEST\/COM\/program.mak/ d' Makefile
    sed -i '/CANOPEN\/TEST\/CANOPEN_DIOC711_KLIMA\/COM\/program.mak/ d' Makefile
    sed -i '/CANOPEN\/TEST\/CANOPEN_DIOC711_TEST\/COM\/program.mak/ d' Makefile
    sed -i '/CANOPEN\/TEST\/CANOPEN_MAX_TEST\/COM\/program.mak/ d' Makefile
    sed -i '/CANOPEN\/TEST\/CANOPEN_SER_TEST\/COM\/program.mak/ d' Makefile
    sed -i '/SMB2_SHC\/COM\/library.mak/ a ICANL2_API\/COM\/library.mak \\' Makefile
    make_install "${LogPrefix}"
    cd "${CurrentPath}" || exit "${ERR_NOEXIST}"
}

############################################################################
# m65n_test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m65n_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}

    m65n_canopen_fix "${1}" "${2}"

    debug_print "${LogPrefix} Step1: modprobe men_ll_icanl2" "${LogFile}"
    if ! run_as_root modprobe men_ll_icanl2
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_icanl2" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    # Run icanl2_veri tests twice
    debug_print "${LogPrefix} Step2: run icanl2_veri m65_${ModuleNo}a m65_${ModuleNo}b -n=2" "${LogFile}"
    if ! run_as_root icanl2_veri m65_"${ModuleNo}"a m65_"${ModuleNo}"b -n=2 > icanl2_veri.log
    then
        debug_print "${LogPrefix} Could not run icanl2_veri "\
          | tee -a "${LogFile}" 2>&1
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    if ! grep "TEST RESULT: 0 errors" icanl2_veri.log > /dev/null
    then
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
