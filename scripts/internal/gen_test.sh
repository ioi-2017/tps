#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"
source "${INTERNALS}/gen_util.sh"

tests_dir="$1"; shift
test_name="$1"; shift
gen_command_line=("$@")

input_file_name="${test_name}.in"
output_file_name="${test_name}.out"

input_file_path="${tests_dir}/${input_file_name}"
output_file_path="${tests_dir}/${output_file_name}"


initialize_failed_job_list


printf "%-${STATUS_PAD}s" "${test_name}"

export BOX_PADDING=7

echo -n "gen"
gen_job="${test_name}.gen"
if ! "${SKIP_GEN}"; then
	insensitive guard "${gen_job}" gen_input "${input_file_path}" "${gen_command_line[@]}"
fi
verify_job_failure "${gen_job}"
gen_status="$(job_status "${gen_job}")"
echo_status "${gen_status}"


function validate {
	if [ ! -f "${input_file_path}" ]; then
		errcho "input file '${input_file_name}' is not available"
		return 4
	fi
	local validator_commands
	validator_commands="$(get_test_validator_commands "${tests_dir}" "${test_name}")" || return $?
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


function gen_output {
	if [ ! -f "${input_file_path}" ]; then
		errcho "input file '${input_file_name}' is not available"
		return 4
	fi
	local -r temp_output="${output_file_path}.tmp"
	bash "${SCRIPTS}/run.sh" < "${input_file_path}" > "${temp_output}" || return $?
	mv "${temp_output}" "${output_file_path}"
}

echo -n "sol"
sol_job="${test_name}.sol"
if ! "${SKIP_SOL}" && ! is_in "${gen_status}" "FAIL"; then
	insensitive guard "${sol_job}" gen_output
fi
verify_job_failure "${sol_job}"
sol_status="$(job_status "${sol_job}")"
echo_status "${sol_status}"


echo

if should_stop_for_failed_jobs; then
	stop_for_failed_jobs
fi
