#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"
source "${MyDir}/M_Modules_Tests/m47.sh"

############################################################################
# m47 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m47_pci_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    echo "--------------------------------M47 PCI Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system."
    echo "    Use the PCI_BUS_PATH makes the test dependent on the CompactPCI slot in the backplane"
    echo "    where the carrier board should be placed, so please, remember to connect the F205"
    echo "    in the same slot specified on 13MD05-90_02_03-System-TestReport-1.pdf"
    echo "DESCRIPTION:"
    echo "    Load module driver and run M-Module example programs"
    echo "    1.Load m-module drivers: modprobe men_ll_m47"
    echo "    2.Run example/verification program:"
    echo "      m47_simp m47_${ModuleNo} and save the command output"
    echo "    3.Verify if m47_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m47 is working correctly accessing via PCI_BUS_PATH instead of PCI BUS/PCI DEVICE NUMBER"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1560"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1870"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${ModuleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m47 test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m47_pci_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local TestResult=0

    # This carrier board is indentified as d203_1 so we copy
    # the previous file.
    debug_print "${LogPrefix} Backup previous d203_1.bin file" "${LogFile}"
    run_as_root cp ${MdisDescDir}/d203_1.bin ${MdisDescDir}/d203_1.bin.original

    # Copy the new DESC binary file of carrier board where
    # this M-Module is connected to.
    debug_print "${LogPrefix} Replace the d203_1.bin file with the new one" "${LogFile}"
    run_as_root cp ${MyDir}/Config/St_Test_Setup_1/d203_1.bin ${MdisDescDir}/d203_1.bin

    # Run the parent test
    debug_print "${LogPrefix} Run parent m47 test..." "${LogFile}"
    m47_test ${LogFile} ${LogPrefix} ${ModuleNo}
    TestResult=$?

    debug_print "${LogPrefix} Test result: ${TestResult}" "${LogFile}"

    # After that, restore the file with the previous DESC binary
    # file.
    debug_print "${LogPrefix} Restore old d203_1.bin file" "${LogFile}"
    run_as_root cp ${MdisDescDir}/d203_1.bin.original ${MdisDescDir}/d203_1.bin

    # Delete original file.
    run_as_root rm -rf ${MdisDescDir}/d203_1.bin.original

    if [ ${TestResult} -ne 0 ]; then
        return "${ERR_VALUE}"
    fi

    return "${ERR_OK}"
}
