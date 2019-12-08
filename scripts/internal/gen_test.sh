#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"

tests_dir="$1"; shift
test_name="$1"; shift
command="$1"; shift
args=("$@")

input="${tests_dir}/${test_name}.in"
output="${tests_dir}/${test_name}.out"

function gen_input {
	temp_input=${input}.tmp
	if [ "${command}" == "manual" ]; then
		if [ ${#args[@]} -ne 1 ] ; then
			errcho "There must be exactly one argument for manual tests, but found ${#args[@]} arguments."
			return 1
		fi
		cp "${GEN_DIR}/manual/${args[0]}" "${temp_input}" || return $?
	else
		"${GEN_DIR}/${command}.exe" "${args[@]}" > "${temp_input}" || return $?
	fi
	
	header_file=${GEN_DIR}/input.header
	footer_file=${GEN_DIR}/input.footer
	if [ -f "${header_file}" -o -f "${footer_file}" ]; then
		temp_input2=${input}.tmp2
		if [ -f "${header_file}" -a -f "${footer_file}" ]; then
			cat "${header_file}" "${temp_input}" "${footer_file}" > "${temp_input2}"
		elif [ -f "${header_file}" ]; then
			cat "${header_file}" "${temp_input}" > "${temp_input2}"
		elif [ -f "${footer_file}" ]; then
			cat "${temp_input}" "${footer_file}" > "${temp_input2}"
		fi
		mv "${temp_input2}" "${temp_input}"
	fi
	
	if command_exists dos2unix ; then
		dos2unix "${temp_input}" >/dev/null 2>&1
	fi
	mv "${temp_input}" "${input}"
}

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
	insensitive guard "${gen_job}" gen_input
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
