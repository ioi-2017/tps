#!/bin/bash

# A supplementary command as a tool used in TPS repositories
# Kian Mirjalali, Hamed Saleh, MohammadReza Maleki
# IOI 2017, Iran


readonly tps_version=1.5


set -e

function __tps__errcho__ {
	>&2 echo "$@"
}



if [ $# -eq 0 ]; then
	readonly __tps_help_mode__="true"
	echo "\
TPS version ${tps_version}

Usage: tps <command> <arguments>...
"
	function __tps__help_exit__ {
		local -r message="$1"; shift
		echo "${message}"
		exit 1
	}
else
	readonly __tps_help_mode__="false"
	__tps_command__="$1"; shift
fi


if ! "${__tps_help_mode__}" && [ "${__tps_command__}" == "--bash-completion" ]; then
	readonly __tps_bash_completion_mode__="true"

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
		compgen -f -- "$1" | __tps_unified_sort__ | fix_file_endings || true
	}

	[ $# -gt 1 ] || exit 0

	bc_index="$1"; shift
	[ ${bc_index} -gt 0 ] || exit 0

	readonly bc_cursor_location="$1"; shift
	[ ${bc_cursor_location} -ge 0 ] || exit 0

	# Removing the token 'tps'
	shift

	if [ "${bc_index}" -le $# ]; then
		readonly bc_current_token="${!bc_index}"
	else
		readonly bc_current_token=""
	fi
	readonly bc_current_token_prefix="${bc_current_token:0:${bc_cursor_location}}"
else
	readonly __tps_bash_completion_mode__="false"
fi


function __tps__error_exit__ {
	"${__tps_bash_completion_mode__}" && exit 0
	local -r exit_code="$1"; shift
	local -r message="$1"; shift
	__tps__errcho__ "Error: ${message}"
	exit "${exit_code}"
}


function __tps_unified_sort__ {
	local _sort
	_sort=$(which -a "sort" | grep -iv "windows" | head -1)
	readonly _sort
	if [ -n "${_sort}" ] ; then
		"${_sort}" -u "$@"
	else
		cat "$@"
	fi
}


__tps_target_file__="problem.json"
__tps_scripts__="scripts"

function __tps_find_basedir__ {
	#looking for ${__tps_target_file__} in current and parent directories...
	local __tps_curr__="$PWD"
	local __tps_prev__=""
	while [ "${__tps_curr__}" != "${__tps_prev__}" ]; do
		if [ -f "${__tps_curr__}/${__tps_target_file__}" ]; then
			readonly __in_tps_repo__="true"
			readonly BASE_DIR="${__tps_curr__}"
			readonly __tps_scripts_dir__="${BASE_DIR}/${__tps_scripts__}"
			return
		fi
		__tps_prev__="${__tps_curr__}"
		__tps_curr__="$(dirname "${__tps_curr__}")"
	done
	readonly __in_tps_repo__="false"
}
__tps_find_basedir__


if ! "${__in_tps_repo__}"; then
	if "${__tps_bash_completion_mode__}"; then
		if [ ${bc_index} -eq 1 ]; then
			# No commands available out of a TPS repository
			exit 0
		fi
		# Extracting the command name
		__tps_command__="$1"; shift; ((bc_index--))
		# bc_index >= 1
	fi
	"${__tps_help_mode__}" && __tps__help_exit__ "Currently not in a TPS repository ('${__tps_target_file__}' not found in any of the parent directories)."
	__tps__error_exit__ 2 "Not in a TPS repository ('${__tps_target_file__}' not found in any of the parent directories)."
fi


export BASE_DIR

# Keeping the lower-case variable 'base_dir' for backward compatibility.
export base_dir="${BASE_DIR}"


if [ ! -d "${__tps_scripts_dir__}" ]; then
	"${__tps_help_mode__}" && __tps__help_exit__ "In a TPS repository without directory '${__tps_scripts__}'."
	__tps__error_exit__ 2 "Directory '${__tps_scripts__}' not found."
fi


readonly __tps_runnable_extensions__=("sh" "py" "exe")

function __tps_run_file__ {
	local -r file2run="$1"; shift
	local -r ext="${file2run##*.}"
	if [ "${ext}" == "sh" ]; then
		bash "${file2run}" "$@"
	elif [ "${ext}" == "py" ]; then
		function __tps__check_py_cmd__ {
			local -r CMD="$1"
			command -v "${CMD}" >/dev/null 2>&1 || return 1
			__tps__python__="${CMD}"
			return 0
		}
		if [ -n "${PYTHON+x}" ] ; then
			__tps__check_py_cmd__ "${PYTHON}" ||
			__tps__error_exit__ 2 "Python command '${PYTHON}' set by environment variable 'PYTHON' does not exist."
		else
			__tps__check_py_cmd__ "python3" ||
			__tps__check_py_cmd__ "python" ||
			__tps__error_exit__ 2 "Environment variable 'PYTHON' is not set and neither of python commands 'python3' nor 'python' exists."
		fi
		"${__tps__python__}" "${file2run}" "$@"
	elif [ "${ext}" == "exe" ]; then
		"${file2run}" "$@"
	else
		__tps__error_exit__ 3 "Unknown extension '${ext}' for running (illegal state)."
	fi
}


function __tps_list_commands__ {
	local extensions=""
	for ext in "${__tps_runnable_extensions__[@]}"; do
		[ -n "${extensions}" ] && extensions="${extensions}|"
		extensions="${extensions}${ext}"
	done
	local f
	ls -a -1 "${__tps_scripts_dir__}" 2>/dev/null | grep -E ".\\.(${extensions})$" | while read f; do echo ${f%.*}; done | __tps_unified_sort__ || true
}

if "${__tps_bash_completion_mode__}"; then
	if [ ${bc_index} -eq 1 ]; then
		available_commands="$(__tps_list_commands__)"
		readonly available_commands
		if [ -n "${available_commands}" ]; then
			compgen -W "${available_commands}" -- "${bc_current_token_prefix}" | add_space_all || true
		fi
		exit 0
	fi
	# Extracting the command name
	__tps_command__="$1"; shift; ((bc_index--))
	# bc_index >= 1
fi

if "${__tps_help_mode__}"; then
	readonly version_file="${__tps_scripts_dir__}/internal/version"
	if [ -f "${version_file}" ]; then
		scripts_version="$(sed -n 1p "${version_file}")"
		readonly scripts_version
		readonly scripts_version_info="Scripts version: ${scripts_version}
"
	else
		readonly scripts_version_info=""
	fi
	available_commands="$(__tps_list_commands__)"
	readonly available_commands
	if [ -z "${available_commands}" ]; then
		readonly commands_info="In a TPS repository with no commands available in '${__tps_scripts__}'."
	else
		function add_prefix {
			local -r prefix="$1"; shift
			local x
			while read -r x; do
				printf '%s%s\n' "${prefix}" "${x}"
			done
		}
		commands_info="In a TPS repository with the following commands available:
$(echo "${available_commands}" | add_prefix '  ')"
		readonly commands_info
	fi
	__tps__help_exit__ "${scripts_version_info}${commands_info}"
fi


function __tps_find_runnable_file__ {
	local -r cmd="$1"; shift
	local -r dir="$1"; shift
	local ext
	for ext in "${__tps_runnable_extensions__[@]}"; do
		local file_name="${cmd}.${ext}"
		if [ -f "${dir}/${file_name}" ]; then
			echo "${file_name}"
			return
		fi
	done
}


__tps_command_file_name__="$(__tps_find_runnable_file__ "${__tps_command__}" "${__tps_scripts_dir__}")"
readonly __tps_command_file_name__

if [ -z "${__tps_command_file_name__}" ]; then
	searched_files=""
	for ext in "${__tps_runnable_extensions__[@]}"; do
		[ -n "${searched_files}" ] && searched_files="${searched_files}, "
		searched_files="${searched_files}'${__tps_command__}.${ext}'"
	done
	__tps__error_exit__ 2 "Command '${__tps_command__}' not found in '${__tps_scripts__}'.
Searched for ${searched_files}."
fi


if "${__tps_bash_completion_mode__}"; then
	readonly bc_dir="${__tps_scripts_dir__}/bash_completion"
	# Looking for bash completion script file
	command_bc_script_file_name="$(__tps_find_runnable_file__ "${__tps_command__}" "${bc_dir}")"
	readonly command_bc_script_file_name
	if [ -n "${command_bc_script_file_name}" ]; then
		readonly command_bc_script_file="${bc_dir}/${command_bc_script_file_name}"
		__tps_run_file__ "${command_bc_script_file}" "${bc_index}" "${bc_cursor_location}" "$@"
		exit 0
	fi
	# Looking for bash completion options file
	readonly command_bc_options_file="${bc_dir}/${__tps_command__}.options"
	if [ -f "${command_bc_options_file}" ]; then
		if [[ ${bc_current_token_prefix} == --*=* ]]; then
			complete_with_files "${bc_current_token_prefix#*=}"
		else
			compgen -W "$(cat "${command_bc_options_file}")" -- "${bc_current_token_prefix}" | add_space_options || true
			complete_with_files "${bc_current_token_prefix}"
		fi
		exit 0
	fi
	# No specific bash completion method. Using files.
	complete_with_files "${bc_current_token_prefix}"
	exit 0
fi


readonly __tps_init_relative_path__="${__tps_scripts__}/internal/tps_init.sh"
readonly __tps_init_file__="${BASE_DIR}/${__tps_init_relative_path__}"

if [ -f "${__tps_init_file__}" ]; then
	source "${__tps_init_file__}"
else
	: "File '${__tps_init_relative_path__}' not found."
fi


readonly __tps_command_file__="${__tps_scripts_dir__}/${__tps_command_file_name__}"
__tps_run_file__ "${__tps_command_file__}" "$@"

