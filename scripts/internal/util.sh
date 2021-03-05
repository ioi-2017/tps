#!/bin/bash

function errcho {
	>&2 echo "$@"
}

function print_exit_code {
	ret=0
	"$@" || ret=$?
	echo "${ret}"
}

function extension {
	file=$1
	echo "${file##*.}"
}

function variable_exists {
	varname=$1
	[ -n "${!varname+x}" ]
}

function variable_not_exists {
	varname=$1
	[ -z "${!varname+x}" ]
}

function check_variable {
	varname=$1
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


function are_same {
	diff "$1" "$2" > /dev/null 2>&1
}

function recreate_dir {
	dir=$1
	mkdir -p "${dir}"
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
	ret=$?
	if [ "${ret}" -ne 0 ]; then
		exit ${ret}
	fi
}

function is_windows {
	if variable_not_exists "OS" ; then
		return 1
	fi
	echo "${OS}" | grep -iq "windows"
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
	color="$1"; shift
	echo "$@" | "${PYTHON}" "${INTERNALS}/colored_cat.py" "${color}"
}

#colored errcho
function cerrcho {
	>&2 cecho "$@"
}


function boxed_echo {
	color="$1"; shift

	echo -n "["
	cecho "${color}" -n "$1"
	echo -n "]"

	if variable_exists "BOX_PADDING" ; then
		pad=$((BOX_PADDING - ${#1}))
		hspace "${pad}"
	fi
}

function echo_status {
	status="$1"

	case "${status}" in
		OK) color=ok ;;
		FAIL) color=fail ;;
		WARN) color=warn ;;
		SKIP) color=skipped ;;
		*) color=other ;;
	esac

	boxed_echo "${color}" "${status}"
}

function echo_verdict {
	verdict="$1"

	case "${verdict}" in
		Correct) color=ok ;;
		Partial*) color=warn ;;
		Wrong*|Runtime*) color=error ;;
		Time*) color=blue ;;
		Unknown) color=ignored ;;
		*) color=other ;;
	esac

	boxed_echo "${color}" "${verdict}"
}


function has_warnings {
	local job="$1"
	local WARN_FILE="${LOGS_DIR}/${job}.warn"
	[ -s "${WARN_FILE}" ]
}

skip_status=1000
abort_status=1001
warn_status=250

function job_ret {
	local job="$1"
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
	is_warning_sensitive && has_warnings "$1"
}

function warning_aware_job_ret {
	local job="$1"
	local ret="$(job_ret "${job}")"
	if [ ${ret} -ne 0 ]; then
		echo ${ret}
	elif has_sensitive_warnings "${job}"; then
		echo ${warn_status}
	else
		echo 0
	fi
}


function check_float {
	echo "$1" | grep -Eq '^[0-9]+\.?[0-9]*$'
}

function job_tlog_file {
	local job="$1"
	echo "${LOGS_DIR}/${job}.tlog"
}

function job_tlog {
	local job="$1"; shift
	local key="$1"
	local tlog_file="$(job_tlog_file "${job}")"
	if [ -f "${tlog_file}" ]; then
		local ret=0
		local line="$(grep "^${key} " "${tlog_file}")" || ret=$?
		if [ ${ret} -ne 0 ]; then
			errcho "tlog file '${tlog_file}' does not contain key '${key}'"
			exit 1
		fi
		echo "${line}" | cut -d' ' -f2-
	else
		errcho "tlog file '${tlog_file}' is not created"
		exit 1
	fi
}

function job_status {
	local job="$1"
	local ret="$(job_ret "${job}")"

	if [ "${ret}" -eq 0 ]; then
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
	local job="$1"; shift
	local outlog="${LOGS_DIR}/${job}.out"
	local errlog="${LOGS_DIR}/${job}.err"
	local retlog="${LOGS_DIR}/${job}.ret"
	export WARN_FILE="${LOGS_DIR}/${job}.warn"

	echo "${abort_status}" > "${retlog}"

	local ret=0
	"$@" > "${outlog}" 2> "${errlog}" || ret=$?
	echo "${ret}" > "${retlog}"

	return ${ret}
}

function insensitive {
	"$@" || true
}

function boxed_guard {
	local job="$1"

	insensitive guard "$@"
	echo_status "$(job_status "${job}")"
}

function execution_report {
	local job="$1"

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
	local job="$1"

	boxed_guard "$@"

	local ret="$(warning_aware_job_ret "${job}")"

	if [ "${ret}" -ne 0 ]; then
		echo
		execution_report "${job}"
	fi

	return ${ret}
}


WARNING_TEXT_PATTERN_FOR_CPP="warning:"
WARNING_TEXT_PATTERN_FOR_PAS="Warning:"
WARNING_TEXT_PATTERN_FOR_JAVA="warning:"


MAKEFILE_COMPILE_OUTPUTS_LIST_TARGET="compile_outputs_list"

function makefile_compile_outputs_list {
	local make_dir="$1"; shift
	make --quiet -C "${make_dir}" "${MAKEFILE_COMPILE_OUTPUTS_LIST_TARGET}"
}

function build_with_make {
	local make_dir="$1"; shift
	make -j4 -C "${make_dir}" || return $?
	if variable_exists "WARN_FILE"; then
		if compile_outputs_list=$(makefile_compile_outputs_list "${make_dir}"); then
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
				if grep -q "${warning_text_pattern}" "${make_dir}/${compile_output}"; then
					echo "Text pattern '${warning_text_pattern}' found in compile output '${compile_output}':" >> "${WARN_FILE}"
					cat "${make_dir}/${compile_output}" >> "${WARN_FILE}"
					echo "----------------------------------------------------------------------" >> "${WARN_FILE}"
				fi
			done
		else
			echo "Makefile in '${make_dir}' does not have target '${MAKEFILE_COMPILE_OUTPUTS_LIST_TARGET}'." >> "${WARN_FILE}"
		fi
	fi	

}


function is_in {
	key="$1"; shift
	for item in "$@"; do
		if [ "${key}" == "${item}" ]; then
			return 0
		fi
	done
	return 1
}

function hspace {
	printf "%$1s" ""
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
	test_flag="$1"; shift
	the_problem="$1"; shift
	file_title="$1"; shift
	file_path="$1"; shift
	error_prefix=""
	if [[ "$#" > 0 ]] ; then
		error_prefix="$1"; shift
	fi

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
	command -v "$1" >/dev/null 2>&1
}

function invalid_arg {
	errcho "Error at argument '${curr}':" "$@"
	usage
	exit 2
}

# Fetches the value of an option, while parsing the arguments of the command
# ${curr} denotes the current token
# ${next} denotes the next token when ${next_available} is "true"
# the next token is allowed to be used when ${can_use_next} is "true"
function fetch_arg_value {
	local variable_name="$1"; shift
	local short_name="$1"; shift
	local long_name="$1"; shift
	local argument_name="$1"

	local fetched_arg_value=""
	if [ "${curr}" == "${short_name}" ]; then
		if "${can_use_next}" && "${next_available}"; then
			fetched_arg_value="${next}"
			shifts=1
		fi
	else
		fetched_arg_value="${curr#${long_name}=}"
	fi
	if [ -n "${fetched_arg_value}" ]; then
		eval "${variable_name}='${fetched_arg_value}'"
	else
		invalid_arg "missing ${argument_name}"
	fi
}

# Fetches the value of the next argument, while parsing the arguments of the command
# ${curr} denotes the current token
# ${next} denotes the next token when ${next_available} is "true"
# the next token is allowed to be used when ${can_use_next} is "true"
function fetch_next_arg {
	local variable_name="$1"; shift
	local short_name="$1"; shift
	local long_name="$1"; shift
	local argument_name="$1"; shift
	if "${can_use_next}" && "${next_available}"; then
		shifts=1
		eval "${variable_name}='${next}'"
	else
		invalid_arg "missing ${argument_name}"
	fi
}

# Parses arguments of the command
# two callbacks should be provided in order to handle positional args and options
# variables ${curr}, ${next}, ${next_available}, and ${can_use_next} are provided to callbacks
function argument_parser {
	handle_positional_arg_callback="$1"; shift
	handle_option_callback="$1"; shift

	while [ $# -gt 0 ]; do
		shifts=0
		curr="$1"; shift
		next_available="false"
		if [ $# -gt 0 ]; then
			next="$1"
			next_available="true"
		fi

		if [[ "${curr}" == --* ]]; then
			can_use_next="true"
			"${handle_option_callback}"
		elif [[ "${curr}" == -* ]]; then
			if [ "${#curr}" == 1 ]; then
				invalid_arg "invalid argument"
			else
				temp="${curr#-}"
				while [ -n "${temp}" ]; do
					can_use_next="false"
					if [ "${#temp}" -eq 1 ]; then
						can_use_next="true"
					fi
					curr="-${temp:0:1}"
					"${handle_option_callback}"
					temp="${temp:1}"
				done
			fi
		else
			"${handle_positional_arg_callback}"
		fi

		shift "${shifts}"
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
