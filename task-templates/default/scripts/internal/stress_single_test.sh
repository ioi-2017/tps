#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"
source "${INTERNALS}/gen_util.sh"
source "${INTERNALS}/invoke_util.sh"

round_index="$1"; shift
gen_command_line=("$@")

test_name="testcase"
input_file_name="${test_name}.in"
input_file_path="${SANDBOX_ROOT}/${input_file_name}"
model_output="${SANDBOX_MODEL}/${test_name}.out"
stressed_stdout="${SANDBOX_STRESSED}/${test_name}.out"
stressed_stderr="${SANDBOX_STRESSED}/${test_name}.err"

# Remove any remaining files from previous runs
rm -f "${input_file_path}" "${model_output}" "${stressed_stdout}" "${stressed_stderr}"

initialize_failed_job_list


export BOX_PADDING=6

echo -n "gen"
gen_job="${test_name}.gen"
echo "${gen_command_line[@]}" > "${LOGS_DIR}/${gen_job}.args"
insensitive guard "${gen_job}" gen_input "${input_file_path}" "${gen_command_line[@]}"
verify_job_failure "${gen_job}"
gen_status="$(job_status "${gen_job}")"
echo_status "${gen_status}"


function validate {
	if [ ! -f "${input_file_path}" ]; then
		errcho "input file '${input_file_name}' is not available"
		return 4
	fi
	local validator_commands
	validator_commands="$(get_global_validator_commands)" || return $?
	run_validator_commands_on_input "${input_file_path}" <<< "${validator_commands}" || return $?
}

echo -n "val"
val_job="${test_name}.val"
if ! "${SKIP_VAL}" && ! is_in "${gen_status}" "FAIL"; then
	insensitive guard "${val_job}" validate
fi
verify_job_failure "${val_job}"
val_status="$(job_status "${val_job}")"
echo_status "${val_status}"


function create_model_output {
	if [ ! -f "${input_file_path}" ]; then
		errcho "input file '${input_file_name}' is not available"
		return 4
	fi
	local -r temp_output="${model_output}.tmp"
	export SANDBOX="${SANDBOX_MODEL}"
	local ret=0
	bash "${SCRIPTS}/run.sh" < "${input_file_path}" > "${temp_output}" || ret=$?
	unset SANDBOX
	[ "${ret}" -eq "0" ] ||
		return "${ret}"
	mv "${temp_output}" "${model_output}"
}

echo -n "model"
model_job="${test_name}.model"
if ! "${SKIP_MODEL}" && ! is_in "${gen_status}" "FAIL"; then
	insensitive guard "${model_job}" create_model_output
fi
verify_job_failure "${model_job}"
model_status="$(job_status "${model_job}")"
echo_status "${model_status}"



export BOX_PADDING=4

unset execution_time score verdict reason

echo -n "stressed"
stressed_job="${test_name}.stressed"
if is_in "${gen_status}" "FAIL"; then
	execution_time=""
	score="?"
	verdict="${VERDICT__UNKNOWN}"
	reason="Failure in generating input"
else
	export SANDBOX="${SANDBOX_STRESSED}"
	invoke_solution "${stressed_job}" "${test_name}" "${input_file_path}" "${stressed_stdout}" "${stressed_stderr}"
	unset SANDBOX
fi
if variable_exists "verdict" && is_verdict_judge_failure "${verdict}"; then
	verify_job_failure "${stressed_job}"
fi
stressed_status="$(job_status "${stressed_job}")"
echo_status "${stressed_status}"
printf "%7s" "${execution_time}"
hspace 4


export BOX_PADDING=5

echo -n "check"
check_job="${test_name}.check"
if ! is_in "${stressed_status}" "FAIL" "SKIP"; then
	export SANDBOX="${SANDBOX_STRESSED}"
	run_checker_if_needed "${check_job}" "${test_name}" "${input_file_path}" "${model_output}" "${stressed_stdout}" "${stressed_stderr}"
	unset SANDBOX
fi
verify_job_failure "${check_job}"
check_status="$(job_status "${check_job}")"
echo_status "${check_status}"

print_score "${score}" "6"
hspace 2

export BOX_PADDING=20
echo_verdict "${verdict}"

echo "${score}" > "${LOGS_DIR}/${test_name}.score"
echo "${verdict}" > "${LOGS_DIR}/${test_name}.verdict"
echo "${reason}" > "${LOGS_DIR}/${test_name}.reason"

echo

if should_stop_for_failed_jobs; then
	echo
	echo "Failure on gen command line:"
	echo "${gen_command_line[@]}"
	stop_for_failed_jobs
fi

if is_signed_decimal_format "${score}" && py_test "${score} < ${MIN_SCORE}"; then
	cecho "error" "Hacked!"
	echo "${gen_command_line[@]}" >> "${LOGS_DIR}/hacked.txt"
	if "${HACK_SENSITIVE}"; then
		echo
		cecho "yellow" "Gen command line:"
		echo "${gen_command_line[@]}"
		exit 100
	fi
fi
