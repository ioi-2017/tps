
# Assumes that "util.sh" is already sourced.
source "${INTERNALS}/run_util.sh"


function compile_generators_if_needed {
	printf "%-${STATUS_PAD}s%s" "generator" "compile"
	if "${SKIP_GEN}"; then
		echo_status "SKIP"
	else
		sensitive reporting_guard "generators.compile" build_with_make "${GEN_DIR}"
	fi
	echo
}


function compile_validators_if_needed {
	printf "%-${STATUS_PAD}s%s" "validator" "compile"
	if "${SKIP_VAL}"; then
		echo_status "SKIP"
	else
		sensitive reporting_guard "validators.compile" build_with_make "${VALIDATOR_DIR}"
	fi
	echo
}


function gen_input {
	local -r input="$1"; shift
	local -r command="$1"; shift
	local -r args=("$@")

	local -r temp_input="${input}.tmp"
	pushdq "${GEN_DIR}"
	if is_in "${command}" "manual" "copy"; then
		if [ ${#args[@]} -ne 1 ] ; then
			errcho "There must be exactly one argument for test generation command '${command}', but found ${#args[@]} arguments."
			return 1
		fi
		local source_file="${args[0]}"
		if [ "${command}" == "manual" ] ; then
			source_file="./manual/${source_file}"
		fi
		readonly source_file
		check_file_exists "Source file" "${source_file}" || return $?
		cp "${source_file}" "${temp_input}" || return $?
	else
		local gen_file_name
		gen_file_name="$(find_runnable_file "${command}" ".")"
		readonly gen_file_name
		if [ -z "${gen_file_name}" ]; then
			errcho "Generator '${command}' not found in '${GEN_DIR}'.
Searched for $(searched_runnable_files_str "${command}" ".")."
			return 4
		fi
		local -r gen_file="./${gen_file_name}"
		run_file "${gen_file}" ${args[@]+"${args[@]}"} > "${temp_input}" || return $?
	fi
	popdq

	local -r header_file="${GEN_DIR}/input.header"
	local -r footer_file="${GEN_DIR}/input.footer"
	if [ -f "${header_file}" -o -f "${footer_file}" ]; then
		local -r temp_input2="${input}.tmp2"
		if [ -f "${header_file}" -a -f "${footer_file}" ]; then
			cat "${header_file}" "${temp_input}" "${footer_file}" > "${temp_input2}"
		elif [ -f "${header_file}" ]; then
			cat "${header_file}" "${temp_input}" > "${temp_input2}"
		elif [ -f "${footer_file}" ]; then
			cat "${temp_input}" "${footer_file}" > "${temp_input2}"
		fi
		mv "${temp_input2}" "${temp_input}"
	fi

	if command_exists "dos2unix" ; then
		dos2unix "${temp_input}" &> "/dev/null"
	fi
	mv "${temp_input}" "${input}"
}


function run_validator_commands_on_input {
	local -r input="$1"; shift
	while read validator_command; do
		[ -z "${validator_command}" ] && continue
		errcho "Starting validator command: ${validator_command}"
		local validator_exit_code=0
		eval "${validator_command}" < "${input}" || validator_exit_code=$?
		if [ "${validator_exit_code}" -eq "0" ]; then
			errcho "OK"
		else
			errcho "Validator command exited with code ${validator_exit_code}"
			return "${validator_exit_code}"
		fi
	done || return $?
}
