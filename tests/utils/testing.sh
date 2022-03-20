
TESTS_DIR="$(absolute_path "${TESTS_DIR}")"
ROOT="$(absolute_path "${TESTS_DIR}/..")"

TEST_SANDBOX="${TESTS_DIR}/sandbox"
TEST_STAGE="${TEST_SANDBOX}/stage"



TEST_CONTEXT=""

function get_test_context {
	local tc
	while read tc; do
		echo -n "> ${tc} "
	done <<< "${TEST_CONTEXT}"
}

function print_test_context {
	get_test_context >&2
	errcho
}

function push_test_context {
	local -r tc="$1"; shift
	[ -z "${TEST_CONTEXT}" ] || TEST_CONTEXT="${TEST_CONTEXT}${NEW_LINE}"
	TEST_CONTEXT="${TEST_CONTEXT}${tc}"
	# errcho "$(get_test_context) ((";
}

function pop_test_context {
	# errcho "$(get_test_context) ))";
	local last_new_line_index=0
	local i
	for ((i=0; i<${#TEST_CONTEXT}; i++)); do
		[ "${TEST_CONTEXT:${i}:1}" != "${NEW_LINE}" ] || last_new_line_index=${i}
	done
	TEST_CONTEXT="${TEST_CONTEXT:0:${last_new_line_index}}"
}



function pushd_test_context {
	pushdq_here
	push_test_context "$@"
}

function pushd_test_context_here {
	pushdq_here
	push_test_context "$(basename ${PWD})"
}

function popd_test_context {
	popdq
	pop_test_context "$@"
}



function error_exit {
	local -r exit_code="$1"; shift
	print_test_context
	errcho "$@"
	exit "${exit_code}"
}


function stage_dir {
	local -r dir="$1"; shift
	check_directory_exists "Staging directory" "${dir}"
	mkdir -p "${TEST_STAGE}" # Making sure parent directories are created.
	rm -rf "${TEST_STAGE}"
	cp -R "${dir}" "${TEST_STAGE}"
	STAGED_DIR="$(absolute_path "${dir}")"
}


function test_failure {
	local -r message="$1"; shift
	errcho "Test failure:"
	print_test_context
	errcho "${message}"
	exit 10
}

function assert_equal {
	local -r name="$1"; shift
	local -r expected="$1"; shift
	local -r actual="$1"; shift
	[ "${expected}" == "${actual}" ] || test_failure "Incorrect value for ${name}, expected: '${expected}', actual: '${actual}'."
}

function assert_file_content {
	local -r name="$1"; shift
	local -r expected_content="$1"; shift
	local -r actual_file_name="$1"; shift
	local actual_file_content
	read_file_exactly "actual_file_content" "${actual_file_name}"
	if [ "${expected_content}" != "${actual_file_content}" ]; then
		test_failure "Incorrect data in ${name} (${actual_file_name}).
============== Expected ==============
${expected_content}======================================
=============== Actual ===============
${actual_file_content}======================================"
	fi
}

function assert_same_files {
	local -r name="$1"; shift
	local -r expected="$1"; shift
	local -r actual="$1"; shift
	local -r diff_file="${TEST_SANDBOX}/latest.diff"
	if ! diff "${expected}" "${actual}" > "${diff_file}" 2>&1; then
		local diff_info
		diff_info="$(truncated_cat "${diff_file}" 20)"
		readonly diff_info
		test_failure "Incorrect data in ${name}, expected: '${expected}', actual: '${actual}'.
${diff_info}"
	fi
}

function assert_file_empty {
	local -r name="$1"; shift
	local -r actual="$1"; shift
	! [ -s "${actual}" ] || test_failure "Expected ${name} to be empty, actual: '${actual}'."
}

function set_exec_cwd {
	EXEC_WORKING_DIRECTORY="$1"
}

function unset_exec_cwd {
	unset EXEC_WORKING_DIRECTORY
}


function __exec__parse_options__ {
	make_command_path_absolute="false"
	readonly WD_STATUS_UNSPECIFIED="unspecified"
	readonly WD_STATUS_GIVEN="given"
	working_directory_status="${WD_STATUS_UNSPECIFIED}"
	readonly IN_STATUS_UNSPECIFIED="unspecified"
	readonly IN_STATUS_FILE="file"
	stdin_status="${IN_STATUS_UNSPECIFIED}"
	readonly OUT_STATUS_UNSPECIFIED="unspecified"
	readonly OUT_STATUS_FILE="file"
	readonly OUT_STATUS_HERE="here"
	readonly OUT_STATUS_EMPTY="empty"
	readonly OUT_STATUS_IGNORE="ignore"
	stdout_status="${OUT_STATUS_UNSPECIFIED}"
	stdout_file=""
	stderr_status="${OUT_STATUS_UNSPECIFIED}"
	stderr_file=""
	readonly RETURN_STATUS_UNSPECIFIED="unspecified"
	readonly RETURN_STATUS_FIXED="fixed"
	readonly RETURN_STATUS_NONZERO="nonzero"
	readonly RETURN_STATUS_IGNORE="ignore"
	return_code_status="${RETURN_STATUS_UNSPECIFIED}"

	shifts=0

	local arg_shifts
	function read_file_status_args {
		local -r option_flag="$1"; shift
		local -r status_varname="$1"; shift
		local -r file_varname="$1"; shift

		local -r option_suffix="${option_flag:2}"
		arg_shifts=0
		case "${option_suffix}" in
			"")
				local -r file_value="$1"; shift; increment arg_shifts
				set_variable "${status_varname}" "${OUT_STATUS_FILE}"
				set_variable "${file_varname}" "${file_value}"
				;;
			h*|H*)
				local -r option_suffix_char="${option_suffix:0:1}"
				if [ -n "${option_suffix:1}" ]; then
					local -r num_lines="${option_suffix:1}"
					is_nonnegative_integer "${num_lines}" || error_exit 2 "Undefined option '${option_flag}'."
				else
					local -r num_lines=1
				fi
				[ $# -ge "${num_lines}" ] || error_exit 2 "Insufficient number of arguments after '${option_flag}'."
				local file_value
				local i line
				for ((i=0; i<num_lines; i++)); do
					line="$1"; shift; increment arg_shifts
					[ "${i}" -eq 0 ] || file_value="${file_value}${NEW_LINE}"
					file_value="${file_value}${line}"
				done
				[ "${option_suffix_char}" != "h" ] || file_value="${file_value}${NEW_LINE}"
				set_variable "${status_varname}" "${OUT_STATUS_HERE}"
				set_variable "${file_varname}" "${file_value}"
				;;
			empty)
				set_variable "${status_varname}" "${OUT_STATUS_EMPTY}"
				;;
			ignore)
				set_variable "${status_varname}" "${OUT_STATUS_IGNORE}"
				;;
			*)
				error_exit 2 "Undefined option '${option_flag}'."
				;;
		esac
	}

	while [ $# -gt 0 ] && str_starts_with "$1" "-"; do
		local option="$1"; shift; increment shifts
		case "${option}" in
			-d)
				working_directory_status="${WD_STATUS_GIVEN}"
				working_directory="$1"; shift; increment shifts
				;;
			-i)
				stdin_status="${IN_STATUS_FILE}"
				stdin_file="$1"; shift; increment shifts
				;;
			-o*)
				read_file_status_args "${option}" stdout_status stdout_file "$@"
				shift "${arg_shifts}"; increment shifts "${arg_shifts}"
				;;
			-e*)
				read_file_status_args "${option}" stderr_status stderr_file "$@"
				shift "${arg_shifts}"; increment shifts "${arg_shifts}"
				;;
			-r)
				return_code_status="${RETURN_STATUS_FIXED}"
				expected_return_code="$1"; shift; increment shifts
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
				error_exit 2 "Undefined option '${option}'."
				;;
		esac
	done

	[ $# -gt 0 ] || error_exit 2 "Command is not given."
	readonly command_name="$1"; shift; increment shifts
}

function __exec__run_command__ {
	if [ "${working_directory_status}" == "${WD_STATUS_UNSPECIFIED}" ]; then
		if variable_exists "EXEC_WORKING_DIRECTORY"; then
			working_directory="${EXEC_WORKING_DIRECTORY}"
		else
			working_directory="."
		fi
	fi

	if str_starts_with "${working_directory}" "/"; then
		local -r abs_working_directory="${working_directory}"
		check_directory_exists "Working directory" "${abs_working_directory}"
	else
		local -r abs_working_directory="${TEST_STAGE}/${working_directory}"
		check_directory_exists "Staged working directory" "${abs_working_directory}"
	fi

	mkdir -p "${TEST_SANDBOX}"

	[ "${stdin_status}" != "${IN_STATUS_UNSPECIFIED}" ] || stdin_file="/dev/null"
	readonly exec_stdout="${TEST_SANDBOX}/exec.out"
	readonly exec_stderr="${TEST_SANDBOX}/exec.err"

	local exec_abs_stdin
	exec_abs_stdin="$(absolute_path "${stdin_file}")"
	readonly exec_abs_stdin
	local exec_abs_stdout
	exec_abs_stdout="$(absolute_path "${exec_stdout}")"
	readonly exec_abs_stdout
	local exec_abs_stderr
	exec_abs_stderr="$(absolute_path "${exec_stderr}")"
	readonly exec_abs_stderr

	if str_ends_with "${command_name}" ".sh" || str_ends_with "${command_name}" ".py"; then
		make_command_path_absolute="true"
	fi

	if "${make_command_path_absolute}"; then
		local abs_command
		abs_command="$(absolute_path "${command_name}")"
		readonly abs_command
	else
		local -r abs_command="${command_name}"
	fi

	if str_ends_with "${abs_command}" ".sh"; then
		local -ra command_array=("bash" "${abs_command}")
	elif str_ends_with "${abs_command}" ".py"; then
		local _test_py_cmd
		function _test_check_py_cmd {
			local -r CMD="$1"; shift
			command_exists "${CMD}" || return 1
			_test_py_cmd="${CMD}"
			return 0
		}
		if variable_exists "PYTHON" ; then
			_test_check_py_cmd "${PYTHON}" || error_exit 3 "Python command '${PYTHON}' does not exist."
		else
			if ! _test_check_py_cmd "python3" ; then
				_test_check_py_cmd "python" || error_exit 3 "Neither of python commands 'python3' nor 'python' exists."
			fi
		fi
		local -ra command_array=("${_test_py_cmd}" "${abs_command}")
	else
		local -ra command_array=("${abs_command}")
	fi

	pushdq "${abs_working_directory}"
	exec_return_code=0
	"${command_array[@]}" "$@" < "${exec_abs_stdin}" > "${exec_abs_stdout}" 2>"${exec_abs_stderr}" || exec_return_code=$?
	popdq
}

function expect_exec {
	push_test_context "expect_exec $(array_to_str_args "$@")"

	local WD_STATUS_UNSPECIFIED
	local WD_STATUS_GIVEN
	local working_directory_status
	local working_directory
	local IN_STATUS_UNSPECIFIED
	local IN_STATUS_FILE
	local stdin_status
	local stdin_file
	local RETURN_STATUS_UNSPECIFIED
	local RETURN_STATUS_FIXED
	local RETURN_STATUS_NONZERO
	local RETURN_STATUS_IGNORE
	local return_code_status
	local expected_return_code
	local make_command_path_absolute
	local OUT_STATUS_UNSPECIFIED
	local OUT_STATUS_FILE
	local OUT_STATUS_HERE
	local OUT_STATUS_EMPTY
	local OUT_STATUS_IGNORE
	local stdout_status
	local stdout_file
	local stderr_status
	local stderr_file
	local command_name
	local shifts
	__exec__parse_options__ "$@"
	shift ${shifts}

	[ "${stdout_status}" != "${OUT_STATUS_UNSPECIFIED}" ] || error_exit 2 "Status of stdout is not specified."
	[ "${stderr_status}" != "${OUT_STATUS_UNSPECIFIED}" ] || error_exit 2 "Status of stderr is not specified."

	local exec_stdout
	local exec_stderr
	local exec_return_code
	__exec__run_command__ "$@"

	if [ "${return_code_status}" == "${RETURN_STATUS_IGNORE}" ]; then
		: Do nothing
	elif [ "${return_code_status}" == "${RETURN_STATUS_UNSPECIFIED}" ]; then
		assert_equal "execution return code" "0" "${exec_return_code}"
	elif [ "${return_code_status}" == "${RETURN_STATUS_FIXED}" ]; then
		assert_equal "execution return code" "${expected_return_code}" "${exec_return_code}"
	elif [ "${return_code_status}" == "${RETURN_STATUS_NONZERO}" ]; then
		[ "${exec_return_code}" -ne 0 ] || test_failure "Execution return code is zero, while expected to be nonzero."
	else
		error_exit 5 "Illegal state; invalid return code status '${return_code_status}'."
	fi

	function check_file {
		local -r name="$1"; shift
		local -r status="$1"; shift
		local -r expected_file="$1"; shift
		local -r exec_file="$1"; shift
		if [ "${status}" == "${OUT_STATUS_IGNORE}" ]; then
			: Do nothing
		elif [ "${status}" == "${OUT_STATUS_EMPTY}" ]; then
			assert_file_empty "${name}" "${exec_file}"
		elif [ "${status}" == "${OUT_STATUS_HERE}" ]; then
			assert_file_content "${name}" "${expected_file}" "${exec_file}"
		elif [ "${status}" == "${OUT_STATUS_FILE}" ]; then
			assert_same_files "${name}" "${expected_file}" "${exec_file}"
		else
			error_exit 5 "Illegal state; invalid status '${status}' for ${name}."
		fi
	}
	check_file "execution stdout" "${stdout_status}" "${stdout_file}" "${exec_stdout}"
	check_file "execution stderr" "${stderr_status}" "${stderr_file}" "${exec_stderr}"

	pop_test_context
}



function eval_value {
	local -r arg="$1"; shift
	eval echo "${arg}"
}

function eval_args_array {
	evaluated_args=()
	while [ $# -gt 0 ]; do
		local arg="$1"; shift
		evaluated_args+=("$(eval_value "${arg}")")
	done
}


CAPTURED_DATA_DIR_NAME="captured-data"
CAPTURED_SCRIPTS_FILE_NAME="captured-tests.sh"

function run_captured_tests {
	bash "${CAPTURED_SCRIPTS_FILE_NAME}"
}

function begin_capturing {
	__capture_stdout_backup_fd__=$(next_free_fd) || error_exit 5 "Could not open '${CAPTURED_SCRIPTS_FILE_NAME}'."
	recreate_dir "${CAPTURED_DATA_DIR_NAME}"
	local -r readme_file=
	cat > "${CAPTURED_DATA_DIR_NAME}/README.md" <<EOF
Do not edit this directory manually. It is automatically generated.
Edit '$(basename "$0")' instead.
EOF
	# Save stdout in #${__capture_stdout_backup_fd__}, as a backup.
	eval "exec ${__capture_stdout_backup_fd__}>&1"
	# Replace stdout with file "${CAPTURED_SCRIPTS_FILE_NAME}"
	exec 1> "${CAPTURED_SCRIPTS_FILE_NAME}"
	cat <<EOF
# Do not edit this file manually. It is automatically generated.
# Edit '$(basename "$0")' instead.

EOF
}

function end_capturing {
	# Restore stdout and close file descriptor #${__capture_stdout_backup_fd__}.
	eval "exec 1>&${__capture_stdout_backup_fd__} ${__capture_stdout_backup_fd__}>&-"
}


function capture_run {
	echo "$@"
	local -a evaluated_args
	eval_args_array "$@"
	${evaluated_args[@]+"${evaluated_args[@]}"}
}


function capture_exec {
	push_test_context "capture_exec $(array_to_str_args "$@")"
	local -r key="$1"; shift

	local -r captured_data_dir="${CAPTURED_DATA_DIR_NAME}"
	local -r captured_tests_file="${captured_data_dir}/captured-tests.txt"
	if [ -f "${captured_tests_file}" ] && grep -q "^${key}$" "${captured_tests_file}"; then
		error_exit 3 "Captured data for '${key}' already exists."
	fi
	echo "${key}" >> "${captured_tests_file}"

	local -ra raw_args=("$@")
	local -a evaluated_args
	eval_args_array "$@"

	local WD_STATUS_UNSPECIFIED
	local WD_STATUS_GIVEN
	local working_directory_status
	local working_directory
	local IN_STATUS_UNSPECIFIED
	local IN_STATUS_FILE
	local stdin_status
	local stdin_file
	local RETURN_STATUS_UNSPECIFIED
	local RETURN_STATUS_FIXED
	local RETURN_STATUS_NONZERO
	local RETURN_STATUS_IGNORE
	local return_code_status
	local expected_return_code
	local make_command_path_absolute
	local OUT_STATUS_UNSPECIFIED
	local OUT_STATUS_FILE
	local OUT_STATUS_HERE
	local OUT_STATUS_EMPTY
	local OUT_STATUS_IGNORE
	local stdout_status
	local stdout_file
	local stderr_status
	local stderr_file
	local command_name
	local shifts
	__exec__parse_options__ ${evaluated_args[@]+"${evaluated_args[@]}"}

	local exec_stdout
	local exec_stderr
	local exec_return_code
	__exec__run_command__ "${evaluated_args[@]:${shifts}}"

	local exec_args=("expect_exec" "${raw_args[@]:0:$((shifts-1))}")

	# Add stdout/stderr expectation if needed
	local -r data_dir="${captured_data_dir}/${key}"
	local -r data_temp_dir="${captured_data_dir}/${key}.tmp"
	mkdir -p "${data_temp_dir}"

	function handle_file {
		local -r flag="$1"; shift
		local -r name="$1"; shift
		local -r status="$1"; shift
		local -r exec_file="$1"; shift
		[ "${status}" == "${OUT_STATUS_UNSPECIFIED}" ] || return 0
		if [ -s "${exec_file}" ]; then
			local -r bytes_limit=100
			local -r lines_limit=9
			local exec_file_bytes
			exec_file_bytes="$(head -c $((bytes_limit+2)) "${exec_file}" | wc -c)"
			readonly exec_file_bytes
			local exec_file_lines
			exec_file_lines="$(head -n $((lines_limit+2)) "${exec_file}" | wc -l)"
			readonly exec_file_lines
			if [ "${exec_file_bytes}" -gt "${bytes_limit}" ] || [ "${exec_file_lines}" -gt "${lines_limit}" ] ; then
				cp "${exec_file}" "${data_temp_dir}/${name}"
				exec_args+=("${flag}" "$(escape_arg "${data_dir}/${name}")")
			else
				local exec_content
				read_file_exactly exec_content "${exec_file}"
				local -r exec_content_len="${#exec_content}"
				local -r last_index="$((exec_content_len-1))"
				if [ "${exec_content: ${last_index}}" == "${NEW_LINE}" ]; then
					local flag_suffix="h"
					exec_content="${exec_content:0: ${last_index}}"
				else
					local flag_suffix="H"
				fi
				local -a lines=()
				while IFS= read -r; do
					lines+=("$REPLY")
				done <<< "${exec_content}"
				local -r num_lines="${#lines[@]}"
				[ "${num_lines}" -le 1 ] || flag_suffix="${flag_suffix}${num_lines}"
				exec_args+=("${flag}${flag_suffix}")
				local line
				for line in "${lines[@]}"; do
					exec_args+=("$(escape_arg "${line}")")
				done
			fi
		else
			exec_args+=("${flag}empty")
		fi
	}

	handle_file "-o" "stdout" "${stdout_status}" "${exec_stdout}"
	handle_file "-e" "stderr" "${stderr_status}" "${exec_stderr}"

	if [ -z "$(ls -A "${data_temp_dir}")" ]; then
		rm -rf "${data_temp_dir}"
	else
		mv "${data_temp_dir}" "${data_dir}"
	fi

	# Add return code expectation if needed
	if [ "${return_code_status}" == "${RETURN_STATUS_UNSPECIFIED}" ]; then
		[ "${exec_return_code}" -eq 0 ] || exec_args+=("-r" "${exec_return_code}")
	fi

	exec_args+=("${raw_args[@]:$((shifts-1))}")
	echo "${exec_args[@]}"
	pop_test_context
}
