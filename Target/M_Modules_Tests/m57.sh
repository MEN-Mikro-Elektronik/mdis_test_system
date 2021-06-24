#! /bin/bash
MyDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${MyDir}/../../Common/Conf.sh"
source "${MyDir}/../St_Functions.sh"

############################################################################
# m57 test description
#
# parameters:
# $1    Module number
# $2    Module log path 
function m57_description {
    local moduleNo=${1}
    local moduleLogPath=${2}
    echo "--------------------------------M57 Test Case---------------------------------"
    echo "PREREQUISITES:"
    echo "    It is assumed that at this point all necessary drivers have been build and"
    echo "    are available in the system"
    echo "DESCRIPTION:"
    echo "    Load module driver and run M-Module example programs"
    echo "    1.Load m-module drivers: modprobe men_ll_profidp"
    echo "    2.Run example/verification program:"
    echo "      profidp_simp m57_${moduleNo} and save the command output"
    echo "    3.Verify if profidp_simp command output is valid - does not contain errors"
    echo "      Device was opened and closed succesfully"
    echo "PURPOSE:"
    echo "    Check if M-module m57 is working correctly"
    echo "UPPER_REQUIREMENT_ID:"
    echo "    MEN_13MD0590_SWR_1630"
    #echo "REQUIREMENT_ID:"
    #echo "    MEN_13MD05-90_SA_1880"
    echo "RESULTS"
    echo "    SUCCESS / FAIL"
    echo "    If \"FAIL\", please check test case log file:"
    echo "    ${moduleLogPath}"
    echo "    For more detailed information please see corresponding log files in test"
    echo "    case repository"
    echo "    To see error codes definition please check Conf.sh"
}

############################################################################
# run m57 test
#
# parameters:
# $1    LogFile
# $2    LogPrefix
# $3    M-Module number
function m57_test {
    local LogFile=${1}
    local LogPrefix=${2}
    local ModuleNo=${3}
    local profidp_simp_PID

    debug_print "${LogPrefix} Step1: modprobe men_ll_profidp" "${LogFile}"
    if ! run_as_root modprobe men_ll_profidp
    then
        debug_print "${LogPrefix}  ERR_VALUE: could not modprobe men_ll_profidp" "${LogFile}" 
        return "${ERR_VALUE}"
    fi

    cat >m57_test.sh <<EOF
#!/usr/bin/env bash
stdbuf -o0 profidp_simp m57_${ModuleNo} > profidp_simp.log &
Result="${ERR_SIMP_ERROR}"
#Wait until PID is created
idx=1
while [ \$idx -le 5 ]
do
    sleep 1
    profidp_simp_PID=\$(pgrep profidp_simp)
    if [ -z "\$profidp_simp_PID" ]
    then
        idx=\$(( \$idx + 1 ))
    else
        Result="${ERR_OK}"
        break
    fi
done
#Wait until log FILE is created
idx=1
while [[ ! -f profidp_simp.log && \$idx -le 5 ]]
do
    sleep 1
    idx=\$(( \$idx + 1 ))
done
#Test has finished if the number of lines does not change in 2 cycles otherwise by Timeout
idx=1
n_lines_bk=0
n_match=0
while [ \$idx -le 10 ]
do
    sleep 2
    n_lines=\$(cat profidp_simp.log | wc -l)
    if [ \$n_lines_bk != \$n_lines ]
    then
        n_lines_bk=\$n_lines
        n_match=0
    else
        if [ \$n_lines -gt 12 ]
        then
            n_match=\$(( \$n_match + 1 ))
        fi
        if [ \$n_match -ge 2 ]
        then
            break
        fi
    fi
    idx=\$(( \$idx + 1 ))
done
#The test is killed if it is still running 
profidp_simp_PID=\$(pgrep profidp_simp)
if [ -n "\$profidp_simp_PID" ]
then
    kill -9 \${profidp_simp_PID} > /dev/null 2>&1
    if [ \$n_match -ge 2 ]
    then
        Result="${ERR_OK}"
    fi
fi
return \$Result
EOF
    chmod +x m57_test.sh
    
    m57_test_errors=0
    # Run profidp_simp
    debug_print "${LogPrefix} Step2: run profidp_simp m57_${ModuleNo}" "${LogFile}"
    if ! run_as_root ./m57_test.sh
    then
        debug_print "${LogPrefix} Could not run profidp_simp " "${LogFile}"
    else
        if [ $? -eq "${ERR_SIMP_ERROR}" ]
        then
            m57_test_errors=1
        fi
    fi

    debug_print "${LogPrefix} Step3: check for errors" "${LogFile}"
    grep "^M_open" profidp_simp.log > /dev/null && \
    grep "^Start Profibus protocol stack" profidp_simp.log > /dev/null && \
    grep "^Get FMB_FM2_EVENT reason" profidp_simp.log > /dev/null && \
    grep "^FMB_FM2_EVENT reason" profidp_simp.log > /dev/null && \
    grep "^Get Slave Diag" profidp_simp.log > /dev/null && \
    grep "station_status_1 = 01" profidp_simp.log > /dev/null && \
    grep "station_status_2 = 00" profidp_simp.log > /dev/null && \
    grep "station_status_3 = 00" profidp_simp.log > /dev/null && \
    grep "master_add = ff" profidp_simp.log > /dev/null && \
    grep "ident_number = 0000" profidp_simp.log > /dev/null && \
    grep "Stop Profibus protocol stack" profidp_simp.log > /dev/null && \
    grep "^M_close" profidp_simp.log > /dev/null
    if [ $? -ne 0 ]; then
        debug_print "${LogPrefix} Invalid log output, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    grep -i "Error" profidp_simp.log > /dev/null
    if [ $? -eq 0 ]; then
        debug_print "${LogPrefix} Error in profidp_simp.log, ERROR" "${LogFile}"
        return "${ERR_VALUE}"
    fi

    if [ $m57_test_errors -eq 1 ]; then
        debug_print "${LogPrefix} Any Error in m57_test.sh, ERROR" "${LogFile}"
    fi

    return "${ERR_OK}"
}
