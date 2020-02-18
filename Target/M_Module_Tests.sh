#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../Common/Conf.sh"

############################################################################
# m33 test description
#
# parameters:
# $1    TestCaseLogName
function m33_description {
    echo "-----------------------M33 Test Case-------------------------------"
    echo "Prerequisites:"
    echo " - It is assumed that at this point all necessary drivers have been"
    echo "   build and are available in the system"
    echo " - M33 adapter is plugged into M33 m-module"
    echo "Steps:"
    echo " 1. Load m-module drivers: modprobe men_ll_m33"
    echo " 2. Run example/verification program:"
    echo "     m33_demo m33_{nr} and save the command output"
    echo " 3. Verify if m33_demo command output is valid - does not contain"
    echo "    errors, and was opened, and closed succesfully"
    echo "Results:"
    echo " - SUCCESS / FAIL"
    echo " - in case of \"FAIL\", please check test case log file:"
    echo "   ${1}"
    echo "   For more detailed information please see corresponding log files"
    echo "   In test case repository"
    echo " - to see definition of all error codes please check Conf.sh"
}

############################################################################
# run m33 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m33_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNr=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_m33" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_m33
    then
        echo "${LogPrefix} ERR_VALUE: could not modprobe men_ll_m33" | tee -a "${TestCaseLogName}"
        return "${ERR_VALUE}"
    fi

    echo "${LogPrefix} Step2: run m33_demo m33_${ModuleNr}" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' m33_demo m33_"${ModuleNr}" > m33_demo.log
    then
        echo "${LogPrefix} Could not run m33_demo " \
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    grep "^Device m33_${ModuleNr}" m33_demo.log > /dev/null && \
    grep "^channel 0: produce ramps" m33_demo.log > /dev/null && \
    grep "^ lowest..highest ramp" m33_demo.log > /dev/null && \
    grep "^ highest..lowest ramp" m33_demo.log > /dev/null && \
    grep "^channel 0: toggle lowest/highest" m33_demo.log > /dev/null && \
    grep "^Device m33_1 closed" m33_demo.log > /dev/null
    if [ $? -ne 0 ]; then
            echo "${LogPrefix} Invalid log output, ERROR" \
              | tee -a "${TestCaseLogName}" 2>&1
            return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
############################################################################
# m47 test description
#
# parameters:
# $1    TestCaseLogName
function m47_description {
    echo "-----------------------M47 Test Case-------------------------------"
    echo "Prerequisites:"
    echo " - It is assumed that at this point all necessary drivers have been"
    echo "   build and are available in the system"
    echo "Steps:"
    echo " 1. Load m-module drivers: modprobe men_ll_m47"
    echo " 2. Run example/verification program:"
    echo "     m47_simp m47_{nr} and save the command output"
    echo " 3. Verify if m47_simp command output is valid - does not contain"
    echo "    errors, and was opened, and closed succesfully"
    echo "Results:"
    echo " - SUCCESS / FAIL"
    echo " - in case of \"FAIL\", please check test case log file:"
    echo "   ${1}"
    echo "   For more detailed information please see corresponding log files"
    echo "   In test case repository"
    echo " - to see definition of all error codes please check Conf.sh"
}

############################################################################
# run m47 test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m47_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNr=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_m47" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_m47
    then
        echo "${LogPrefix} ERR_VALUE: could not modprobe men_ll_m47" | tee -a "${TestCaseLogName}"
        return "${ERR_VALUE}"
    fi

    # Run m47_simp
    echo "${LogPrefix} Step2: run m47_simp m47_${ModuleNr}" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' m47_simp m47_"${ModuleNr}" > m47_simp.log
    then
        echo "${LogPrefix} Could not run m47_simp "\
          | tee -a "${TestCaseLogName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    grep "^ Device name: m47_${ModuleNr}" m47_simp.log > /dev/null && \
    grep "^ Channel: 0" m47_simp.log > /dev/null && \
    grep "^M_open" m47_simp.log > /dev/null && \
    grep "^Read value = 00000000" m47_simp.log > /dev/null && \
    grep "^M_close" m47_simp.log > /dev/null
    if [ $? -ne 0 ]; then
            echo "${LogPrefix} Invalid log output, ERROR"\
              | tee -a "${TestCaseLogName}" 2>&1
            return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}

############################################################################
# m65n test description
#
# parameters:
# $1    TestCaseLogName
function m65n_description {
    echo "-----------------------M65N Test Case-------------------------------"
    echo "Prerequisites:"
    echo " - It is assumed that at this point all necessary drivers have been"
    echo "   build and are available in the system"
    echo " - M65N adapter is plugged into M65N m-module"
    echo "Steps:"
    echo " 1. Load m-module drivers: modprobe men_ll_icanl2"
    echo " 2. Run example/verification program:"
    echo "    icanl2_veri m65_{nr}a m65_{nr}b -n=2 and save the command output"
    echo " 3. Verify if icanl2_veri command output is valid - does not contain"
    echo "    errors (find line 'TEST RESULT: 0 errors)"
    echo "Results:"
    echo " - SUCCESS / FAIL"
    echo " - in case of \"FAIL\", please check test case log file:"
    echo "   ${1}"
    echo "   For more detailed information please see corresponding log files"
    echo "   In test case repository"
    echo " - to see definition of all error codes please check Conf.sh"
}

############################################################################
# m65n_test
#
# parameters:
# $1    TestCaseLogName
# $2    LogPrefix
# $3    M-Module number
function m65n_test {
    local TestCaseLogName=${1}
    local LogPrefix=${2}
    local ModuleNr=${3}

    echo "${LogPrefix} Step1: modprobe men_ll_icanl2" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' modprobe men_ll_icanl2
    then
        echo "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_icanl2" | tee -a "${TestCaseLogName}"
        return "${ERR_VALUE}"
    fi

    # Run icanl2_veri tests twice
    echo "${LogPrefix} Step2: run icanl2_veri m65_${ModuleNr}a m65_${ModuleNr}b -n=2" | tee -a "${TestCaseLogName}" 2>&1
    if ! echo "${MenPcPassword}" | sudo -S --prompt=$'\r' icanl2_veri m65_"${ModuleNr}"a m65_"${ModuleNr}"b -n=2 > icanl2_veri.log
    then
        echo "${LogPrefix} Could not run icanl2_veri "\
          | tee -a "${LogFileName}" 2>&1
    fi

    echo "${LogPrefix} Step3: check for errors" | tee -a "${TestCaseLogName}" 2>&1
    if ! grep "TEST RESULT: 0 errors" icanl2_veri.log > /dev/null
    then
        echo "${LogPrefix} Invalid log output, ERROR"\
          | tee -a "${TestCaseLogName}" 2>&1
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
