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

function add_failed_job {
	local -r job_name="$1"; shift
	local -r ret="$1"; shift
	final_ret="${ret}"
	failed_jobs="${failed_jobs} ${job_name}"
}

function verify_job_failure {
	local -r job_name="$1"; shift
	local ret
	ret="$(warning_aware_job_ret "${job_name}")"
	is_in "${ret}" "0" "${skip_status}" ||
		add_failed_job "${job_name}" "${ret}"
}


printf "%-${STATUS_PAD}s" "${test_name}"

export BOX_PADDING=4

unset execution_time score verdict reason

echo -n "sol"
sol_job="${test_name}.sol"

# Inputs: job_name, test_name, sol_stdin, sol_stdout, sol_stderr
# This function may set the variables execution_time, score, verdict, and reason
function invoke_solution {
	local -r job_name="$1"; shift
	local -r test_name="$1"; shift
	local -r sol_stdin="$1"; shift
	local -r sol_stdout="$1"; shift
	local -r sol_stderr="$1"; shift

	if [ ! -f "${sol_stdin}" ]; then
		function input_not_found {
			return 4
		}
		insensitive guard "${job_name}" input_not_found
		execution_time=""
		score="0"
		verdict="${VERDICT__JUDGE_FAILURE}"
		reason="input file ${test_name}.in is not available"
		return
	fi

	function run_solution {
		local tlog_file
		tlog_file="$(job_tlog_file "${job_name}")"
		readonly tlog_file
		"${PYTHON}" "${INTERNALS}/timer.py" "${SOFT_TL}" "${HARD_TL}" "${tlog_file}" bash "${TEMPLATES}/run_test.sh" "${test_name}" "${sol_stdin}" "${sol_stdout}" "${sol_stderr}"
	}
	insensitive guard "${job_name}" run_solution
	local ret
	ret="$(job_ret "${job_name}")"
	readonly ret
	execution_time="$(job_tlog "${job_name}" "duration")"

	if [ "${ret}" -eq "${TIME_LIMIT_EXIT_CODE}" ]; then
		score="0"
		verdict="${VERDICT__TIME_LIMIT_EXCEEDED}"
		local terminated
		terminated="$(job_tlog "${job_name}" "terminated")"
		readonly terminated
		if "${terminated}"; then
			reason="solution terminated after hard time limit '${HARD_TL}'"
		else
			local solution_exit_code
			solution_exit_code="$(job_tlog "${job_name}" "ret")"
			readonly solution_exit_code
			reason="solution finished after time limit '${SOFT_TL}', with exit code '${solution_exit_code}'"
		fi
	elif [ "${ret}" -ne "0" ]; then
		score="0"
		verdict="${VERDICT__RUNTIME_ERROR}"
		reason="solution finished with exit code ${ret}"
	fi
}
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

# Inputs: job_name test_name sol_stdin judge_answer sol_stdout sol_stderr
# This function may set the variables score, verdict, and reason
function run_checker_if_needed {
	local -r job_name="$1"; shift
	local -r test_name="$1"; shift
	local -r sol_stdin="$1"; shift
	local -r judge_answer="$1"; shift
	local -r sol_stdout="$1"; shift
	local -r sol_stderr="$1"; shift

	if "${SKIP_CHECK}"; then
		score="?"
		verdict="${VERDICT__UNKNOWN}"
		reason="Checker skipped"
	else
		function run_checker {
			function issue_judge_failure_verdict {
				local -r _local_reason="$1"; shift
				score="0"
				verdict="${VERDICT__JUDGE_FAILURE}"
				reason="${_local_reason}"
			}
			local ret=0
			bash "${TEMPLATES}/check_test.sh" "${test_name}" "${sol_stdin}" "${judge_answer}" "${sol_stdout}" "${sol_stderr}" || ret=$?
			if [ "${ret}" -ne "0" ]; then
				issue_judge_failure_verdict "checker exited with code ${ret}"
				return "${ret}"
			fi
			local -r checker_stdout="${LOGS_DIR}/${job_name}.out"
			local -r checker_stderr="${LOGS_DIR}/${job_name}.err"
			function source_checker_result {
				source "${TEMPLATES}/checker_result.sh"
			}
			source_checker_result
			return 0
		}
		insensitive guard "${job_name}" run_checker
	fi
}
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

echo


if "${SENSITIVE_RUN}" && [ "${final_ret}" -ne "0" ]; then
	for job in ${failed_jobs}; do
		echo
		echo "failed job: ${job}"
		execution_report "${job}"
	done
	exit "${final_ret}"
fi
