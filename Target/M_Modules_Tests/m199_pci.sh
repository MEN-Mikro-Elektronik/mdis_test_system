#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/M_Modules_Tests/m199.sh"

############################################################################
# m199 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m199_pci_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------M199 PCI Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Load module driver and run M-Module example programs"
    echo "    1.Load m-module drivers: modprobe men_ll_m199"
    echo "    2.Run example/verification program:"
    echo "      m199_simp m199_${moduleNo} and save the command output"
    echo "    3.Verify if m199_simp command output is valid - does not contain errors"
    echo "PURPOSE:"
    echo "    Check if M-module m199 is working correctly accessing via PCI_BUS_PATH instead of PCI BUS/PCI DEVICE NUMBER"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1870"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1960"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m199 test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m199_pci_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestResult=0

    # This carrier board is indentified as d203_1 so we copy
    # the previous file.
    update_desc_file "d203_1.bin" "${MyDir}/Config/St_Test_Setup_5/d203_1.bin" $LogFile $LogPrefix

    # Run the parent test
    debug_print "${LogPrefix} Run parent m199 test..." "${LogFile}"
    m199_test ${LogFile} ${LogPrefix} ${ModuleNo}
    TestResult=$?

    debug_print "${LogPrefix} Test result: ${TestResult}" "${LogFile}"

    # After that, restore the file with the previous DESC binary
    # file.
    restore_desc_file "d203_1.bin" $LogFile $LogPrefix

    if [ ${TestResult} -ne 0 ]; then
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
