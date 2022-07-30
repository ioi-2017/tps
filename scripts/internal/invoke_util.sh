
# Assumes that "util.sh" and "problem_util.sh" are already sourced.


function check_invoke_prerequisites {
	if ! is_windows && ! "${PYTHON}" -c "import psutil" &> "/dev/null"; then
		cerrcho error -n "Error: "
		errcho "Package 'psutil' is not installed."
		errcho "You can install it using:"
		errcho -e "\tpip install psutil"
		errcho "or:"
		errcho -e "\t${PYTHON} -m pip install psutil"
		exit 1
	fi
}


function check_and_init_limit_variables {
	if variable_not_exists "SOFT_TL" ; then
		SOFT_TL="$(get_time_limit)"
	fi

	if ! check_float "${SOFT_TL}"; then
		error_usage_exit 2 "Provided time limit '${SOFT_TL}' is not a positive real number."
	fi

	if variable_not_exists "HARD_TL" ; then
		HARD_TL="$("${PYTHON}" -c "print(${SOFT_TL} + 2)")"
	fi

	if ! check_float "${HARD_TL}"; then
		error_usage_exit 2 "Provided hard time limit '${HARD_TL}' is not a positive real number."
	fi

	if py_test "${HARD_TL} <= ${SOFT_TL}"; then
		error_usage_exit 2 "Provided hard time limit (${HARD_TL}) is not greater than the soft time limit (${SOFT_TL})."
	fi
}


function compile_solution_if_needed {
	local -r skip="$1"; shift
	local -r job_name="$1"; shift
	local -r solution_label="$1"; shift
	local -r solution_path="$1"; shift

	printf "%-${STATUS_PAD}scompile" "${solution_label}"
	if "${skip}"; then
		echo_status "SKIP"
	else
		sensitive reporting_guard "${job_name}" bash "${INTERNALS}/compile_solution.sh" "${solution_path}"
	fi
	echo
}


function compile_checker_if_needed {
	if "${HAS_CHECKER}"; then
		printf "%-${STATUS_PAD}scompile" "checker"
		if "${SKIP_CHECK}"; then
			echo_status "SKIP"
		else
			sensitive reporting_guard "checker.compile" build_with_make "${CHECKER_DIR}"
		fi
		echo
	fi
}


readonly TIME_LIMIT_EXIT_CODE="124"

readonly VERDICT__UNKNOWN="Unknown"
readonly VERDICT__JUDGE_FAILURE="Judge Failure"
readonly VERDICT__TIME_LIMIT_EXCEEDED="Time Limit Exceeded"
readonly VERDICT__RUNTIME_ERROR="Runtime Error"
#readonly VERDICT__WRONG_ANSWER=""
#readonly VERDICT__CORRECT=""


function is_verdict_judge_failure {
	local -r verdict="$1"; shift
	local verdict_low
	verdict_low="$(tr '[:upper:]' '[:lower:]' <<< "${verdict}")"
	grep -Eq 'judge.*fail' <<< "${verdict_low}"
}


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


function print_score {
	local -r score="$1"; shift
	local -r text_width="$1"; shift

	local score_str
	score_str="$(printf "%${text_width}s" "${score}")"
	readonly score_str
	local score_color
	if [ "${score}" == "?" ]; then
		score_color="skipped"
	elif py_test "${score} <= 0"; then
		score_color="red"
	elif py_test "${score} >= 1"; then
		score_color="green"
	else
		score_color="yellow"
	fi
	readonly score_color
	cecho "${score_color}" -n "${score_str}"
}
