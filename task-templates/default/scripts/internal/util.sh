#!/bin/bash

function errcho {
	>&2 echo "$@"
}

function print_exit_code {
	local ret=0
	"$@" || ret=$?
	echo "${ret}"
}

function extension {
	local -r file="$1"; shift
	echo "${file##*.}"
}

function variable_exists {
	local -r varname="$1"; shift
	declare -p "${varname}" &> "/dev/null"
}

function variable_not_exists {
	local -r varname="$1"; shift
	! variable_exists "${varname}"
}

function check_variable {
	local -r varname="$1"; shift
	if variable_not_exists "${varname}" ; then
		errcho "Error: Variable '${varname}' is not set."
		exit 1
	fi
}

function set_variable {
	local -r var_name="$1"; shift
	local -r var_value="$1"; shift
	printf -v "${var_name}" '%s' "${var_value}"
}

function increment {
	# Calling ((v++)) causes unexpected exit in some versions of bash if used with 'set -e'.
	# Usage:
	# v=3
	# increment v
	# increment v 2
	local -r var_name="$1"; shift
	if [ $# -gt 0 ]; then
		local -r c="$1"; shift
	else
		local -r c=1
	fi
	set_variable "${var_name}" "$((${var_name}+c))"
}

function decrement {
	# Similar to increment
	local -r var_name="$1"; shift
	if [ $# -gt 0 ]; then
		local -r c="$1"; shift
	else
		local -r c=1
	fi
	set_variable "${var_name}" "$((${var_name}-c))"
}


function py_test {
	# Similar to Bash "test" command, but with a pythonic expression.
	# Ends with zero exit code iff the expression evaluates to True.
	# Usage: py_test "...pythonic-expression..."
	# Usage example: if py_test "$a < $b"; then ...
	local -r expr="$1"; shift
	"${PYTHON}" -c "import sys; sys.exit(0 if (${expr}) else 1)"
}


function pushdq {
	pushd "$@" > "/dev/null"
}

function popdq {
	popd "$@" > "/dev/null"
}


function is_identifier_format {
	local -r text="$1"; shift
	local -r pattern='^[a-zA-Z_][a-zA-Z0-9_]*$'
	[[ "${text}" =~ ${pattern} ]]
}

function is_unsigned_integer_format {
	local -r text="$1"; shift
	local -r pattern='^[0-9]+$'
	[[ "${text}" =~ ${pattern} ]]
}

function is_signed_integer_format {
	local -r text="$1"; shift
	local -r pattern='^[+-]?[0-9]+$'
	[[ "${text}" =~ ${pattern} ]]
}

function is_unsigned_decimal_format {
	local -r text="$1"; shift
	local -r pattern='^([0-9]+\.?[0-9]*|\.[0-9]+)$'
	[[ "${text}" =~ ${pattern} ]]
}

function is_signed_decimal_format {
	local -r text="$1"; shift
	local -r pattern='^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)$'
	[[ "${text}" =~ ${pattern} ]]
}


function are_same {
	diff "$1" "$2" &> "/dev/null"
}

function recreate_dir {
	local -r dir="$1"; shift
	mkdir -p "${dir}"
	local file
	ls -A1 "${dir}" | while read file; do
		[ -z "${file}" ] && continue
		rm -rf "${dir}/${file}"
	done
}


function get_sort_command {
	which -a "sort" | grep -iv "windows" | sed -n 1p
}

function _sort {
	local sort_command
	sort_command="$(get_sort_command)"
	readonly sort_command
	if [ -n "${sort_command}" ] ; then
		"${sort_command}" "$@"
	else
		cat "$@"
	fi
}

function unified_sort {
	local sort_command
	sort_command="$(get_sort_command)"
	readonly sort_command
	if [ -n "${sort_command}" ] ; then
		"${sort_command}" -u "$@"
	else
		cat "$@"
	fi
}


function sensitive {
	"$@"
	local ret=$?
	if [ "${ret}" -ne 0 ]; then
		exit ${ret}
	fi
}

function is_windows {
	if variable_not_exists "OS" ; then
		return 1
	fi
	grep -iq "windows" <<< "${OS}"
}

function is_web {
	if variable_not_exists "WEB_TERMINAL" ; then
		return 1
	fi
	[ "${WEB_TERMINAL}" == "true" ]
}


#'echo's with the given color
#examples:
# cecho green this is a text
# cecho warn this is a text with semantic color 'warn'
# cecho red -n this is a text with no new line

function cecho {
	local -r color="$1"; shift
	echo "$@" | "${PYTHON}" "${INTERNALS}/colored_cat.py" "${color}"
}

#colored errcho
function cerrcho {
	>&2 cecho "$@"
}


function boxed_echo {
	local -r color="$1"; shift
	local -r text="$1"; shift

	echo -n "["
	cecho "${color}" -n "${text}"
	echo -n "]"

	if variable_exists "BOX_PADDING" ; then
		local pad
		pad="$((BOX_PADDING - ${#text}))"
		readonly pad
		hspace "${pad}"
	fi
}

function echo_status {
	local -r status="$1"; shift

	local color
	case "${status}" in
		OK) color="ok" ;;
		FAIL) color="fail" ;;
		WARN) color="warn" ;;
		SKIP) color="skipped" ;;
		*) color="other" ;;
	esac

	boxed_echo "${color}" "${status}"
}

function echo_verdict {
	local -r verdict="$1"; shift

	local color
	case "${verdict}" in
		Correct) color="ok" ;;
		Partial*) color="warn" ;;
		Wrong*|Runtime*) color="error" ;;
		Time*) color="blue" ;;
		Unknown) color="ignored" ;;
		*) color="other" ;;
	esac

	boxed_echo "${color}" "${verdict}"
}


function has_warnings {
	local -r job="$1"; shift
	local WARN_FILE="${LOGS_DIR}/${job}.warn"
	[ -s "${WARN_FILE}" ]
}

readonly skip_status=1000
readonly abort_status=1001
readonly warn_status=250

function job_ret {
	local -r job="$1"; shift

	local ret_file="${LOGS_DIR}/${job}.ret"
	if [ -f "${ret_file}" ]; then
		cat "${ret_file}"
	else
		echo "${skip_status}"
	fi
}

function is_warning_sensitive {
	variable_exists "WARNING_SENSITIVE_RUN" && "${WARNING_SENSITIVE_RUN}"
}

function has_sensitive_warnings {
	local -r job="$1"; shift
	is_warning_sensitive && has_warnings "${job}"
}

function warning_aware_job_ret {
	local -r job="$1"; shift

	local ret
	ret="$(job_ret "${job}")"
	readonly ret
	if [ "${ret}" -ne "0" ]; then
		echo "${ret}"
	elif has_sensitive_warnings "${job}"; then
		echo "${warn_status}"
	else
		echo "0"
	fi
}


# Deprecation warning:
# Use function 'is_unsigned_decimal_format' instead.
# Keeping this function for backward compatibility.
function check_float {
	is_unsigned_decimal_format "$1"
}


function job_tlog_file {
	local -r job="$1"; shift
	echo "${LOGS_DIR}/${job}.tlog"
}

function job_tlog {
	local -r job="$1"; shift
	local -r key="$1"; shift

	local tlog_file
	tlog_file="$(job_tlog_file "${job}")"
	readonly tlog_file
	if [ -f "${tlog_file}" ]; then
		local line
		local ret=0
		line="$(grep "^${key} " "${tlog_file}")" || ret=$?
		readonly line
		if [ ${ret} -ne 0 ]; then
			errcho "tlog file '${tlog_file}' does not contain key '${key}'"
			exit 1
		fi
		cut -d' ' -f2- <<< "${line}"
	else
		errcho "tlog file '${tlog_file}' is not created"
		exit 1
	fi
}

function job_status {
	local -r job="$1"; shift

	local ret
	ret="$(job_ret "${job}")"
	readonly ret

	if [ "${ret}" -eq "0" ]; then
		if has_warnings "${job}"; then
			echo "WARN"
		else
			echo "OK"
		fi
	elif [ "${ret}" -eq "${skip_status}" ]; then
		echo "SKIP"
	else
		echo "FAIL"
	fi
}

function guard {
	local -r job="$1"; shift

	local -r outlog="${LOGS_DIR}/${job}.out"
	local -r errlog="${LOGS_DIR}/${job}.err"
	local -r retlog="${LOGS_DIR}/${job}.ret"
	export WARN_FILE="${LOGS_DIR}/${job}.warn"

	echo "${abort_status}" > "${retlog}"

	local ret=0
	"$@" > "${outlog}" 2> "${errlog}" || ret=$?
	echo "${ret}" > "${retlog}"

	return "${ret}"
}

function insensitive {
	"$@" || true
}

function boxed_guard {
	local -r job="$1"; shift

	insensitive guard "${job}" "$@"
	echo_status "$(job_status "${job}")"
}

function execution_report {
	local -r job="$1"; shift

	cecho yellow -n "exit-code: "
	echo "$(job_ret "${job}")"
	if has_warnings "${job}"; then
		cecho yellow "warnings:"
		cat "${LOGS_DIR}/${job}.warn"
	fi
	cecho yellow "stdout:"
	cat "${LOGS_DIR}/${job}.out"
	cecho yellow "stderr:"
	cat "${LOGS_DIR}/${job}.err"
}

function reporting_guard {
	local -r job="$1"; shift

	boxed_guard "${job}" "$@"

	local ret
	ret="$(warning_aware_job_ret "${job}")"
	readonly ret

	if [ "${ret}" -ne "0" ]; then
		echo
		execution_report "${job}"
	fi

	return ${ret}
}


function initialize_failed_job_list {
	failed_jobs_final_ret=0
	failed_jobs_list=""
}

function add_failed_job {
	local -r job_name="$1"; shift
	local -r ret="$1"; shift
	failed_jobs_final_ret="${ret}"
	failed_jobs_list="${failed_jobs_list} ${job_name}"
}

function verify_job_failure {
	local -r job_name="$1"; shift
	local ret
	ret="$(warning_aware_job_ret "${job_name}")"
	is_in "${ret}" "0" "${skip_status}" ||
		add_failed_job "${job_name}" "${ret}"
}

function should_stop_for_failed_jobs {
	"${SENSITIVE_RUN}" && [ "${failed_jobs_final_ret}" -ne "0" ]
}

function stop_for_failed_jobs {
	local job
	for job in ${failed_jobs_list}; do
		echo
		cecho "fail" -n "failed job:"
		echo " ${job}"
		execution_report "${job}"
	done
	exit "${failed_jobs_final_ret}"
}


readonly WARNING_TEXT_PATTERN_FOR_CPP="warning:"
readonly WARNING_TEXT_PATTERN_FOR_PAS="Warning:"
readonly WARNING_TEXT_PATTERN_FOR_JAVA="warning:"


MAKEFILE_COMPILE_OUTPUTS_LIST_TARGET="compile_outputs_list"

function makefile_compile_outputs_list {
	local -r makefile_dir="$1"; shift
	make --quiet -C "${makefile_dir}" "${MAKEFILE_COMPILE_OUTPUTS_LIST_TARGET}"
}

function build_with_make {
	local -r makefile_dir="$1"; shift

	make -j4 -C "${makefile_dir}" || return $?

	if variable_exists "WARN_FILE"; then
		local compile_outputs_list
		if compile_outputs_list="$(makefile_compile_outputs_list "${makefile_dir}")"; then
			local compile_output
			for compile_output in ${compile_outputs_list}; do
				if [[ "${compile_output}" == *.cpp.* ]] || [[ "${compile_output}" == *.cc.* ]]; then
					local warning_text_pattern="${WARNING_TEXT_PATTERN_FOR_CPP}"
				elif [[ "${compile_output}" == *.pas.* ]]; then
					local warning_text_pattern="${WARNING_TEXT_PATTERN_FOR_PAS}"
				elif [[ "${compile_output}" == *.java.* ]]; then
					local warning_text_pattern="${WARNING_TEXT_PATTERN_FOR_JAVA}"
				else
					errcho "Could not detect the type of compile output '${compile_output}'."
					continue
				fi
				if grep -q "${warning_text_pattern}" "${makefile_dir}/${compile_output}"; then
					echo "Text pattern '${warning_text_pattern}' found in compile output '${compile_output}':" >> "${WARN_FILE}"
					cat "${makefile_dir}/${compile_output}" >> "${WARN_FILE}"
					echo "----------------------------------------------------------------------" >> "${WARN_FILE}"
				fi
			done
		else
			echo "Makefile in '${makefile_dir}' does not have target '${MAKEFILE_COMPILE_OUTPUTS_LIST_TARGET}'." >> "${WARN_FILE}"
		fi
	fi	
}


function is_in {
	local -r key="$1"; shift
	local item
	for item in "$@"; do
		if [ "${key}" == "${item}" ]; then
			return 0
		fi
	done
	return 1
}


# This function gets a series of true/false arguments and prints a true/false string as their OR.
# Natural usage: cond="$(str_or "${a}" "${b}")"
function str_or {
	local item
	for item in "$@"; do
		if [ "${item}" == "true" ]; then
			echo "true"
			return
		fi
	done
	echo "false"
}


function hspace {
	local -r width="$1"; shift
	printf "%${width}s" ""
}


function decorate_lines {
	local -r prefix="$1"; shift
	if [ $# -ge 1 ]; then
		local -r suffix="$1"; shift
	else
		local -r suffix=""
	fi
	local x
	while read -r x; do
		printf '%s%s%s\n' "${prefix}" "${x}" "${suffix}"
	done
}


function check_any_type_file_exists {
	local -r test_flag="$1"; shift
	local -r the_problem="$1"; shift
	local -r file_title="$1"; shift
	local -r file_path="$1"; shift
	local error_prefix=""
	if [[ "$#" > 0 ]] ; then
		error_prefix="$1"; shift
	fi
	readonly error_prefix

	if [ ! -e "${file_path}" ]; then
		errcho -ne "${error_prefix}"
		errcho "${file_title} '$(basename "${file_path}")' not found."
		errcho "Given address: '${file_path}'"
		return 4
	fi
	
	if [ ! "$test_flag" "${file_path}" ]; then
		errcho -ne "${error_prefix}"
		errcho "${file_title} '$(basename "${file_path}")' ${the_problem}."
		errcho "Given address: '${file_path}'"
		return 4
	fi
}

#usage: check_file_exists <file-title> <file-path> [<error-prefix>]
function check_file_exists {
	check_any_type_file_exists -f "is not a regular file" "$@"
}

function check_directory_exists {
	check_any_type_file_exists -d "is not a directory" "$@"
}

function check_executable_exists {
	check_any_type_file_exists -x "is not executable" "$@"
}


function command_exists {
	local -r cmd_name="$1"; shift
	command -v "${cmd_name}" &> "/dev/null"
}


# Assumes that a function "usage" is defined
function usage_exit {
	local -r exit_code="$1"; shift
	usage
	exit "${exit_code}"
}

# Assumes that a function "usage" is defined
function error_usage_exit {
	local -r exit_code="$1"; shift
	local -r msg="$1"; shift
	errcho "${msg}"
	usage_exit "${exit_code}"
}


# This is a commonly used function as an invalid_arg_callback for argument_parser.
# It assumes that a "usage" function is already defined and available during the argument parsing.
function invalid_arg_with_usage {
	local -r curr_arg="$1"; shift
	errcho "Error at argument '${curr_arg}':" "$@"
	usage
	exit 2
}

# Fetches the value of an option, while parsing the arguments of a command.
# ${curr} denotes the current token
# ${next} denotes the next token when ${next_available} is "true"
# the next token is allowed to be used when ${can_use_next} is "true"
function fetch_arg_value {
	local -r __fav_local__variable_name="$1"; shift
	local -r __fav_local__short_name="$1"; shift
	local -r __fav_local__long_name="$1"; shift
	local -r __fav_local__argument_name="$1"; shift

	local __fav_local__fetched_arg_value
	local __fav_local__is_fetched="false"
	if [ "${curr}" == "${__fav_local__short_name}" ]; then
		if "${can_use_next}" && "${next_available}"; then
			__fav_local__fetched_arg_value="${next}"
			__fav_local__is_fetched="true"
			increment "arg_shifts"
		fi
	else
		__fav_local__fetched_arg_value="${curr#${__fav_local__long_name}=}"
		__fav_local__is_fetched="true"
	fi
	if "${__fav_local__is_fetched}"; then
		set_variable "${__fav_local__variable_name}" "${__fav_local__fetched_arg_value}"
	else
		"${invalid_arg_callback}" "${curr}" "missing ${__fav_local__argument_name}"
	fi
}

function fetch_nonempty_arg_value {
	fetch_arg_value "$@"
	local -r __fnav_local__variable_name="$1"; shift
	local -r __fnav_local__short_name="$1"; shift
	local -r __fnav_local__long_name="$1"; shift
	local -r __fnav_local__argument_name="$1"; shift
	[ -n "${!__fnav_local__variable_name}" ] ||
		"${invalid_arg_callback}" "${curr}" "Given ${__fnav_local__argument_name} shall not be empty."
}

# Fetches the value of the next argument, while parsing the arguments of a command.
# ${curr} denotes the current token
# ${next} denotes the next token when ${next_available} is "true"
# the next token is allowed to be used when ${can_use_next} is "true"
function fetch_next_arg {
	local -r __fna_local__variable_name="$1"; shift
	local -r __fna_local__short_name="$1"; shift
	local -r __fna_local__long_name="$1"; shift
	local -r __fna_local__argument_name="$1"; shift

	if "${can_use_next}" && "${next_available}"; then
		increment "arg_shifts"
		set_variable "${__fna_local__variable_name}" "${next}"
	else
		"${invalid_arg_callback}" "${curr}" "missing ${__fna_local__argument_name}"
	fi
}

# This function parses the given arguments of a command.
# Three callback functions shall be given before passing the command arguments:
# * handle_positional_arg_callback: for handling the positional arguments
#   arguments: the current command argument
# * handle_option_callback: for handling the optional arguments
#   arguments: the current command argument (after separating the concatenated optional arguments, e.g. -abc --> -a -b -c)
# * invalid_arg_callback: for handling the errors in arguments
#   arguments: the current command argument & error message
# Variables ${curr}, ${next}, ${next_available}, and ${can_use_next} are provided to callbacks.
function argument_parser {
	local -r handle_positional_arg_callback="$1"; shift
	local -r handle_option_callback="$1"; shift
	local -r invalid_arg_callback="$1"; shift

	local -i arg_shifts
	local curr next_available next can_use_next concatenated_option_chars
	while [ $# -gt 0 ]; do
		arg_shifts=0
		curr="$1"; shift
		next_available="false"
		if [ $# -gt 0 ]; then
			next="$1"
			next_available="true"
		fi

		if [[ "${curr}" == --* ]]; then
			can_use_next="true"
			"${handle_option_callback}" "${curr}"
		elif [[ "${curr}" == -* ]]; then
			if [ "${#curr}" == 1 ]; then
				"${invalid_arg_callback}" "${curr}" "invalid argument"
			else
				concatenated_option_chars="${curr#-}"
				while [ -n "${concatenated_option_chars}" ]; do
					can_use_next="false"
					if [ "${#concatenated_option_chars}" -eq 1 ]; then
						can_use_next="true"
					fi
					curr="-${concatenated_option_chars:0:1}"
					"${handle_option_callback}" "${curr}"
					concatenated_option_chars="${concatenated_option_chars:1}"
				done
			fi
		else
			"${handle_positional_arg_callback}" "${curr}"
		fi

		shift "${arg_shifts}"
	done
}


# Prepares the environment for bash completion
# arguments should be in the form:
# <bc_index> <bc_cursor_offset> <arguments...>
# It sets these variables:
#  shifts: You should run "shift ${shifts}" if you want to parse the arguments.
#  bc_index: Index of the token on which the cursor is (1-based).
#  bc_cursor_offset: Location (offset) of the cursor on the current token (0-based).
#  bc_current_token: The token on which the cursor is (possibly empty).
#  bc_current_token_prefix: The part of the current token which is before the cursor.
# Example:
#  setup_bash_completion 1 2 param1 param2
# Result:
#  shifts=2, bc_index=1, bc_cursor_offset=2,
#  bc_current_token=param1, bc_current_token_prefix=pa
function setup_bash_completion {
	function add_space_all {
		local tmp
		while read -r tmp; do
			printf '%s \n' "${tmp}"
		done
	}

	function add_space_options {
		local tmp
		while read -r tmp; do
			if [[ ${tmp} != *= ]]; then
				printf '%s \n' "${tmp}"
			else
				printf '%s\n' "${tmp}"
			fi
		done
	}

	function fix_file_endings {
		local tmp
		while read -r tmp; do
			if [ -d "${tmp}" ]; then
				printf '%s/\n' "${tmp}"
			else
				printf '%s \n' "${tmp}"
			fi
		done
	}

	function complete_with_files {
		compgen -f -- "$1" | unified_sort | fix_file_endings || true
	}

	[ $# -gt 1 ] || exit 0

	shifts=0
	bc_index="$1"; shift; increment shifts
	[ ${bc_index} -gt 0 ] || exit 0

	readonly bc_cursor_offset="$1"; shift; increment shifts
	[ ${bc_cursor_offset} -ge 0 ] || exit 0

	if [ "${bc_index}" -le $# ]; then
		readonly bc_current_token="${!bc_index}"
	else
		readonly bc_current_token=""
	fi
	readonly bc_current_token_prefix="${bc_current_token:0:${bc_cursor_offset}}"
}
