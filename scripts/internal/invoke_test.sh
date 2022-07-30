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


final_ret=0
failed_jobs=""


printf "%-${STATUS_PAD}s" "${test_name}"

export BOX_PADDING=4

unset execution_time score verdict reason

echo -n "sol"
sol_job="${test_name}.sol"

function invoke_solution {
	if [ ! -f "${input_file_path}" ]; then
		final_ret=4
		failed_jobs="${failed_jobs} ${sol_job}"

		execution_time=""
		score="0"
		verdict="Judge Failure"
		reason="input file ${test_name}.in is not available"
		return
	fi

	function run_solution {
		local tlog_file
		tlog_file="$(job_tlog_file "${sol_job}")"
		readonly tlog_file
		"${PYTHON}" "${INTERNALS}/timer.py" "${SOFT_TL}" "${HARD_TL}" "${tlog_file}" bash "${TEMPLATES}/run_test.sh" "${test_name}" "${input_file_path}" "${sol_stdout}" "${sol_stderr}"
	}
	insensitive guard "${sol_job}" run_solution
	local ret
	ret="$(job_ret "${sol_job}")"
	readonly ret
	execution_time="$(job_tlog "${sol_job}" "duration")"

	if [ "${ret}" -eq 124 ]; then
		score="0"
		verdict="Time Limit Exceeded"
		local terminated
		terminated="$(job_tlog "${sol_job}" "terminated")"
		readonly terminated
		if "${terminated}"; then
			reason="solution terminated after hard time limit '${HARD_TL}'"
		else
			local solution_exit_code
			solution_exit_code="$(job_tlog "${sol_job}" "ret")"
			readonly solution_exit_code
			reason="solution finished after time limit '${SOFT_TL}', with exit code '${solution_exit_code}'"
		fi
	elif [ "${ret}" -ne "0" ]; then
		score="0"
		verdict="Runtime Error"
		reason="solution finished with exit code ${ret}"
	fi
}
invoke_solution
sol_status="$(job_status "${sol_job}")"
echo_status "${sol_status}"
printf "%7s" "${execution_time}"
hspace 5


export BOX_PADDING=5

echo -n "check"
check_job="${test_name}.check"
function run_checker_if_needed {
	if "${SKIP_CHECK}"; then
		score="?"
		verdict="Unknown"
		reason="Checker skipped"
	else
		function run_checker {
			bash "${TEMPLATES}/check_test.sh" "${test_name}" "${input_file_path}" "${judge_answer}" "${sol_stdout}" "${sol_stderr}"
		}
		insensitive guard "${check_job}" run_checker
		local ret
		ret="$(job_ret "${check_job}")"

		if [ "${ret}" -ne 0 ]; then
			final_ret="${ret}"
			failed_jobs="${failed_jobs} ${check_job}"

			score="0"
			verdict="Judge Failure"
			reason="checker exited with code ${ret}"
		else
			checker_stdout="${LOGS_DIR}/${check_job}.out"
			checker_stderr="${LOGS_DIR}/${check_job}.err"
			source "${TEMPLATES}/checker_result.sh"
			if has_sensitive_warnings "${check_job}"; then
				final_ret="${warn_status}"
				failed_jobs="${failed_jobs} ${check_job}"
			fi
		fi
	fi
}
if ! is_in "${sol_status}" "FAIL" "SKIP"; then
	run_checker_if_needed
fi
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

echo


if "${SENSITIVE_RUN}" && [ "${final_ret}" -ne "0" ]; then
	for job in ${failed_jobs}; do
		echo
		echo "failed job: ${job}"
		execution_report "${job}"
	done
	exit "${final_ret}"
fi
