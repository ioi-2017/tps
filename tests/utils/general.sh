
readonly _TT_NEW_LINE="
"

function _TT_errcho {
	>&2 echo "$@"
}

function _TT_error_exit {
	local -r exit_code="$1"; shift
	_TT_errcho "$@"
	exit "${exit_code}"
}


function _TT_is_in {
	local -r item_to_find="$1"; shift
	local item
	for item in "$@"; do
		[ "${item_to_find}" != "${item}" ] ||
			return 0
	done
	return 1
}


function _TT_variable_exists {
	local -r varname="$1"; shift
	declare -p "${varname}" &>/dev/null
}

function _TT_variable_not_exists {
	local -r varname="$1"; shift
	! _TT_variable_exists "${varname}"
}

function _TT_set_variable {
	local -r var_name="$1"; shift
	local -r var_value="$1"; shift
	printf -v "${var_name}" '%s' "${var_value}"
}

function _TT_set_array_variable {
	local -r new_var_name="$1"; shift
	local -r old_var_name="$1"; shift
	eval "${new_var_name}=(\${${old_var_name}[@]+\"\${${old_var_name}[@]}\"})"
}

function _TT_is_variable_array {
	local -r varname="$1"; shift
	[[ "$(declare -p "${varname}" 2>/dev/null)" =~ "declare -a" ]]
}

function _TT_increment {
	# Calling ((v++)) causes unexpected exit in some versions of bash.
	local -r var_name="$1"; shift
	if [ $# -gt 0 ]; then
		local -r c="$1"; shift
	else
		local -r c=1
	fi
	_TT_set_variable "${var_name}" "$((${var_name}+c))"
}

function _TT_is_nonnegative_integer {
	local -r value="$1"; shift
	grep -Eq '^[0-9]+$' <<< "${value}"
}


function _TT_str_starts_with {
	local -r s="$1"; shift
	local -r t="$1"; shift
	[[ "${s}" == "${t}"* ]]
}

function _TT_str_ends_with {
	local -r s="$1"; shift
	local -r t="$1"; shift
	[[ "${s}" == *"${t}" ]]
}

function _TT_str_contains {
	local -r s="$1"; shift
	local -r t="$1"; shift
	[[ "${s}" == *"${t}"* ]]
}


function _TT_escape_arg {
	local -r str="$1"; shift
	echo -n "\""
	echo -n "${str}" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\\$/g'
	echo -n "\""
}

function _TT_escape_arg_if_needed {
	local -r s="$1"; shift
	local q
	printf -v q "%q" "${s}"
	readonly q
	if [ "${q}" == "${s}" ]; then
		printf "%s" "${s}"
	else
		_TT_escape_arg "${s}"
	fi
}

function _TT_array_to_str_args {
	local first="true"
	while [ $# -gt 0 ]; do
		"${first}" ||
			printf " "
		first="false"
		_TT_escape_arg_if_needed "$1"; shift
	done
}

function _TT_command_exists {
	command -v "$1" >/dev/null 2>&1
}


function _TT_absolute_path {
	local -r path="$1"; shift
	if _TT_str_starts_with "${path}" "/"; then
		echo "${path}"
	else
		echo "$(cd "$(dirname "${path}")"; pwd)/$(basename "${path}")"
	fi
}

function _TT_pushdq {
	pushd "$@" > /dev/null
}

function _TT_popdq {
	popd > /dev/null
}

function _TT_pushdq_here {
	_TT_pushdq "$(dirname "$0")"
}


function _TT_check_any_type_file_exists {
	local -r test_flag="$1"; shift
	local -r the_problem="$1"; shift
	local -r file_title="$1"; shift
	local -r file_path="$1"; shift
	local error_prefix=""
	if [ "$#" -gt 0 ] ; then
		error_prefix="$1"; shift
	fi
	readonly error_prefix

	[ -e "${file_path}" ] ||
		_TT_error_exit 4 -e "\
${error_prefix}${file_title} '$(basename "${file_path}")' not found.
Given address: '${file_path}'"

	[ "${test_flag}" "${file_path}" ] ||
		_TT_error_exit 4 -e "\
${error_prefix}${file_title} '$(basename "${file_path}")' ${the_problem}.
Given address: '${file_path}'"
}

#usage: _TT_check_file_exists <file-title> <file-path> [<error-prefix>]
function _TT_check_file_exists {
	_TT_check_any_type_file_exists -f "is not a regular file" "$@"
}

function _TT_check_directory_exists {
	_TT_check_any_type_file_exists -d "is not a directory" "$@"
}


function _TT_recreate_dir {
	local -r dir="$1"; shift
	mkdir -p "${dir}"
	local file
	ls -A1 "${dir}" | while read file; do
		[ -n "${file}" ] ||
			continue
		rm -rf "${dir}/${file}"
	done
	return 0 # For safety
}

function run_bash_on {
	local -r pattern="$1"; shift
	local -r files="$(eval ls -1 "${pattern}" 2>/dev/null || true)"
	[ -n "${files}" ] ||
		return 0
	local f
	while read f; do
		bash "${f}" "$@"
	done <<< "${files}"
}

function _TT_truncated_cat {
	local -r file_name="$1"; shift
	local -r limit="$1"; shift
	_TT_check_file_exists "File" "${file_name}" "Error in using _TT_truncated_cat: "
	local lines
	lines="$(wc -l < "${file_name}")"
	readonly lines
	if [ "${lines}" -le "${limit}" ]; then
		cat "${file_name}"
	else
		head "-${limit}" "${file_name}"
		printf "[Truncated] +%d more line(s). See the complete version in '%s'." "$((lines-limit))" "$(_TT_escape_arg "${file_name}")"
	fi
}

function _TT_linux_sort {
	local -r _sort=$(which -a "sort" | grep -iv "windows" | head -1)
	if [ -n "${_sort}" ] ; then
		"${_sort}" "$@"
	else
		_TT_error_exit 3 "Could not find a proper 'sort' command."
	fi
}

function _TT_linux_find {
	local -r _find=$(which -a "find" | grep -iv "windows" | head -1)
	if [ -n "${_find}" ] ; then
		"${_find}" "$@"
	else
		_TT_error_exit 3 "Could not find a proper 'find' command."
	fi
}

function _TT_read_file_exactly {
	# This keeps the trailing new lines.
	local -r var_name="$1"; shift
	local -r file_name="$1"; shift
	_TT_check_file_exists "File" "${file_name}" "Error in using _TT_read_file_exactly: "
	local content_x
	content_x="$(cat "${file_name}"; echo "x")"
	readonly content_x
	_TT_set_variable "${var_name}" "${content_x%x}"
}

function _TT_next_free_fd {
	local -r max="$(ulimit -n)"
	local fd
	for ((fd=3; fd<max; ++fd)); do
		! true >&${fd} && ! true <&${fd} && echo "${fd}" && return 0
	done 2>/dev/null
	return 1
}
