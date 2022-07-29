#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"
source "${INTERNALS}/gen_util.sh"

tests_dir="$1"; shift
test_name="$1"; shift
gen_command_line=("$@")

input="${tests_dir}/${test_name}.in"
output="${tests_dir}/${test_name}.out"

function gen_output {
	if [ ! -f "${input}" ]; then
		errcho "input file ${test_name}.in is not available"
		return 4
	fi
	temp_output=${output}.tmp
	bash "${SCRIPTS}/run.sh" < "${input}" > "${temp_output}" || return $?
	mv "${temp_output}" "${output}"
}

function validate {
	if [ ! -f "${input}" ]; then
		errcho "input file ${test_name}.in is not available"
		return 4
	fi
	
	get_test_validator_commands "${tests_dir}" "${test_name}" | while read validator_command; do
		[ -z "${validator_command}" ] && continue
		errcho "starting validator command: ${validator_command}"
		eval "${validator_command}" < "${input}" || return $?
		errcho "OK"
	done || return $?
}


printf "%-${STATUS_PAD}s" "${test_name}"

failed_jobs=""
final_ret=0

function verify_job_failure {
	local job="$1"
	local ret=$(warning_aware_job_ret "${job}")
	if [ ${ret} -ne 0 ]; then
		final_ret=${ret}
		failed_jobs="${failed_jobs} ${job}"
	fi
}


export BOX_PADDING=7

echo -n "gen"
gen_job="${test_name}.gen"

if ! "${SKIP_GEN}"; then
	insensitive guard "${gen_job}" gen_input "${input}" "${gen_command_line[@]}"
	verify_job_failure "${gen_job}"
fi

gen_status=$(job_status "${gen_job}")
echo_status "${gen_status}"


echo -n "val"
val_job="${test_name}.val"

if ! "${SKIP_VAL}" && ! is_in "${gen_status}" "FAIL"; then
	insensitive guard "${val_job}" validate
	verify_job_failure "${val_job}"
fi

val_status=$(job_status "${val_job}")
echo_status "${val_status}"


echo -n "sol"
sol_job="${test_name}.sol"

if ! "${SKIP_SOL}" && ! is_in "${gen_status}" "FAIL"; then
	insensitive guard "${sol_job}" gen_output
	verify_job_failure "${sol_job}"
fi

sol_status=$(job_status "${sol_job}")
echo_status "${sol_status}"


echo


if "${SENSITIVE_RUN}"; then
	if [ ${final_ret} -ne 0 ]; then
		for job in ${failed_jobs}; do
			echo
			echo "failed job: ${job}"
			execution_report "${job}"
		done

		exit ${final_ret}
	fi
fi
