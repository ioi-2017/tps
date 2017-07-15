#!/bin/bash

set -euo pipefail

source "${internals}/util.sh"

test_name="$1"; shift

input="${tests_dir}/${test_name}.in"
answer="${tests_dir}/${test_name}.out"
sol_output="${sandbox}/${test_name}.out"

function run_solution {
    tlog_file="$(job_tlog_file "${sol_job}")"
    python "${internals}/timer.py" "${soft_tl}" "${hard_tl}" "${tlog_file}" bash "${scripts}/run.sh" < "${input}" > "${sol_output}"
}

function run_checker {
    "${checker_dir}/checker.exe" "${input}" "${answer}" "${sol_output}"
}


printf "%-${status_pad}s" "${test_name}"

failed_jobs=""
final_ret=0


if [ -f "${input}" ]; then
    input_status="OK"
else
    input_status="FAIL"
    final_ret=4

    score="0"
    verdict="Judge Failure"
    reason="input file ${test_name}.in is not available"
fi


export box_padding=4

echo -n "sol"
sol_job="${test_name}.sol"
execution_time=""

if ! is_in "${input_status}" "FAIL" "SKIP"; then
    insensitive guard "${sol_job}" run_solution
    ret=$(job_ret "${sol_job}")
    execution_time="$(job_tlog "${sol_job}" "duration")"

    if [ ${ret} -eq 124 ]; then
        score="0"
        verdict="Time Limit Exceeded"
        terminated="$(job_tlog "${sol_job}" "terminated")"
        if "${terminated}"; then
            reason="solution terminated after hard time limit '${hard_tl}'"
        else
            solution_exit_code="$(job_tlog "${sol_job}" "ret")"
            reason="solution finished after time limit '${soft_tl}', with exit code '${solution_exit_code}'"
        fi
    elif [ ${ret} -ne 0 ]; then
        failed_jobs="${failed_jobs} ${sol_job}"

        score="0"
        verdict="Runtime Error"
        reason="solution finished with exit code ${ret}"
    fi
fi

sol_status="$(job_status ${sol_job})"
echo_status "${sol_status}"
printf "%7s" "${execution_time}"
hspace 5


export box_padding=5

echo -n "check"
check_job="${test_name}.check"

if ! is_in "${sol_status}" "FAIL" "SKIP"; then
    if "${skip_check}"; then
        score="?"
        verdict="Unknown"
        reason="Checker skipped"
    else
        insensitive guard "${check_job}" run_checker
        ret=$(job_ret "${check_job}")

        if [ "${ret}" -ne 0 ]; then
            final_ret=${ret}
            failed_jobs="${failed_jobs} ${check_job}"

            score="0"
            verdict="Judge Failure"
            reason="checker exited with code ${ret}"
        else
            score="$(sed -n 1p "${logs_dir}/${check_job}.out")"
            verdict="$(sed -n 1p "${logs_dir}/${check_job}.err")"
            reason="$(sed -n 2p "${logs_dir}/${check_job}.err")"
        fi
    fi
fi

check_status=$(job_status "${check_job}")
echo_status "${check_status}"


printf "%5s" "${score}"
hspace 2
export box_padding=20
echo_verdict "${verdict}"

if "${show_reason}"; then
    hspace 2
    printf "%s" "${reason}"
fi

echo


if "${sensitive_run}"; then
    if [ ${final_ret} -ne 0 ]; then
        for job in ${failed_jobs}; do
            echo
            echo "failed job: ${job}"
            execution_report "${job}"
        done

        exit ${final_ret}
    fi
fi