
_TPS_TESTS_ABS_DIR="$(_TT_absolute_path "${_TPS_TESTS_DIR}")"
PROJECT_ROOT="$(_TT_absolute_path "${_TPS_TESTS_DIR}/..")"

_TT_SANDBOX="${_TPS_TESTS_ABS_DIR}/sandbox"
_TT_STAGE="${_TT_SANDBOX}/stage"



# Using string instead of array, since arrays are not exported in some versions of bash.
_TT_TEST_CONTEXT=""

function get_test_context {
	local tc
	while read tc; do
		echo -n "> ${tc} "
	done <<< "${_TT_TEST_CONTEXT}"
}

function print_test_context {
	get_test_context >&2
	_TT_errcho
}

function _TT_is_verbose {
	_TT_variable_exists "_TT_VERBOSE" && "${_TT_VERBOSE}"
}

function push_test_context {
	local -r tc="$1"; shift
	[ -z "${_TT_TEST_CONTEXT}" ] ||
		_TT_TEST_CONTEXT="${_TT_TEST_CONTEXT}${_TT_NEW_LINE}"
	local tc_escaped
	# Escaping newline (\n) and backslash (\\) in the test context
	# Source: https://stackoverflow.com/a/1252191
	tc_escaped="$(echo "${tc}" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\\\\/\\\\\\\\/g' -e 's/\n/\\\\n/g')"
	_TT_TEST_CONTEXT="${_TT_TEST_CONTEXT}${tc_escaped}"
	if _TT_is_verbose; then
		_TT_errcho "++ $(get_test_context)"
	fi
}

function pop_test_context {
	if _TT_is_verbose; then
		_TT_errcho "-- $(get_test_context)"
	fi
	local last_new_line_index=0
	local i
	for ((i=0; i<${#_TT_TEST_CONTEXT}; i++)); do
		[ "${_TT_TEST_CONTEXT:${i}:1}" != "${_TT_NEW_LINE}" ] ||
			last_new_line_index="${i}"
	done
	_TT_TEST_CONTEXT="${_TT_TEST_CONTEXT:0:${last_new_line_index}}"
}



function pushd_test_context {
	_TT_pushdq_here
	push_test_context "$@"
}

function pushd_test_context_here {
	_TT_pushdq_here
	push_test_context "$(basename "${PWD}")"
}

function popd_test_context {
	_TT_popdq
	pop_test_context "$@"
}



function _TT_test_error_exit {
	local -r exit_code="$1"; shift
	print_test_context
	_TT_errcho "$@"
	exit "${exit_code}"
}


function stage_dir {
	local -r dir="$1"; shift
	_TT_check_directory_exists "Staging directory" "${dir}"
	mkdir -p "${_TT_STAGE}" # Making sure parent directories are created.
	rm -rf "${_TT_STAGE}"
	cp -R "${dir}" "${_TT_STAGE}"
	STAGED_DIR="$(_TT_absolute_path "${dir}")"
}


function _TT_test_failure {
	local -r message="$1"; shift
	_TT_errcho "Test failure:"
	print_test_context
	_TT_errcho "${message}"
	exit 10
}

function _TT_assert_equal {
	local -r name="$1"; shift
	local -r expected="$1"; shift
	local -r actual="$1"; shift
	[ "${expected}" == "${actual}" ] ||
		_TT_test_failure "Incorrect value for ${name}, expected: '${expected}', actual: '${actual}'."
}

function _TT_assert_equal_variable {
	local -r name="$1"; shift
	local -r expected_varname="$1"; shift
	local -r actual_varname="$1"; shift
	if _TT_variable_not_exists "${expected_varname}"; then
		_TT_variable_not_exists "${actual_varname}" ||
			_TT_test_failure "${name} expected to be undefined."
		return 0
	fi
	_TT_variable_exists "${actual_varname}" ||
		_TT_test_failure "${name} expected to be defined."
	! _TT_is_variable_array "${actual_varname}" ||
		_TT_test_failure "${name} was not expected to be an array."
	local -r var_expected_value="${!expected_varname}"
	local -r var_actual_value="${!actual_varname}"
	_TT_assert_equal "${name}" "${var_expected_value}" "${var_actual_value}"
}

function _TT_assert_equal_array {
	local -r name="$1"; shift
	local -r expected_varname="$1"; shift
	local -r actual_varname="$1"; shift
	if _TT_variable_not_exists "${expected_varname}"; then
		_TT_variable_not_exists "${actual_varname}" ||
			_TT_test_failure "${name} expected to be undefined."
		return 0
	fi
	_TT_variable_exists "${actual_varname}" ||
		_TT_test_failure "${name} expected to be defined."
	_TT_is_variable_array "${actual_varname}" ||
		_TT_test_failure "${name} expected to be an array."
	local -a expected_array
	_TT_set_array_variable "expected_array" "${expected_varname}"
	readonly expected_array
	local -a actual_array
	_TT_set_array_variable "actual_array" "${actual_varname}"
	readonly actual_array
	local -r actual_len="${#actual_array[@]}"
	local -a expected_len="${#expected_array[@]}"
	[ "${expected_len}" == "${actual_len}" ] ||
		_TT_test_failure "Incorrect length for ${name}, expected: ${expected_len}, actual: ${actual_len}."
	local i
	for ((i=0; i<expected_len; i++)); do
		[ "${expected_array[${i}]}" == "${actual_array[${i}]}" ] ||
			_TT_test_failure "Incorrect value at item ${i} of ${name}, expected: '${expected_array[${i}]}', actual: '${actual_array[${i}]}'."
	done
}

function _TT_assert_file_content {
	local -r name="$1"; shift
	local -r expected_content="$1"; shift
	local -r actual_file_name="$1"; shift
	local actual_file_content
	_TT_read_file_exactly "actual_file_content" "${actual_file_name}"
	if [ "${expected_content}" != "${actual_file_content}" ]; then
		_TT_test_failure "Incorrect data in ${name} (${actual_file_name}).
============== Expected ==============
${expected_content}======================================
=============== Actual ===============
${actual_file_content}======================================"
	fi
}

function _TT_assert_same_files {
	local -r name="$1"; shift
	local -r expected="$1"; shift
	local -r actual="$1"; shift
	local -r diff_file="${_TT_SANDBOX}/latest.diff"
	if ! diff "${expected}" "${actual}" > "${diff_file}" 2>&1; then
		local diff_info
		diff_info="$(_TT_truncated_cat "${diff_file}" 20)"
		readonly diff_info
		_TT_test_failure "Incorrect data in ${name}, expected: '${expected}', actual: '${actual}'.
${diff_info}"
	fi
}

function _TT_assert_same_directories {
	local -r name="$1"; shift
	local -r expected="$1"; shift
	local -r actual="$1"; shift
	local -r diff_file="${_TT_SANDBOX}/latest.diff"
	if ! diff -rq "${expected}" "${actual}" > "${diff_file}" 2>&1; then
		local diff_info
		diff_info="$(_TT_truncated_cat "${diff_file}" 20)"
		readonly diff_info
		_TT_test_failure "Incorrect directory contents in ${name}, expected: '${expected}', actual: '${actual}'.
${diff_info}"
	fi
}

function _TT_assert_file_empty {
	local -r name="$1"; shift
	local -r actual="$1"; shift
	_TT_is_file_empty "${actual}" ||
		_TT_test_failure "Expected ${name} to be empty, actual: '${actual}'."
}


function set_exec_cwd {
	EXEC_WORKING_DIRECTORY="$1"
}

function unset_exec_cwd {
	unset EXEC_WORKING_DIRECTORY
}


function get_probed_variable_status_varname {
	local -r var_name="$1"; shift
	echo "__PROBED_VARIABLE_STATUS__${var_name}"
}

function get_probed_variable_expected_value_varname {
	local -r var_name="$1"; shift
	echo "__PROBED_VARIABLE_EXPECTED_VALUE__${var_name}"
}

function get_probed_variable_actual_value_varname {
	local -r var_name="$1"; shift
	echo "__PROBED_VARIABLE_ACTUAL_VALUE__${var_name}"
}


function _TT_dump_variable_value {
	local -r _TT_f_variable_value_varname="$1"; shift
	if _TT_is_variable_array "${_TT_f_variable_value_varname}"; then
		local -a _TT_f_array_value
		_TT_set_array_variable "_TT_f_array_value" "${_TT_f_variable_value_varname}"
		printf "("
		local _TT_f_array_item _TT_f_array_item_escaped
		for _TT_f_array_item in ${_TT_f_array_value[@]+"${_TT_f_array_value[@]}"}; do
			_TT_f_array_item_escaped="$(_TT_escape_arg "${_TT_f_array_item}")"
			printf " %s" "${_TT_f_array_item_escaped}"
		done
		printf " )"
	else
		local _TT_f_variable_value="${!_TT_f_variable_value_varname}"
		local _TT_f_variable_value_escaped
		_TT_f_variable_value_escaped="$(_TT_escape_arg "${_TT_f_variable_value}")"
		printf "%s" "${_TT_f_variable_value_escaped}"
	fi
}

function _TT_dump_variable_name_and_value {
	local -r _TT_f_variable_name="$1"; shift
	local -r _TT_f_variable_value_varname="$1"; shift
	printf "%s=" "${_TT_f_variable_name}"
	_TT_dump_variable_value "${_TT_f_variable_value_varname}"
	printf "\n"
}


function _TT_exec_parse_options {
	make_command_path_absolute="false"
	readonly WD_STATUS_UNSPECIFIED="unspecified"
	readonly WD_STATUS_GIVEN="given"
	working_directory_status="${WD_STATUS_UNSPECIFIED}"
	readonly FILE_STATUS_UNSPECIFIED="unspecified"
	readonly FILE_STATUS_FILE="file"
	readonly FILE_STATUS_HERE="here"
	readonly FILE_STATUS_EMPTY="empty"
	readonly FILE_STATUS_IGNORE="ignore"
	stdin_status="${FILE_STATUS_UNSPECIFIED}"
	stdin_file=""
	stdout_status="${FILE_STATUS_UNSPECIFIED}"
	stdout_file=""
	stderr_status="${FILE_STATUS_UNSPECIFIED}"
	stderr_file=""
	readonly RETURN_STATUS_UNSPECIFIED="unspecified"
	readonly RETURN_STATUS_FIXED="fixed"
	readonly RETURN_STATUS_NONZERO="nonzero"
	readonly RETURN_STATUS_IGNORE="ignore"
	return_code_status="${RETURN_STATUS_UNSPECIFIED}"
	readonly PROBED_VAR_STATUS_CAPTURE="capture"
	readonly PROBED_VAR_STATUS_UNSET="unset"
	readonly PROBED_VAR_STATUS_STRING="string"
	readonly PROBED_VAR_STATUS_ARRAY="array"
	probed_variables=()
	probed_variable_capture_arg_indices=()
	readonly PROBED_FILE_STATUS_UNSPECIFIED="unspecified"
	readonly PROBED_FILE_STATUS_CAPTURE="capture"
	readonly PROBED_FILE_STATUS_NONEXISTING="nonexisting"
	readonly PROBED_FILE_STATUS_EMPTY_FILE="empty-file"
	readonly PROBED_FILE_STATUS_EMPTY_DIR="empty-dir"
	readonly PROBED_FILE_STATUS_FILE="file"
	readonly PROBED_FILE_STATUS_HERE="here"
	probed_files=()
	probed_files_status=()
	probed_files_expected_value=()
	probed_file_capture_arg_indices=()

	shifts=0

	local arg_shifts

	function _TT_read_here_file_arguments {
		# Reads a file content given as arguments & stores in a variable (given by its name).
		# The amount of arguments to shift is also stored in a variable (given by its name).
		# Examples ("flag-suffix" "args"... --> "content" shift):
		# "h" "abc" --> "abc\n" 1
		# "H" "abc" --> "abc" 1
		# "h2" "abc" "def" --> "abc\ndef\n" 2
		local -r option_flag="$1"; shift
		local -r option_suffix="$1"; shift
		local -r arg_shifts_varname="$1"; shift
		local -r file_content_varname="$1"; shift
		local -r option_suffix_char="${option_suffix:0:1}"
		local -r option_suffix_num="${option_suffix:1}"
		if [ -n "${option_suffix_num}" ]; then
			local -r num_lines="${option_suffix_num}"
			_TT_is_nonnegative_integer "${num_lines}" ||
				_TT_test_error_exit 2 "Undefined option '${option_flag}'."
		else
			local -r num_lines=1
		fi
		[ $# -ge "${num_lines}" ] ||
			_TT_test_error_exit 2 "Insufficient number of arguments after '${option_flag}'."
		local _TT_f_file_content
		local _TT_f_arg_shifts=0
		local i line
		for ((i=0; i<num_lines; i++)); do
			line="$1"; shift; _TT_increment "_TT_f_arg_shifts"
			[ "${i}" -eq 0 ] ||
				_TT_f_file_content="${_TT_f_file_content}${_TT_NEW_LINE}"
			_TT_f_file_content="${_TT_f_file_content}${line}"
		done
		[ "${option_suffix_char}" != "h" ] ||
			_TT_f_file_content="${_TT_f_file_content}${_TT_NEW_LINE}"
		_TT_set_variable "${arg_shifts_varname}" "${_TT_f_arg_shifts}"
		_TT_set_variable "${file_content_varname}" "${_TT_f_file_content}"
	}

	function _TT_exec_read_file_status_args {
		local -r option_flag="$1"; shift
		local -r status_varname="$1"; shift
		local -r file_varname="$1"; shift

		local -r option_suffix="${option_flag:2}"
		arg_shifts=0
		case "${option_suffix}" in
			"")
				local -r file_value="$1"; shift; _TT_increment arg_shifts
				_TT_set_variable "${status_varname}" "${FILE_STATUS_FILE}"
				_TT_set_variable "${file_varname}" "${file_value}"
				;;
			h*|H*)
				local file_content
				local here_arg_shifts
				_TT_read_here_file_arguments "${option_flag}" "${option_suffix}" "here_arg_shifts" "file_content" "$@"
				shift "${here_arg_shifts}"; _TT_increment "arg_shifts" "${here_arg_shifts}"
				_TT_set_variable "${status_varname}" "${FILE_STATUS_HERE}"
				_TT_set_variable "${file_varname}" "${file_content}"
				;;
			empty)
				_TT_set_variable "${status_varname}" "${FILE_STATUS_EMPTY}"
				;;
			ignore)
				_TT_set_variable "${status_varname}" "${FILE_STATUS_IGNORE}"
				;;
			*)
				_TT_test_error_exit 2 "Undefined option '${option_flag}'."
				;;
		esac
	}

	function _TT_exec_read_var_status_args {
		local -r option_flag="$1"; shift

		local -r option_suffix="${option_flag:2}"
		arg_shifts=0
		local -r var_name="$1"; shift; _TT_increment arg_shifts
		local -r var_status_varname="$(get_probed_variable_status_varname "${var_name}")"
		local -r var_expected_value_varname="$(get_probed_variable_expected_value_varname "${var_name}")"
		probed_variables+=("${var_name}")
		case "${option_suffix}" in
			c)
				"${is_capture_mode}" ||
					_TT_test_error_exit 2 "Option '${option_flag}' is only available in capture mode."
				_TT_set_variable "${var_status_varname}" "${PROBED_VAR_STATUS_CAPTURE}"
				probed_variable_capture_arg_indices+=("$((shifts-1))")
				;;
			u)
				_TT_set_variable "${var_status_varname}" "${PROBED_VAR_STATUS_UNSET}"
				;;
			s)
				_TT_set_variable "${var_status_varname}" "${PROBED_VAR_STATUS_STRING}"
				local -r var_value="$1"; shift; _TT_increment arg_shifts
				_TT_set_variable "${var_expected_value_varname}" "${var_value}"
				;;
			a)
				_TT_set_variable "${var_status_varname}" "${PROBED_VAR_STATUS_ARRAY}"
				local -r array_len="$1"; shift; _TT_increment arg_shifts
				_TT_is_nonnegative_integer "${array_len}" ||
					_TT_test_error_exit 2 "Undefined option '${option_flag}'."
				[ $# -ge "${array_len}" ] ||
					_TT_test_error_exit 2 "Insufficient number of arguments after '${option_flag}'."
				local -a var_value=()
				local i item
				for ((i=0; i<array_len; i++)); do
					item="$1"; shift; _TT_increment arg_shifts
					var_value+=("${item}")
				done
				_TT_set_array_variable "${var_expected_value_varname}" "var_value"
				;;
			*)
				_TT_test_error_exit 2 "Undefined option '${option_flag}'."
				;;
		esac
	}

	function _TT_exec_read_probed_file_status_args {
		local -r option_flag="$1"; shift
		arg_shifts=0
		local -r file_name="$1"; shift; _TT_increment arg_shifts
		local probed_file_status="${PROBED_FILE_STATUS_UNSPECIFIED}"
		local probed_file_expected_value="?"
		local -r option_suffix="${option_flag:2}"
		case "${option_suffix}" in
			c)
				"${is_capture_mode}" ||
					_TT_test_error_exit 2 "Option '${option_flag}' is only available in capture mode."
				probed_file_status="${PROBED_FILE_STATUS_CAPTURE}"
				probed_file_capture_arg_indices+=("$((shifts-1))")
				;;
			u)
				probed_file_status="${PROBED_FILE_STATUS_NONEXISTING}"
				;;
			empty)
				probed_file_status="${PROBED_FILE_STATUS_EMPTY_FILE}"
				;;
			empty-dir)
				probed_file_status="${PROBED_FILE_STATUS_EMPTY_DIR}"
				;;
			"")
				local -r file_value="$1"; shift; _TT_increment arg_shifts
				probed_file_status="${PROBED_FILE_STATUS_FILE}"
				probed_file_expected_value="${file_value}"
				;;
			h*|H*)
				local file_content
				local here_arg_shifts
				_TT_read_here_file_arguments "${option_flag}" "${option_suffix}" "here_arg_shifts" "file_content" "$@"
				shift "${here_arg_shifts}"; _TT_increment "arg_shifts" "${here_arg_shifts}"
				probed_file_status="${PROBED_FILE_STATUS_HERE}"
				probed_file_expected_value="${file_content}"
				;;
			*)
				_TT_test_error_exit 2 "Undefined option '${option_flag}'."
				;;
		esac
		probed_files+=("${file_name}")
		probed_files_status+=("${probed_file_status}")
		probed_files_expected_value+=("${probed_file_expected_value}")
	}

	while [ $# -gt 0 ] && _TT_str_starts_with "$1" "-"; do
		local option="$1"; shift; _TT_increment shifts
		case "${option}" in
			-d)
				working_directory_status="${WD_STATUS_GIVEN}"
				working_directory="$1"; shift; _TT_increment shifts
				;;
			-i|-iempty|-ih*|-iH*)
				_TT_exec_read_file_status_args "${option}" stdin_status stdin_file "$@"
				shift "${arg_shifts}"; _TT_increment shifts "${arg_shifts}"
				;;
			-o*)
				_TT_exec_read_file_status_args "${option}" stdout_status stdout_file "$@"
				shift "${arg_shifts}"; _TT_increment shifts "${arg_shifts}"
				;;
			-e*)
				_TT_exec_read_file_status_args "${option}" stderr_status stderr_file "$@"
				shift "${arg_shifts}"; _TT_increment shifts "${arg_shifts}"
				;;
			-v*)
				_TT_exec_read_var_status_args "${option}" "$@"
				shift "${arg_shifts}"; _TT_increment shifts "${arg_shifts}"
				;;
			-f*)
				_TT_exec_read_probed_file_status_args "${option}" "$@"
				shift "${arg_shifts}"; _TT_increment shifts "${arg_shifts}"
				;;
			-r)
				return_code_status="${RETURN_STATUS_FIXED}"
				expected_return_code="$1"; shift; _TT_increment shifts
				;;
			-rnz)
				return_code_status="${RETURN_STATUS_NONZERO}"
				;;
			-rignore)
				return_code_status="${RETURN_STATUS_IGNORE}"
				;;
			-abs)
				make_command_path_absolute="true"
				;;
			*)
				_TT_test_error_exit 2 "Undefined option '${option}'."
				;;
		esac
	done

	[ $# -gt 0 ] ||
		_TT_test_error_exit 2 "Command is not given."
	readonly command_name="$1"; shift; _TT_increment shifts
}


function _TT_absolute_stage_path {
	local -r the_path="$1"; shift
	if _TT_str_starts_with "${the_path}" "/"; then
		echo "${the_path}"
	else
		echo "${_TT_STAGE}/${the_path}"
	fi
}


function _TT_exec_run_command {
	if [ "${working_directory_status}" == "${WD_STATUS_UNSPECIFIED}" ]; then
		if _TT_variable_exists "EXEC_WORKING_DIRECTORY"; then
			working_directory="${EXEC_WORKING_DIRECTORY}"
		else
			working_directory="."
		fi
	fi

	local abs_working_directory
	abs_working_directory="$(_TT_absolute_stage_path "${working_directory}")"
	readonly abs_working_directory
	_TT_check_directory_exists "Working directory" "${abs_working_directory}"

	mkdir -p "${_TT_SANDBOX}"

	exec_stdin="${_TT_SANDBOX}/exec.in"
	rm -f "${exec_stdin}" # Just for cleaning up
	case "${stdin_status}" in
		"${FILE_STATUS_UNSPECIFIED}"|"${FILE_STATUS_EMPTY}")
			exec_stdin="/dev/null"
			;;
		"${FILE_STATUS_FILE}")
			cp "${stdin_file}" "${exec_stdin}"
			;;
		"${FILE_STATUS_HERE}")
			printf "%s" "${stdin_file}" > "${exec_stdin}"
			;;
		*)
			_TT_test_error_exit 5 "Illegal state; unknown stdin status '${stdin_status}'."
			;;
	esac
	readonly exec_stdin

	readonly exec_stdout="${_TT_SANDBOX}/exec.out"
	readonly exec_stderr="${_TT_SANDBOX}/exec.err"
	readonly exec_variables="${_TT_SANDBOX}/exec.vars"

	local exec_abs_stdin
	exec_abs_stdin="$(_TT_absolute_path "${exec_stdin}")"
	readonly exec_abs_stdin
	local exec_abs_stdout
	exec_abs_stdout="$(_TT_absolute_path "${exec_stdout}")"
	readonly exec_abs_stdout
	local exec_abs_stderr
	exec_abs_stderr="$(_TT_absolute_path "${exec_stderr}")"
	readonly exec_abs_stderr
	local exec_abs_variables
	exec_abs_variables="$(_TT_absolute_path "${exec_variables}")"
	readonly exec_abs_variables

	if _TT_str_ends_with "${command_name}" ".sh" || _TT_str_ends_with "${command_name}" ".py"; then
		make_command_path_absolute="true"
	fi

	if "${make_command_path_absolute}"; then
		local abs_command
		abs_command="$(_TT_absolute_path "${command_name}")"
		readonly abs_command
	else
		local -r abs_command="${command_name}"
	fi

	if _TT_str_ends_with "${abs_command}" ".sh"; then
		local -ra command_array=("bash" "${abs_command}")
	elif _TT_str_ends_with "${abs_command}" ".py"; then
		local _TT_exec_py_cmd
		function _TT_exec_check_py_cmd {
			local -r CMD="$1"; shift
			_TT_command_exists "${CMD}" ||
				return 1
			_TT_exec_py_cmd="${CMD}"
			return 0
		}
		if _TT_variable_exists "PYTHON" ; then
			_TT_exec_check_py_cmd "${PYTHON}" ||
				_TT_test_error_exit 3 "Python command '${PYTHON}' does not exist."
		else
			_TT_exec_check_py_cmd "python3" ||
				_TT_exec_check_py_cmd "python" ||
				_TT_test_error_exit 3 "Neither of python commands 'python3' nor 'python' exists."
		fi
		local -ra command_array=("${_TT_exec_py_cmd}" "${abs_command}")
	else
		local -ra command_array=("${abs_command}")
	fi

	_TT_pushdq "${abs_working_directory}"
	rm -f "${exec_abs_variables}"
	touch "${exec_abs_variables}"
	exec_return_code=0
	(
		"${command_array[@]}" "$@" < "${exec_abs_stdin}" > "${exec_abs_stdout}" 2>"${exec_abs_stderr}" || exec_return_code=$?
		local probed_var_name
		for probed_var_name in ${probed_variables[@]+"${probed_variables[@]}"}; do
			_TT_variable_exists "${probed_var_name}" ||
				continue
			local var_actual_value_varname
			var_actual_value_varname="$(get_probed_variable_actual_value_varname "${probed_var_name}")"
			_TT_dump_variable_name_and_value "${var_actual_value_varname}" "${probed_var_name}"
		done > "${exec_abs_variables}"
		exit "${exec_return_code}"
	) || exec_return_code=$?
	_TT_popdq
}


function expect_exec {
	(
	push_test_context "expect_exec $(_TT_array_to_str_args "$@")"

	local -r is_capture_mode="false"
	local WD_STATUS_UNSPECIFIED
	local WD_STATUS_GIVEN
	local working_directory_status
	local working_directory
	local FILE_STATUS_UNSPECIFIED
	local FILE_STATUS_FILE
	local FILE_STATUS_HERE
	local FILE_STATUS_EMPTY
	local FILE_STATUS_IGNORE
	local stdin_status
	local stdin_file
	local RETURN_STATUS_UNSPECIFIED
	local RETURN_STATUS_FIXED
	local RETURN_STATUS_NONZERO
	local RETURN_STATUS_IGNORE
	local return_code_status
	local expected_return_code
	local make_command_path_absolute
	local stdout_status
	local stdout_file
	local stderr_status
	local stderr_file
	local PROBED_VAR_STATUS_CAPTURE
	local PROBED_VAR_STATUS_UNSET
	local PROBED_VAR_STATUS_STRING
	local PROBED_VAR_STATUS_ARRAY
	local probed_variables
	local probed_variable_capture_arg_indices
	local PROBED_FILE_STATUS_UNSPECIFIED
	local PROBED_FILE_STATUS_CAPTURE
	local PROBED_FILE_STATUS_NONEXISTING
	local PROBED_FILE_STATUS_EMPTY_FILE
	local PROBED_FILE_STATUS_EMPTY_DIR
	local PROBED_FILE_STATUS_FILE
	local PROBED_FILE_STATUS_HERE
	local probed_files
	local probed_files_status
	local probed_files_expected_value
	local probed_file_capture_arg_indices
	local command_name
	local shifts
	_TT_exec_parse_options "$@"
	shift "${shifts}"

	[ "${stdout_status}" != "${FILE_STATUS_UNSPECIFIED}" ] ||
		_TT_test_error_exit 2 "Status of stdout is not specified."
	[ "${stderr_status}" != "${FILE_STATUS_UNSPECIFIED}" ] ||
		_TT_test_error_exit 2 "Status of stderr is not specified."

	local exec_stdin
	local exec_stdout
	local exec_stderr
	local exec_variables
	local exec_return_code
	_TT_exec_run_command "$@"

	if [ "${return_code_status}" == "${RETURN_STATUS_IGNORE}" ]; then
		: Do nothing
	elif [ "${return_code_status}" == "${RETURN_STATUS_UNSPECIFIED}" ]; then
		_TT_assert_equal "execution return code" "0" "${exec_return_code}"
	elif [ "${return_code_status}" == "${RETURN_STATUS_FIXED}" ]; then
		_TT_assert_equal "execution return code" "${expected_return_code}" "${exec_return_code}"
	elif [ "${return_code_status}" == "${RETURN_STATUS_NONZERO}" ]; then
		[ "${exec_return_code}" -ne 0 ] ||
			_TT_test_failure "Execution return code is zero, while expected to be nonzero."
	else
		_TT_test_error_exit 5 "Illegal state; invalid return code status '${return_code_status}'."
	fi

	function _TT_exec_check_output_file {
		local -r name="$1"; shift
		local -r status="$1"; shift
		local -r expected_file="$1"; shift
		local -r exec_file="$1"; shift
		if [ "${status}" == "${FILE_STATUS_IGNORE}" ]; then
			: Do nothing
		elif [ "${status}" == "${FILE_STATUS_EMPTY}" ]; then
			_TT_assert_file_empty "${name}" "${exec_file}"
		elif [ "${status}" == "${FILE_STATUS_HERE}" ]; then
			_TT_assert_file_content "${name}" "${expected_file}" "${exec_file}"
		elif [ "${status}" == "${FILE_STATUS_FILE}" ]; then
			_TT_assert_same_files "${name}" "${expected_file}" "${exec_file}"
		else
			_TT_test_error_exit 5 "Illegal state; invalid status '${status}' for ${name}."
		fi
	}
	_TT_exec_check_output_file "execution stdout" "${stdout_status}" "${stdout_file}" "${exec_stdout}"
	_TT_exec_check_output_file "execution stderr" "${stderr_status}" "${stderr_file}" "${exec_stderr}"

	source "${exec_variables}"
	local probed_var_name
	for probed_var_name in ${probed_variables[@]+"${probed_variables[@]}"}; do
		local var_expected_status_varname
		var_expected_status_varname="$(get_probed_variable_status_varname "${probed_var_name}")"
		local var_expected_status="${!var_expected_status_varname}"
		local var_actual_value_varname
		var_actual_value_varname="$(get_probed_variable_actual_value_varname "${probed_var_name}")"

		if [ "${var_expected_status}" == "${PROBED_VAR_STATUS_UNSET}" ]; then
			_TT_variable_not_exists "${var_actual_value_varname}" ||
				_TT_test_failure "Variable '${probed_var_name}' should not have been defined."
		else
			_TT_variable_exists "${var_actual_value_varname}" ||
				_TT_test_failure "Variable '${probed_var_name}' should have been defined."
			local var_expected_value_varname
			var_expected_value_varname="$(get_probed_variable_expected_value_varname "${probed_var_name}")"
			if [ "${var_expected_status}" == "${PROBED_VAR_STATUS_STRING}" ]; then
				_TT_assert_equal_variable "probed variable '${probed_var_name}'" "${var_expected_value_varname}" "${var_actual_value_varname}"
			elif [ "${var_expected_status}" == "${PROBED_VAR_STATUS_ARRAY}" ]; then
				_TT_assert_equal_array "probed variable '${probed_var_name}'" "${var_expected_value_varname}" "${var_actual_value_varname}"
			else
				_TT_test_error_exit 5 "Illegal state; invalid status '${var_expected_status}' for probed variable '${probed_var_name}'."
			fi
		fi
	done

	local probed_file_name
	local probed_file_expected_status
	local probed_file_expected_value
	local probed_file_absolute_path
	local probed_file_title
	function expect_probed_file_to_be_ordinary_file {
		[ -f "${probed_file_absolute_path}" ] ||
			_TT_test_failure "Expected ${probed_file_title} as an ordinary file."
	}
	function expect_probed_file_to_be_directory {
		[ -d "${probed_file_absolute_path}" ] ||
			_TT_test_failure "Expected ${probed_file_title} as a directory."
	}
	local probed_file_index
	for probed_file_index in "${!probed_files[@]}"; do
		probed_file_name="${probed_files[${probed_file_index}]}"
		probed_file_expected_status="${probed_files_status[${probed_file_index}]}"
		probed_file_expected_value="${probed_files_expected_value[${probed_file_index}]}"
		probed_file_absolute_path="$(_TT_absolute_stage_path "${probed_file_name}")"
		probed_file_title="probed file '${probed_file_name}'"
		case "${probed_file_expected_status}" in
			"${PROBED_FILE_STATUS_NONEXISTING}")
				[ ! -e "${probed_file_absolute_path}" ] ||
					_TT_test_failure "Expected ${probed_file_title} to be nonexisting."
				;;
			"${PROBED_FILE_STATUS_EMPTY_FILE}")
				expect_probed_file_to_be_ordinary_file
				_TT_assert_file_empty "${probed_file_title}" "${probed_file_absolute_path}"
				;;
			"${PROBED_FILE_STATUS_EMPTY_DIR}")
				expect_probed_file_to_be_directory
				_TT_is_directory_empty "${probed_file_absolute_path}" ||
					_TT_test_failure "Expected ${probed_file_title} to be an empty directory, actual: '${probed_file_absolute_path}'."
				;;
			"${PROBED_FILE_STATUS_HERE}")
				expect_probed_file_to_be_ordinary_file
				_TT_assert_file_content "${probed_file_title}" "${probed_file_expected_value}" "${probed_file_absolute_path}"
				;;
			"${PROBED_FILE_STATUS_FILE}")
				if [ -f "${probed_file_expected_value}" ]; then
					expect_probed_file_to_be_ordinary_file
					_TT_assert_same_files "${probed_file_title}" "${probed_file_expected_value}" "${probed_file_absolute_path}"
				elif [ -d "${probed_file_expected_value}" ]; then
					expect_probed_file_to_be_directory
					_TT_assert_same_directories "${probed_file_title}" "${probed_file_expected_value}" "${probed_file_absolute_path}"
				else
					_TT_test_error_exit 13 "Unknown file type: '${probed_file_expected_value}'"
				fi
				;;
			*)
				_TT_test_error_exit 5 "Illegal state; invalid probed file status '${probed_file_expected_status}' for '${probed_file_name}'."
				;;
		esac
	done

	pop_test_context
	) || return $?
}



CAPTURED_DATA_DIR_NAME="captured-data"
CAPTURED_SCRIPTS_FILE_NAME="captured-tests.sh"

function run_captured_tests {
	bash -euo pipefail "${CAPTURED_SCRIPTS_FILE_NAME}"
}

function begin_capturing {
	__capture_stdout_backup_fd__="$(_TT_next_free_fd)" ||
		_TT_test_error_exit 5 "Could not open '${CAPTURED_SCRIPTS_FILE_NAME}'."
	_TT_recreate_dir "${CAPTURED_DATA_DIR_NAME}"
	local -r capture_script_file="$(basename "$0")"
	cat > "${CAPTURED_DATA_DIR_NAME}/README.md" <<EOF
Do not edit this directory manually. It is automatically generated.
Edit '${capture_script_file}' instead.
EOF
	# Save stdout in #${__capture_stdout_backup_fd__}, as a backup.
	eval "exec ${__capture_stdout_backup_fd__}>&1"
	# Replace stdout with file "${CAPTURED_SCRIPTS_FILE_NAME}"
	exec 1> "${CAPTURED_SCRIPTS_FILE_NAME}"
	cat <<EOF
# Do not edit this file manually. It is automatically generated.
# Edit '${capture_script_file}' instead.

EOF
}

function end_capturing {
	# Restore stdout and close file descriptor #${__capture_stdout_backup_fd__}.
	eval "exec 1>&${__capture_stdout_backup_fd__} ${__capture_stdout_backup_fd__}>&-"
}


function capture_run {
	local -ra args=("$@")
	local -a escaped_args=()
	local arg
	for arg in ${args[@]+"${args[@]}"}; do
		escaped_args+=("$(_TT_escape_arg_if_needed "${arg}")")
	done
	echo ${escaped_args[@]+"${escaped_args[@]}"}
	${args[@]+"${args[@]}"}
}


function capture_exec {
	(
	push_test_context "capture_exec $(_TT_array_to_str_args "$@")"
	local -r test_capture_key="$1"; shift

	local -r captured_data_dir="${CAPTURED_DATA_DIR_NAME}"
	local -r captured_tests_file="${captured_data_dir}/captured-tests.txt"
	if [ -f "${captured_tests_file}" ] && grep -q "^${test_capture_key}$" "${captured_tests_file}"; then
		_TT_test_error_exit 3 "Captured data for '${test_capture_key}' already exists."
	fi
	echo "${test_capture_key}" >> "${captured_tests_file}"

	local -ra args=("$@")

	local -r is_capture_mode="true"
	local WD_STATUS_UNSPECIFIED
	local WD_STATUS_GIVEN
	local working_directory_status
	local working_directory
	local FILE_STATUS_UNSPECIFIED
	local FILE_STATUS_FILE
	local FILE_STATUS_HERE
	local FILE_STATUS_EMPTY
	local FILE_STATUS_IGNORE
	local stdin_status
	local stdin_file
	local RETURN_STATUS_UNSPECIFIED
	local RETURN_STATUS_FIXED
	local RETURN_STATUS_NONZERO
	local RETURN_STATUS_IGNORE
	local return_code_status
	local expected_return_code
	local make_command_path_absolute
	local stdout_status
	local stdout_file
	local stderr_status
	local stderr_file
	local PROBED_VAR_STATUS_CAPTURE
	local PROBED_VAR_STATUS_UNSET
	local PROBED_VAR_STATUS_STRING
	local PROBED_VAR_STATUS_ARRAY
	local probed_variables
	local probed_variable_capture_arg_indices
	local PROBED_FILE_STATUS_UNSPECIFIED
	local PROBED_FILE_STATUS_CAPTURE
	local PROBED_FILE_STATUS_NONEXISTING
	local PROBED_FILE_STATUS_EMPTY_FILE
	local PROBED_FILE_STATUS_EMPTY_DIR
	local PROBED_FILE_STATUS_FILE
	local PROBED_FILE_STATUS_HERE
	local probed_files
	local probed_files_status
	local probed_files_expected_value
	local probed_file_capture_arg_indices
	local command_name
	local shifts
	_TT_exec_parse_options ${args[@]+"${args[@]}"}

	local exec_stdin
	local exec_stdout
	local exec_stderr
	local exec_variables
	local exec_return_code
	_TT_exec_run_command "${args[@]:${shifts}}"

	local -r data_dir="${captured_data_dir}/${test_capture_key}"
	local -r data_temp_dir="${captured_data_dir}/${test_capture_key}.tmp"
	mkdir -p "${data_temp_dir}"

	function _TT_make_here_file_arguments_if_possible {
		# Converts the contents of a file to a list of arguments if it is not too large.
		# Examples ("content" --> "flag-suffix" "args"...):
		# "abc\n" --> "h" "abc"
		# "abc" --> "H" "abc"
		# "abc\ndef\n" --> "h2" "abc" "def"
		local -r file_path="$1"; shift
		local -r flag_suffix_varname="$1"; shift
		local -r here_file_arguments_varname="$1"; shift
		local -r bytes_limit=100
		local -r lines_limit=9
		local file_bytes_count
		file_bytes_count="$(head -c $((bytes_limit+2)) "${file_path}" | wc -c)"
		readonly file_bytes_count
		local file_lines_count
		file_lines_count="$(head -n $((lines_limit+2)) "${file_path}" | wc -l)"
		readonly file_lines_count
		[ "${file_bytes_count}" -le "${bytes_limit}" -a "${file_lines_count}" -le "${lines_limit}" ] ||
			return 0
		local file_content
		_TT_read_file_exactly "file_content" "${file_path}"
		local -r file_content_len="${#file_content}"
		local -r last_index="$((file_content_len-1))"
		local _TT_f_flag_suffix
		if [ "${file_content:${last_index}}" == "${_TT_NEW_LINE}" ]; then
			_TT_f_flag_suffix="h"
			file_content="${file_content:0:${last_index}}"
		else
			_TT_f_flag_suffix="H"
		fi
		local -a lines=()
		while IFS= read -r; do
			lines+=("${REPLY}")
		done <<< "${file_content}"
		local -r num_lines="${#lines[@]}"
		[ "${num_lines}" -le 1 ] ||
			_TT_f_flag_suffix="${_TT_f_flag_suffix}${num_lines}"
		local -a _TT_f_here_file_arguments=()
		local line
		for line in "${lines[@]}"; do
			_TT_f_here_file_arguments+=("$(_TT_escape_arg "${line}")")
		done
		_TT_set_variable "${flag_suffix_varname}" "${_TT_f_flag_suffix}"
		_TT_set_array_variable "${here_file_arguments_varname}" "_TT_f_here_file_arguments"
	}

	local exec_args=("expect_exec")
	source "${exec_variables}"
	local i
	for ((i=0; i<shifts-1; i++)); do
		if _TT_is_in "${i}" ${probed_variable_capture_arg_indices[@]+"${probed_variable_capture_arg_indices[@]}"}; then
			_TT_increment i
			local probed_var_name="${args[${i}]}"
			local var_actual_value_varname
			var_actual_value_varname="$(get_probed_variable_actual_value_varname "${probed_var_name}")"
			if _TT_variable_not_exists "${var_actual_value_varname}"; then
				exec_args+=("-vu" "${probed_var_name}")
			elif _TT_is_variable_array "${var_actual_value_varname}"; then
				local -a probed_array_actual_value
				_TT_set_array_variable "probed_array_actual_value" "${var_actual_value_varname}"
				exec_args+=("-va" "${probed_var_name}" "${#probed_array_actual_value[@]}")
				local probed_array_item probed_array_item_escaped
				for probed_array_item in ${probed_array_actual_value[@]+"${probed_array_actual_value[@]}"}; do
					probed_array_item_escaped="$(_TT_escape_arg "${probed_array_item}")"
					exec_args+=("${probed_array_item_escaped}")
				done
			else
				local probed_variable_actual_value="${!var_actual_value_varname}"
				local probed_variable_actual_value_escaped
				probed_variable_actual_value_escaped="$(_TT_escape_arg "${probed_variable_actual_value}")"
				exec_args+=("-vs" "${probed_var_name}" "${probed_variable_actual_value_escaped}")
			fi
		elif _TT_is_in "${i}" ${probed_file_capture_arg_indices[@]+"${probed_file_capture_arg_indices[@]}"}; then
			_TT_increment i
			local probed_file_name="${args[${i}]}"
			local probed_file_absolute_path
			probed_file_absolute_path="$(_TT_absolute_stage_path "${probed_file_name}")"
			local escaped_probed_file_name
			escaped_probed_file_name="$(_TT_escape_arg "${probed_file_name}")"
			function _TT_handle_pf_status_as_stored_file {
				local probed_file_storage_name
				if [[ "${probed_file_name}" == *"/"* ]]; then
					probed_file_storage_name="${probed_file_name%%/*}_$(basename "${probed_file_name}")"
				else
					probed_file_storage_name="${probed_file_name}"
				fi
				local probed_file_index
				probed_file_index="$(_TT_index_of "${probed_file_name}" "${probed_files[@]}")"
				readonly probed_file_index
				probed_file_storage_name="${probed_file_index}_${probed_file_storage_name}"
				readonly probed_file_storage_name
				local -r probed_files_storage_dir_name="probed_files"
				mkdir -p "${data_temp_dir}/${probed_files_storage_dir_name}"
				cp -R "${probed_file_absolute_path}" "${data_temp_dir}/${probed_files_storage_dir_name}/${probed_file_storage_name}"
				exec_args+=("-f" "${escaped_probed_file_name}" "$(_TT_escape_arg "${data_dir}/${probed_files_storage_dir_name}/${probed_file_storage_name}")")
			}
			if [ ! -e "${probed_file_absolute_path}" ]; then
				exec_args+=("-fu" "${escaped_probed_file_name}")
			elif [ -d "${probed_file_absolute_path}" ]; then
				if _TT_is_directory_empty "${probed_file_absolute_path}"; then
					exec_args+=("-fempty-dir" "${escaped_probed_file_name}")
				else
					_TT_handle_pf_status_as_stored_file
				fi
			elif [ -f "${probed_file_absolute_path}" ]; then
				if _TT_is_file_empty "${probed_file_absolute_path}"; then
					exec_args+=("-fempty" "${escaped_probed_file_name}")
				else
					local flag_suffix here_file_arguments
					unset flag_suffix
					_TT_make_here_file_arguments_if_possible "${probed_file_absolute_path}" "flag_suffix" "here_file_arguments"
					if _TT_variable_exists "flag_suffix"; then
						exec_args+=("-f${flag_suffix}" "${escaped_probed_file_name}" ${here_file_arguments[@]+"${here_file_arguments[@]}"})
					else
						_TT_handle_pf_status_as_stored_file
					fi
				fi
			else
				_TT_test_error_exit 13 "Unknown file type for '${probed_file_name}'; location: '${probed_file_absolute_path}'"
			fi
		else
			exec_args+=("$(_TT_escape_arg_if_needed "${args[${i}]}")")
		fi
	done

	if [ ${#probed_variables[@]} -gt 0 ]; then
		local probed_var_name
		for probed_var_name in ${probed_variables[@]+"${probed_variables[@]}"}; do
			unset "$(get_probed_variable_actual_value_varname "${probed_var_name}")"
		done
	fi

	# Add stdout/stderr expectation if needed
	function _TT_capture_handle_output_file {
		local -r flag="$1"; shift
		local -r name="$1"; shift
		local -r status="$1"; shift
		local -r exec_file="$1"; shift
		[ "${status}" == "${FILE_STATUS_UNSPECIFIED}" ] ||
			return 0
		if _TT_is_file_empty "${exec_file}"; then
			exec_args+=("${flag}empty")
		else
			local flag_suffix here_file_arguments
			unset flag_suffix
			_TT_make_here_file_arguments_if_possible "${exec_file}" "flag_suffix" "here_file_arguments"
			if _TT_variable_exists "flag_suffix"; then
				exec_args+=("${flag}${flag_suffix}" ${here_file_arguments[@]+"${here_file_arguments[@]}"})
			else
				cp "${exec_file}" "${data_temp_dir}/${name}"
				exec_args+=("${flag}" "$(_TT_escape_arg "${data_dir}/${name}")")
			fi
		fi
	}

	_TT_capture_handle_output_file "-o" "stdout" "${stdout_status}" "${exec_stdout}"
	_TT_capture_handle_output_file "-e" "stderr" "${stderr_status}" "${exec_stderr}"

	if _TT_is_directory_empty "${data_temp_dir}"; then
		rm -rf "${data_temp_dir}"
	else
		mv "${data_temp_dir}" "${data_dir}"
	fi

	# Add return code expectation if needed
	if [ "${return_code_status}" == "${RETURN_STATUS_UNSPECIFIED}" ]; then
		[ "${exec_return_code}" -eq 0 ] ||
			exec_args+=("-r" "${exec_return_code}")
	fi

	local temp_arg
	for temp_arg in "${args[@]:$((shifts-1))}"; do
		exec_args+=("$(_TT_escape_arg_if_needed "${temp_arg}")")
	done

	echo "${exec_args[@]}"
	pop_test_context
	) || return $?
}
