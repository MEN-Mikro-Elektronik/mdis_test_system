#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# b_smb2_pci_description
#
# parameters:
# $1    Module number
# $2    Module log path 
function b_smb2_pci_description {
    local ModuleNo=${1}
    local ModuleLogPath=${2}
    local TestSummaryDirectory="${3}"
    local LongDescription="${4}"
    echo "---------------------SMB2 pci card Test Case-----------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo ""
    echo "PURPOSE:"
    echo ""
    echo "REQUIREMENT_ID:"
    echo "RESULTS"
    echo "    SUCCESS if test is passed without error(s) warning(s)"
    echo "    FAIL otherwise"
    echo ""
}

############################################################################
# run board smb2 pci card test
#
# parameters:
# $1    Log file
# $2    Log prefix
# $3    M-Module number
function b_smb2_pci_test {
    local TestCaseId="${1}"
    local TestSummaryDirectory="${2}"
    local OsNameKernel="${3}"
    local LogFile=${4}
    local LogPrefix=${5}
    local BoardInSystem=${6}

}
