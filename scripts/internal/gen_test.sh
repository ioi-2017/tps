#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"
source "${INTERNALS}/run_util.sh"

tests_dir="$1"; shift
test_name="$1"; shift
command="$1"; shift
args=("$@")

input="${tests_dir}/${test_name}.in"
output="${tests_dir}/${test_name}.out"

function gen_input {
	temp_input=${input}.tmp
	pushd "${GEN_DIR}" > /dev/null
	if is_in "${command}" "manual" "copy"; then
		if [ ${#args[@]} -ne 1 ] ; then
			errcho "There must be exactly one argument for test generation command '${command}', but found ${#args[@]} arguments."
			return 1
		fi
		source_file="${args[0]}"
		if [ "${command}" == "manual" ] ; then
			source_file="./manual/${source_file}"
		fi
		readonly source_file
		check_file_exists "Source file" "${source_file}" || return $?
		cp "${source_file}" "${temp_input}" || return $?
	else
		gen_file_name="$(find_runnable_file "${command}" ".")"
		readonly gen_file_name
		if [ -z "${gen_file_name}" ]; then
			errcho "Generator '${command}' not found in '${GEN_DIR}'.
Searched for $(searched_runnable_files_str "${command}" ".")."
			return 4
		fi
		readonly gen_file="./${gen_file_name}"
		# Using ${args[@]+"${args[@]}"} instead of "${args[@]}" because
		#   simple usage of empty arrays causes unbound variable error in old versions of bash with 'set -u'.
		run_file "${gen_file}" ${args[@]+"${args[@]}"} > "${temp_input}" || return $?
	fi
	popd > /dev/null
	
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
