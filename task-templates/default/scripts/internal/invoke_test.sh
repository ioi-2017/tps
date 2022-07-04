#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"
source "${INTERNALS}/invoke_util.sh"

tests_dir="$1"; shift
test_name="$1"; shift

input_file_path="${tests_dir}/${test_name}.in"
judge_answer="${tests_dir}/${test_name}.out"
sol_stdout="${SANDBOX}/${test_name}.out"
sol_stderr="${SANDBOX}/${test_name}.err"


initialize_failed_job_list


printf "%-${STATUS_PAD}s" "${test_name}"

export BOX_PADDING=4

unset execution_time score verdict reason

echo -n "sol"
sol_job="${test_name}.sol"
invoke_solution "${sol_job}" "${test_name}" "${input_file_path}" "${sol_stdout}" "${sol_stderr}"
if variable_exists "verdict" && is_verdict_judge_failure "${verdict}"; then
	verify_job_failure "${sol_job}"
fi
sol_status="$(job_status "${sol_job}")"
echo_status "${sol_status}"
printf "%7s" "${execution_time}"
hspace 5


export BOX_PADDING=5

echo -n "check"
check_job="${test_name}.check"
if ! is_in "${sol_status}" "FAIL" "SKIP"; then
	run_checker_if_needed "${check_job}" "${test_name}" "${input_file_path}" "${judge_answer}" "${sol_stdout}" "${sol_stderr}"
fi
verify_job_failure "${check_job}"
check_status="$(job_status "${check_job}")"
echo_status "${check_status}"

print_score "${score}" "6"
hspace 2

export BOX_PADDING=20
echo_verdict "${verdict}"

if "${SHOW_REASON}"; then
	hspace 2
	printf "%s" "${reason}"
fi

echo "${score}" > "${LOGS_DIR}/${test_name}.score"
echo "${verdict}" > "${LOGS_DIR}/${test_name}.verdict"
echo "${reason}" > "${LOGS_DIR}/${test_name}.reason"

echo

if should_stop_for_failed_jobs; then
	stop_for_failed_jobs
fi
