#!/bin/bash

# A supplementary command as a tool used in TPS repositories
# Kian Mirjalali, Hamed Saleh, MohammadReza Maleki
# IOI 2017, Iran


readonly tps_version=1.6


set -e

function __tps__errcho__ {
	>&2 echo "$@"
}


function __tps__variable_exists {
	local -r varname="$1"; shift
	declare -p "${varname}" &> "/dev/null"
}


function __tps__unified_sort__ {
	local _sort
	_sort="$(which -a "sort" | grep -iv "windows" | head -1)"
	readonly _sort
	if [ -n "${_sort}" ]; then
		"${_sort}" -u "$@"
	else
		cat "$@"
	fi
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
		compgen -f -- "$1" | __tps__unified_sort__ | fix_file_endings || true
	}

	[ $# -gt 1 ] || exit 0

	bc_index="$1"; shift
	[ ${bc_index} -gt 0 ] || exit 0

	readonly bc_cursor_offset="$1"; shift
	[ ${bc_cursor_offset} -ge 0 ] || exit 0

	# Removing the token 'tps'
	shift

	if [ "${bc_index}" -le $# ]; then
		readonly bc_current_token="${!bc_index}"
	else
		readonly bc_current_token=""
	fi
	readonly bc_current_token_prefix="${bc_current_token:0:${bc_cursor_offset}}"
else
	readonly __tps_bash_completion_mode__="false"
fi


function __tps__error_exit__ {
	"${__tps_bash_completion_mode__}" && exit 0
	local -r exit_code="$1"; shift
	__tps__errcho__ -n "Error: "
	__tps__errcho__ "$@"
	exit "${exit_code}"
}

function __tps__define_python__ {
	# Note: the implementation of this function should be kept synched with function __private__define_python__ in new_task_init
	function __tps__check_py_cmd__ {
		local -r py_cmd="$1"; shift
		command -v "${py_cmd}" &> "/dev/null" || return 1
		__tps__python__="${py_cmd}"
		return 0
	}
	if __tps__variable_exists "PYTHON"; then
		__tps__check_py_cmd__ "${PYTHON}" ||
		__tps__error_exit__ 2 "Python command '${PYTHON}' set by environment variable 'PYTHON' does not exist."
	else
		__tps__check_py_cmd__ "python3" ||
		__tps__check_py_cmd__ "python" ||
		__tps__error_exit__ 2 "Environment variable 'PYTHON' is not set and neither of python commands 'python3' nor 'python' exists."
	fi
}



function __tps_define_utility_functions__ {
	# Note:
	# The functions defined here
	# are mostly based on the functions defined in 'scripts/internal/util.sh'
	# and should be kept synched with them.


	function errcho {
		>&2 echo "$@"
	}


	# This function is not based on 'scripts/internal/util.sh'.
	function error_exit {
		local -r exit_code="$1"; shift
		errcho -n "Error: "
		errcho "$@"
		exit "${exit_code}"
	}


	function variable_exists {
		local -r varname="$1"; shift
		declare -p "${varname}" &> "/dev/null"
	}

	function variable_not_exists {
		local -r varname="$1"; shift
		! variable_exists "${varname}"
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

	function command_exists {
		local -r cmd_name="$1"; shift
		command -v "${cmd_name}" &> "/dev/null"
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
}



function new_task_init {

	function find_file_in_given_path {
		# Given a "file_name" and a colon-delimited "path",
		#   this function prints the first directory (in the "path") containing the specified file.
		# Nothing is printed if none of the directories contain the specified file.
		local -r file_name="$1"; shift
		local -r path="$1"; shift

		local directories
		# Delimit path by colon
		IFS=':' read -ra directories <<< "${path}"

		local parent child
		for parent in ${directories[@]+"${directories[@]}"}; do
			child="${parent}/${file_name}"
			if [ -n "${parent}" -a -d "${parent}" -a -e "${child}" ]; then
				echo "${parent}"
				return 0
			fi
		done
	}

	function union_files_in_given_path {
		# Given a colon-delimited "path",
		#   this function prints the union of files/directories specified in the "path".
		local -r path="$1"; shift

		local directories
		# Delimit path by colon
		IFS=':' read -ra directories <<< "${path}"

		local parent
		for parent in ${directories[@]+"${directories[@]}"}; do
			ls -1 "${parent}" 2> "/dev/null" || true
		done | __tps__unified_sort__
	}

	if "${__tps_bash_completion_mode__}"; then
		function bc_complete_templates {
			local -r value_prefix="$1"; shift

			__tps_define_utility_functions__

			function bc_invalid_arg {
				exit 0
			}
			function bc_handle_positional_arg {
				:
			}
			function bc_handle_option {
				local -r curr_arg="$1"; shift
				local dummy
				case "${curr_arg}" in
					-t|--template=*) fetch_arg_value "dummy" "-t" "--template" "--"; ;;
					-T|--templates-dir=*) fetch_arg_value "task_templates_dir" "-T" "--templates-dir" "--"; ;;
					-D|--define) fetch_next_arg "dummy" "-D" "--define" "--"; ;;
					*) ;;
				esac
			}

			argument_parser "bc_handle_positional_arg" "bc_handle_option" "bc_invalid_arg" "$@" ""

			local template_options
			if variable_exists "task_templates_dir"; then
				[ -d "${task_templates_dir}" ] || exit 0
				template_options="$(ls -1 "${task_templates_dir}")"
			else # Using TPS_TASK_TEMPLATES_PATH
				variable_exists "TPS_TASK_TEMPLATES_PATH" || exit 0
				template_options="$(union_files_in_given_path "${TPS_TASK_TEMPLATES_PATH}")"
			fi
			compgen -W "${template_options}" -- "${value_prefix}" | add_space_all || true
		}

		bc_init_command_options="\
--template=
--templates-dir=
--define"
		if [[ ${bc_current_token_prefix} == --* ]]; then
			if ! [[ ${bc_current_token_prefix} == *=* ]]; then
				compgen -W "${bc_init_command_options}" -- "${bc_current_token_prefix}" | add_space_options || true
			else
				local -r bc_option_value_prefix="${bc_current_token_prefix#*=}"
				case "${bc_current_token_prefix}" in
					--template=*)
						bc_complete_templates "${bc_option_value_prefix}" "$@"
						;;
					--templates-dir=*)
						complete_with_files "${bc_option_value_prefix}"
						;;
					*) ;;
				esac
			fi
		else
			local -r prev_bc_index=$((bc_index-1))
			local -r prev_arg="${!prev_bc_index}"
			case "${prev_arg}" in
				-t)
					bc_complete_templates "${bc_current_token_prefix}" "$@"
					;;
				-T)
					complete_with_files "${bc_current_token_prefix}"
					;;
				*) ;;
			esac
		fi
		exit 0
	fi

	__tps_define_utility_functions__

	function usage {
		errcho -e "\
Usage: tps init <new-dir-name> [options]
\t<new-dir-name> is the name of the new directory created by this command.
\
Options:
\
  -h, --help
\tShows this help.
\
  -t, --template=<task-template-name>
\tSpecifies the task template name.
\tNote: Value 'default' is considered for <task-template-name> if this option is not specified.
\
  -T, --templates-dir=<task-templates-dir>
\tSpecifies the directory where the task templates are stored.
\tNote:
\tIf this argument is provided, the template is searched only in the given directory.
\tOtherwise, the template is searched in the directories specified in the environment variable TPS_TASK_TEMPLATES_PATH.
\tTPS_TASK_TEMPLATES_PATH should be a colon-delimited list of paths containing task templates.
\tExample: /etc/tps/task-templates:/home/user/tps/task-templates
\
  -D, --define <param-name>=<param-value>
\tPredefines the value of a task template parameter.
\tNote: This option can be used multiple times."
	}


	function handle_option {
		local -r curr_arg="$1"; shift
		case "${curr_arg}" in
			-h|--help)
				usage
				exit 0
				;;
			-t|--template=*)
				fetch_nonempty_arg_value "task_template_name" "-t" "--template" "task template name"
				;;
			-T|--templates-dir=*)
				fetch_nonempty_arg_value "task_templates_dir" "-T" "--templates-dir" "task templates directory path"
				;;
			-D|--define)
				local param_definition
				fetch_next_arg "param_definition" "-D" "--define" "task template parameter value definition"
				function error_param_def {
					invalid_arg_with_usage "${curr_arg}" "Invalid format in task template parameter value definition '${param_definition}': $1"
				}
				[[ "${param_definition}" == *"="* ]] ||
					error_param_def "The argument does not have the '=' sign."
				local param_name param_value
				IFS='=' read -r param_name param_value <<< "${param_definition}"
				[ -n "${param_name}" ] ||
					error_param_def "The parameter name shall not be empty."
				( set_variable "${param_name}" "" &> "/dev/null" ) ||
					error_param_def "The parameter name '${param_name}' is not a valid identifier."
				local varname="__PREDEFINED_TPS_TEMPLATE_PARAMETER__${param_name}"
				set_variable "${varname}" "${param_value}"
				predefined_template_parameters+=( "${varname}" )
				;;
			*)
				invalid_arg_with_usage "${curr_arg}" "undefined option"
				;;
		esac
	}

	function handle_positional_arg {
		local -r curr_arg="$1"; shift
		if variable_not_exists "output_dir_name"; then
			output_dir_name="${curr_arg}"
			return 0
		fi
		invalid_arg_with_usage "${curr_arg}" "meaningless argument"
	}

	argument_parser "handle_positional_arg" "handle_option" "invalid_arg_with_usage" "$@"

	if variable_not_exists "output_dir_name"; then
		errcho "<new-dir-name> is not specified."
		usage
		exit 2
	fi

	[ ! -e "${output_dir_name}" ] ||
		error_exit 4 "Given output directory '${output_dir_name}' already exists."

	function set_default_task_template_name_if_needed {
		if variable_not_exists "task_template_name"; then
			errcho "<task-template-name> is not specified. Using 'default' as the template."
			task_template_name="default"
		fi
	}

	if variable_exists "task_templates_dir"; then
		[ -e "${task_templates_dir}" ] ||
			error_exit 4 "Given task templates directory '${task_templates_dir}' does not exist."
		[ -d "${task_templates_dir}" ] ||
			error_exit 4 "Given task templates directory '${task_templates_dir}' is not a valid directory."
		set_default_task_template_name_if_needed
		task_template_dir="${task_templates_dir}/${task_template_name}"
		[ -e "${task_template_dir}" ] ||
			error_exit 4 "Task template '${task_template_name}' does not exist in '${task_templates_dir}'."
	elif variable_exists "TPS_TASK_TEMPLATES_PATH"; then
		set_default_task_template_name_if_needed
		task_templates_dir="$(find_file_in_given_path "${task_template_name}" "${TPS_TASK_TEMPLATES_PATH}")"
		[ -n "${task_templates_dir}" ] ||
			error_exit 4 "Task template '${task_template_name}' does not exist in any of the directories specified in TPS_TASK_TEMPLATES_PATH='${TPS_TASK_TEMPLATES_PATH}'."
		errcho "Found template '${task_template_name}' in '${task_templates_dir}'."
		task_template_dir="${task_templates_dir}/${task_template_name}"
		[ -e "${task_template_dir}" ] ||
			error_exit 5 "[Illegal state] Task template '${task_template_name}' does not exist in '${task_templates_dir}'."
	else
		errcho "Neither <task-templates-dir> is specified nor TPS_TASK_TEMPLATES_PATH is set as an environment variable."
		usage
		exit 2
	fi

	[ -d "${task_template_dir}" ] ||
		error_exit 4 "Task template '${task_template_name}' in '${task_templates_dir}' is not a valid directory."

	# TTIS = task template instantiation script
	TTIS_filename="task-template-instantiate.sh"
	source_TTIS_file="${task_template_dir}/${TTIS_filename}"
	[ -f "${source_TTIS_file}" ] ||
		error_exit 14 "Task template directory '${task_template_dir}' does not contain '${TTIS_filename}' as the instantiation script."

	# Preparing the environment to run TTIS

	export task_template_dir output_dir_name TTIS_filename source_TTIS_file

	local var
	for var in ${predefined_template_parameters[@]+"${predefined_template_parameters[@]}"}; do
		export "${var}"
	done

	export -f errcho \
			error_exit \
			variable_exists variable_not_exists \
			set_variable increment \
			pushdq popdq \
			is_identifier_format \
			is_unsigned_integer_format is_signed_integer_format \
			is_unsigned_decimal_format is_signed_decimal_format \
			command_exists

	# Variables & functions defined from now on are exported & available to TTIS:
	set -a

	function __private__define_python__ {
		# Note: the implementation of this function should be kept synched with function __tps__define_python__
		function __tps__check_py_cmd__ {
			local -r py_cmd="$1"; shift
			command -v "${py_cmd}" &> "/dev/null" || return 1
			__tps__python__="${py_cmd}"
			return 0
		}
		if variable_exists "PYTHON"; then
			__tps__check_py_cmd__ "${PYTHON}" ||
			error_exit 2 "Python command '${PYTHON}' set by environment variable 'PYTHON' does not exist."
		else
			__tps__check_py_cmd__ "python3" ||
			__tps__check_py_cmd__ "python" ||
			error_exit 2 "Environment variable 'PYTHON' is not set and neither of python commands 'python3' nor 'python' exists."
		fi
	}

	function run_python {
		# Runs the python command, considering the existence of python3, python, and environment variable PYTHON
		variable_exists "__tps__python__" || __private__define_python__
		"${__tps__python__}" "$@"
	}

	function general_prompt {
		# Validating function arguments
		function _gperror_ {
			errcho -e "\
Error in calling function '${FUNCNAME[1]}' (file: '${source_TTIS_file}', line #${BASH_LINENO[1]}): $1
Usage:
\t${FUNCNAME[1]} <var-name> <validation-command> <prompt-message> [<description>]
Prompts for a text that is validated and stored in variable <var-name>.
<var-name> must be in identifier format.
The <validation-command> is called with the user-input text as standard input
 and should return 0 if the user-input is valid.
If the user-input is not valid,
 the <validation-command> should write the error message in the standard error
 (in addition to non-zero exit code).
Otherwise, it must write the valid form of user-input in the standard output.
So, any kind of conversion can be handled inside the <validation-command>.
The user prompt is skipped if the variable is defined using -D/--define in the command-line arguments.
The user prompt is repeated if the entered value (or the predefined) is not valid (according to the return value of <validation-function>).
The <prompt-message> is printed before each input trial.
If <description> is provided, it will also be shown to the user (only once)."
			exit 11
		}
		[ $# -ge 3 -a $# -le 4 ] ||
			_gperror_ "Incorrect number of arguments."
		local -r var_name="$1"; shift
		local -r validation_command="$1"; shift
		local -r prompt_message="$1"; shift
		local description=""
		local has_description="false"
		if [ $# -ge 1 ]; then
			description="$1"; shift
			has_description="true"
		fi
		readonly description
		readonly has_description
		is_identifier_format "${var_name}" ||
			_gperror_ "Variable name '${var_name}' is not in a valid identifier format."
		command_exists "${validation_command}" ||
			_gperror_ "Validation command '${validation_command}' is not a callable command/function."
		unset -f _gperror_
		# Prompting and validating the variable value
		local prompt_description
		if "${has_description}"; then
			prompt_description=" (${description})"
		else
			prompt_description=""
		fi
		errcho "Template parameter '${var_name}'${prompt_description}..."
		local predef_var="__PREDEFINED_TPS_TEMPLATE_PARAMETER__${var_name}"
		local predefined_value=""
		local has_predefined_value="false"
		if variable_exists "${predef_var}"; then
			predefined_value="${!predef_var}"
			has_predefined_value="true"
		fi
		local is_valid_var_value="false"
		local input_var_value
		local validated_var_value
		until "${is_valid_var_value}"; do
			if "${has_predefined_value}"; then
				errcho "Parameter '${var_name}' has predefined value '${predefined_value}'."
				input_var_value="${predefined_value}"
				predefined_value=""
				has_predefined_value="false"
			else
				errcho "${prompt_message}"
				IFS= read -r input_var_value
			fi
			local validation_return_code=0
			local validation_output
			validation_output="$("${validation_command}" <<< "${input_var_value}")" || validation_return_code=$?
			if [ "${validation_return_code}" -eq 0 ]; then
				is_valid_var_value="true"
				validated_var_value="${validation_output}"
			fi
		done
		set_variable "${var_name}" "${validated_var_value}"
		__PROMPT_CALLED__="true"
	}

	function prompt {
		# Validating function arguments
		function _perror_ {
			errcho -e "\
Error in calling function '${FUNCNAME[1]}' (file: '${source_TTIS_file}', line #${BASH_LINENO[1]}): $1
Usage:
\t${FUNCNAME[1]} <type> <var-name> [<description>]
Prompts for a text of type <type> and stores it in variable <var-name>.
<var-name> must be in identifier format.
Valid variable types for <type>:
 * string: any string of characters
 * identifier: common identifier format in programming languages
 * int, integer: signed integer format
 * uint, unsigned_integer: unsigned integer format
 * decimal: signed decimal format for real numbers
 * udecimal, unsigned_decimal: unsigned decimal format for real numbers
 * bool: boolean values, true (true,yes,y) and false (false,no,n)
 * enum: enum value format.
   The keyword 'enum' must be followed by the enum values in a format like 'enum:value1:value2:value3'.
   The enum values must be in identifier format.
If <description> is provided, it will be shown to the user.
The user prompt is skipped if the variable is defined using -D/--define in the command-line arguments.
The user prompt is repeated if the entered value (or the predefined) is not valid (according to the type)."
			exit 11
		}
		[ $# -ge 2 -a $# -le 3 ] ||
			_perror_ "Incorrect number of arguments."
		local -r var_type="$1"; shift
		local -r var_name="$1"; shift
		local -a _description_arr=()
		if [ $# -ge 1 ]; then
			_description_arr+=("$1"); shift
		fi
		readonly _description_arr
		case "${var_type}" in
			string|identifier|int|integer|uint|unsigned_integer|decimal|udecimal|unsigned_decimal|bool) ;;
			enum:*)
				local enum_values
				IFS=':' read -ra enum_values <<< "${var_type}"
				# Removing the 'enum' keyword from the array
				enum_values=("${enum_values[@]:1}")
				[ ${#enum_values[@]} -ge 1 ] ||
					_perror_ "Enum types must have at least one value."
				local enum_val
				for enum_val in "${enum_values[@]}"; do
					is_identifier_format "${enum_val}" ||
						_perror_ "Enum value '${enum_val}' does not have a valid identifier format."
				done
				local enum_values_str
				enum_values_str="$(sed -e 's/:/, /g' <<< "${var_type:5}")"
				;;
			enum) _perror_ "Enum values are required to be in a format like 'enum:value1:value2:value3'."; ;;
			*) _perror_ "Unknown type: '${var_type}'"; ;;
		esac
		is_identifier_format "${var_name}" ||
			_perror_ "Variable name '${var_name}' is not in a valid identifier format."
		unset -f _perror_

		local pmessage
		case "${var_type}" in
			enum:*) pmessage="Enter a value among {${enum_values_str}} for '${var_name}':"; ;;
			*) pmessage="Enter a value of type '${var_type}' for '${var_name}':"; ;;
		esac
		local val_command
		function _define_simple_val_command {
			__simple_val_command__format_validation_func="$1"; shift
			__simple_val_command__validation_error_msg="$1"; shift
			function val_command {
				local var_value
				var_value="$(cat)"
				if "${__simple_val_command__format_validation_func}" "${var_value}"; then
					echo -n "${var_value}"
					return 0
				else
					errcho "${__simple_val_command__validation_error_msg}"
					return 1
				fi
			}
		}
		case "${var_type}" in
			string)
				function val_command {
					cat
					return 0
				}
				;;
			identifier)
				_define_simple_val_command "is_identifier_format" "Text not in identifier format."
				;;
			int|integer)
				_define_simple_val_command "is_signed_integer_format" "Invalid signed integer value."
				;;
			uint|unsigned_integer)
				_define_simple_val_command "is_unsigned_integer_format" "Invalid unsigned integer value."
				;;
			decimal)
				_define_simple_val_command "is_signed_decimal_format" "Invalid signed decimal value."
				;;
			udecimal|unsigned_decimal)
				_define_simple_val_command "is_unsigned_decimal_format" "Invalid unsigned decimal value."
				;;
			bool)
				function val_command {
					local var_value
					var_value="$(cat)"
					case "${var_value}" in
						true|yes|y)
							echo -n "true"
							return 0
							;;
						false|no|n)
							echo -n "false"
							return 0
							;;
						*)
							errcho "Invalid boolean value. Valid values: true, false, yes, no, y, n"
							return 1
							;;
					esac
				}
				;;
			enum:*)
				function val_command {
					local var_value
					var_value="$(cat)"
					local enum_val
					for enum_val in "${enum_values[@]}"; do
						if [ "${var_value}" == "${enum_val}" ]; then
							echo -n "${var_value}"
							return 0
						fi
					done
					errcho "Invalid enum value. Valid values: ${enum_values_str}"
					return 1
				}
				;;
			*) error_exit 15 "[Illegal state] The program execution must not reach here!"; ;;
		esac

		general_prompt "${var_name}" "val_command" "${pmessage}" ${_description_arr[@]+"${_description_arr[@]}"}
	}

	function generate_random_string {
		# Validating function arguments
		function _gerror_ {
			local -r exit_code="$1"; shift
			local -r msg="$1"; shift
			errcho -e "\
Error in calling function '${FUNCNAME[1]}' (file: '${source_TTIS_file}', line #${BASH_LINENO[1]}): ${msg}
Usage:
\t${FUNCNAME[1]} <string-length> <string-character-set> <random-seed>
Generates a string of length <string-length> with characters of <string-character-set>.
The parameter <string-length> must be a nonnegative integer.
The parameter <random-seed> can be any string."
			exit "${exit_code}"
		}
		[ $# -eq 3 ] ||
			_gerror_ 11 "Incorrect number of arguments."
		local -r len="$1"; shift
		local -r charset="$1"; shift
		local -r random_seed="$1"; shift
		is_unsigned_integer_format "${len}" ||
			_gerror_ 11 "The string length is not a nonnegative integer."

		local -r py_prog="\
import sys
import random

str_len = int(sys.argv[1])
str_charset = sys.argv[2]
rand_seed = sys.argv[3]
random.seed(rand_seed)
print(''.join(random.choice(str_charset) for _ in range(str_len)))
"
		run_python -c "${py_prog}" "${len}" "${charset}" "${random_seed}"
	}

	function clone_template_directory {
		variable_exists "__PROMPT_CALLED__" ||
			errcho "Warning: No task template parameters are prompted in '${source_TTIS_file}'."
		errcho "Copying task template '${task_template_dir}' to the new directory '${output_dir_name}'..."
		cp -R "${task_template_dir}" "${output_dir_name}"
		# Removing task template related files from '${output_dir_name}'
		rm -f "${output_dir_name}/${TTIS_filename}"
		errcho "Done."
		errcho "Entering the new directory '${output_dir_name}'"
		cd "${output_dir_name}"
		__TPS_INIT_CLONE_CALLED__="true"
	}

	function __check_clone_template_directory_called__ {
		[ "${__TPS_INIT_CLONE_CALLED__-false}" == "true" ] ||
			error_exit 12 "Error in calling function '${FUNCNAME[1]}'
Function 'clone_template_directory' is not called yet."
	}

	function py_regex_replace_in_files {
		__check_clone_template_directory_called__
		# Validating function arguments
		[ $# -ge 2 ] ||
			error_exit 11 "Incorrect number of arguments in calling function '${FUNCNAME[0]}'
Usage: ${FUNCNAME[0]} <pattern> <substitute> <file-paths>..."
		local pattern="$1"; shift
		local substitute="$1"; shift
		local -ra file_paths=("$@")

		local file_path
		for file_path in ${file_paths[@]+"${file_paths[@]}"}; do
			[ -e "${file_path}" ] ||
				error_exit 14 "Given file '${file_path}' does not exist."
			[ -f "${file_path}" ] ||
				error_exit 14 "Given file '${file_path}' is not an ordinary file."
		done

		# Adding an extra character to the arguments (and removing it in the python script)
		# in order to suppress the wrong path translation that happens in some environments (like msys).
		pattern="A${pattern}"
		substitute="A${substitute}"

		local -r py_prog="\
import sys
import re

pattern = sys.argv[1]
substitute = sys.argv[2]
file_path = sys.argv[3]
tmp_file_path = sys.argv[4]
pattern = pattern[1:]
substitute = substitute[1:]
with open(file_path, 'r') as infile:
    content = infile.read()
with open(tmp_file_path, 'w', newline='') as outfile:
    outfile.write(re.sub(pattern, substitute, content))
"

		for file_path in ${file_paths[@]+"${file_paths[@]}"}; do
			local tmp_file_path="${file_path}.replace_tmp"
			run_python -c "${py_prog}" "${pattern}" "${substitute}" "${file_path}" "${tmp_file_path}"
			mv "${tmp_file_path}" "${file_path}"
		done
	}

	function __private__escape_sed_substitute_first_arg {
		local -r first_arg="$1"; shift
		# Source: https://stackoverflow.com/a/29613573
		sed -e 's/[^^]/[&]/g' -e 's/\^/\\^/g' <<< "${first_arg}"
		# Alternative: sed -e 's/[]\/$*.^[]/\\&/g' <<< "${first_arg}"
	}

	function __private__escape_sed_substitute_second_arg {
		local -r second_arg="$1"; shift
		sed -e 's/[&\/]/\\&/g' <<< "${second_arg}"
	}

	function __private__replace_in_text__ {
		local -r old_text="$1"; shift
		local -r new_text="$1"; shift
		local -r text_to_change="$1"; shift

		local escaped_old_text
		escaped_old_text="$(__private__escape_sed_substitute_first_arg "${old_text}")"
		readonly escaped_old_text
		local escaped_new_text
		escaped_new_text="$(__private__escape_sed_substitute_second_arg "${new_text}")"
		readonly escaped_new_text
		sed -e "s/${escaped_old_text}/${escaped_new_text}/g" <<< "${text_to_change}"
	}

	function __private__replace_in_file_content__ {
		local -r old_text="$1"; shift
		local -r new_text="$1"; shift
		local -r file_path="$1"; shift

		local escaped_old_text
		escaped_old_text="$(__private__escape_sed_substitute_first_arg "${old_text}")"
		readonly escaped_old_text
		local escaped_new_text
		escaped_new_text="$(__private__escape_sed_substitute_second_arg "${new_text}")"
		readonly escaped_new_text
		# Do not try to delete the backup removal code by omitting '.sed_tmp'.
		# Implementation of 'sed' in GNU (Linux) is different from BSD (Mac).
		# For any change of this code you have to test it both in Linux and Mac.
		sed -i.sed_tmp -e "s/${escaped_old_text}/${escaped_new_text}/g" "${file_path}"
		rm -f "${file_path}.sed_tmp"
	}

	function replace_exact_text {
		# This function does not support replacing multiline texts.
		# Validating function arguments
		[ $# -eq 3 ] ||
			error_exit 11 "Incorrect number of arguments in calling function '${FUNCNAME[0]}'
Usage: ${FUNCNAME[0]} <old-text> <new-text> <text-to-change>"
		local -r old_text="$1"; shift
		local -r new_text="$1"; shift
		local -r text_to_change="$1"; shift

		__private__replace_in_text__ "${old_text}" "${new_text}" "${text_to_change}"
	}

	function replace_in_file_names {
		__check_clone_template_directory_called__
		# Validating function arguments
		[ $# -ge 2 ] ||
			error_exit 11 "Incorrect number of arguments in calling function '${FUNCNAME[0]}'
Usage: ${FUNCNAME[0]} <old-text> <new-text> <file-paths|root-directories>..."
		local -r old_text="$1"; shift
		local -r new_text="$1"; shift
		local -ra root_paths=("$@")

		local root_path
		for root_path in ${root_paths[@]+"${root_paths[@]}"}; do
			[ -f "${root_path}" -o -d "${root_path}" ] ||
				error_exit 14 "File/directory '${root_path}' does not exist."
		done

		local _find
		_find="$(which -a "find" | grep -iv "windows" | head -1)"
		function __private__replace_in_file_name__ {
			local -r old_text="$1"; shift
			local -r new_text="$1"; shift
			local -r file_path="$1"; shift

			local -r file_dir="$(dirname "${file_path}")"
			local -r file_name="$(basename "${file_path}")"
			local new_file_name
			new_file_name="$(__private__replace_in_text__ "${old_text}" "${new_text}" "${file_name}")"
			readonly new_file_name
			local -r new_file_path="${file_dir}/${new_file_name}"
			errcho "Renaming '${file_path}' to '${new_file_path}'"
			mv "${file_path}" "${new_file_path}"
		}
		for root_path in ${root_paths[@]+"${root_paths[@]}"}; do
			if [ -f "${root_path}" ]; then
				errcho "Replacing '${old_text}' with '${new_text}' in name of file '${root_path}'..."
				__private__replace_in_file_name__ "${old_text}" "${new_text}" "${root_path}"
				errcho "Done."
			elif [ -d "${root_path}" ]; then
				errcho "Replacing '${old_text}' with '${new_text}' in all file names under '${root_path}'..."
				"${_find}" "${root_path}" -depth -name "*${old_text}*" | while IFS= read -r file_path; do
					__private__replace_in_file_name__ "${old_text}" "${new_text}" "${file_path}"
				done
				errcho "Done."
			else
				error_exit 15 "[Illegal state] The program execution must not reach here!"
			fi
		done
	}

	function replace_in_file_contents {
		# It does not support replacing multiline texts.
		__check_clone_template_directory_called__
		# Validating function arguments
		[ $# -ge 2 ] ||
			error_exit 11 "Incorrect number of arguments in calling function '${FUNCNAME[0]}'
Usage: ${FUNCNAME[0]} <old-text> <new-text> <file-paths|root-directories>..."
		local -r old_text="$1"; shift
		local -r new_text="$1"; shift
		local -ra root_paths=("$@")

		local root_path
		for root_path in ${root_paths[@]+"${root_paths[@]}"}; do
			[ -f "${root_path}" -o -d "${root_path}" ] ||
				error_exit 14 "File/directory '${root_path}' does not exist."
		done
		for root_path in ${root_paths[@]+"${root_paths[@]}"}; do
			if [ -f "${root_path}" ]; then
				errcho "Replacing '${old_text}' with '${new_text}' in content of file '${root_path}'..."
				__private__replace_in_file_content__ "${old_text}" "${new_text}" "${root_path}"
				errcho "Done."
			elif [ -d "${root_path}" ]; then
				errcho "Replacing '${old_text}' with '${new_text}' in all file contents under '${root_path}'..."
				grep -lrF "${old_text}" "${root_path}" | while IFS= read -r file_path; do
					errcho "Modifying '${file_path}'"
					__private__replace_in_file_content__ "${old_text}" "${new_text}" "${file_path}"
				done
				errcho "Done."
			else
				error_exit 15 "[Illegal state] The program execution must not reach here!"
			fi
		done
	}

	function replace_in_file_names_and_contents {
		# It does not support replacing multiline texts.
		__check_clone_template_directory_called__
		# Validating function arguments
		[ $# -ge 2 ] ||
			error_exit 11 "Incorrect number of arguments in calling function '${FUNCNAME[0]}'
Usage: ${FUNCNAME[0]} <old-text> <new-text> <file-paths|root-directories>..."

		# File contents should be modified before file names
		replace_in_file_contents "$@"
		replace_in_file_names "$@"
	}

	function move_dir_contents {
		__check_clone_template_directory_called__
		# Validating function arguments
		function _merror_ {
			local -r exit_code="$1"; shift
			local -r msg="$1"; shift
			errcho -e "\
Error in calling function '${FUNCNAME[1]}' (file: '${source_TTIS_file}', line #${BASH_LINENO[1]}): ${msg}
Usage:
\t${FUNCNAME[1]} <source-dir> <destination-dir>
Moves all the contents of <source-dir> to <destination-dir>.
The hidden files are also moved.
The <source-dir> is then deleted.
The <source-dir> shall not be the same as, or a direct/indirect parent of <destination-dir>."
			exit "${exit_code}"
		}
		[ $# -eq 2 ] ||
			_merror_ 11 "Incorrect number of arguments."
		local -r source_dir="$1"; shift
		local -r dest_dir="$1"; shift
		[ -d "${source_dir}" ] ||
			_merror_ 12 "Given source directory '${source_dir}' is not a valid directory."
		[ -d "${dest_dir}" ] ||
			_merror_ 12 "Given destination directory '${dest_dir}' is not a valid directory."
		pushdq "${source_dir}"
		local -r source_dir_abs="${PWD}"
		popdq
		pushdq "${dest_dir}"
		local -r dest_dir_abs="${PWD}"
		popdq
		if [ "${source_dir_abs}" == "${dest_dir_abs}" ]; then
			_merror_ 12 "Given source directory '${source_dir}' is the same as the destination directory '${dest_dir}'."
		fi
		if [[ "${dest_dir_abs}" == "${source_dir_abs}"* ]]; then
			_merror_ 12 "Given source directory '${source_dir}' is a direct/indirect parent of the destination directory '${dest_dir}'."
		fi
		local temp_dir="${source_dir}.tmp"
		mv "${source_dir}" "${temp_dir}"
		(shopt -s dotglob; mv "${temp_dir}/"* "${dest_dir}")
		rmdir "${temp_dir}"
	}

	function select_file_by_value {
		__check_clone_template_directory_called__
		# Validating function arguments
		function _serror_ {
			local -r exit_code="$1"; shift
			local -r msg="$1"; shift
			errcho -e "\
Error in calling function '${FUNCNAME[1]}' (file: '${source_TTIS_file}', line #${BASH_LINENO[1]}): ${msg}
Usage:
\t${FUNCNAME[1]} <selected-value> <destination-path> <value1> <file1> <value2> <file2>...
This function gets a <selected-value>, a <destination-path>, and multiple pairs of (<value>, <file>).
If there is a match of the <selected-value> among the <value>s in the pairs, the corresponding <file> in that pair is moved/renamed to <destination-path>.
All <file>s in the non-matching pairs are deleted."
			exit "${exit_code}"
		}
		[ $# -ge 2 ] ||
			_serror_ 11 "At least 2 arguments must be provided."
		[ $(($# % 2)) -eq 0 ] ||
			_serror_ 11 "The number of arguments must be even."
		local -r target_value="$1"; shift
		local -r destination="$1"; shift
		[ ! -e "${destination}" ] ||
			_serror_ 12 "Destination '${destination}' already exists."
		local i ii v f j jj
		for ((i=1; i<=$#; i+=2)); do
			ii=$((i+1))
			v="${!i}"
			f="${!ii}"
			for ((j=1; j<$i; j+=2)); do
				jj=$((j+1))
				[ "${!j}" != "${v}" ] ||
					_serror_ 12 "Multiple appearances of value '${v}' in the arguments."
				[ "${!jj}" != "${f}" ] ||
					_serror_ 12 "Multiple appearances of file '${f}' in the arguments."
			done
			[ -e "${f}" ] ||
				_serror_ 14 "File/Directory '${f}' does not exist."
		done
		for ((i=1; i<=$#; i+=2)); do
			ii=$((i+1))
			v="${!i}"
			f="${!ii}"
			if [ "${v}" == "${target_value}" ]; then
				mv "${f}" "${destination}"
			else
				rm -rf "${f}"
			fi
		done
	}


	set +a

	errcho "Running the instantiation script '${source_TTIS_file}'..."
	TTIS_exit_code=0
	bash "${source_TTIS_file}" || TTIS_exit_code=$?
	if [ "${TTIS_exit_code}" -eq 0 ]; then
		errcho "The instantiation script execution finished successfully."
	else
		errcho "The instantiation script execution failed with exit code ${TTIS_exit_code}."
		exit "${TTIS_exit_code}"
	fi
	[ -d "${output_dir_name}" ] ||
		error_exit 14 "The instantiation script has not created the task directory '${output_dir_name}'."
	errcho "Finished. Task directory '${output_dir_name}' is ready."
}



__tps_target_file__="problem.json"
__tps_scripts__="scripts"

function __tps_find_basedir__ {
	# Looking for ${__tps_target_file__} in current and parent directories...
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
			# Available commands out of a TPS repository
			readonly available_commands="init"
			compgen -W "${available_commands}" -- "${bc_current_token_prefix}" | add_space_all || true
			exit 0
		fi
		# Extracting the command name
		__tps_command__="$1"; shift; ((bc_index--))
		# bc_index >= 1
	fi
	"${__tps_help_mode__}" && __tps__help_exit__ "\
Currently not in a TPS repository ('${__tps_target_file__}' not found in any of the parent directories).
Commands available:
  init
    Initializes a TPS repository for a new task.
"
	if [ "${__tps_command__}" == "init" ]; then
		new_task_init "$@"
		exit 0
	else
		__tps__error_exit__ 2 "Unknown command '${__tps_command__}', and not in a TPS repository ('${__tps_target_file__}' not found in any of the parent directories)."
	fi
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
		__tps__define_python__
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
	ls -a -1 "${__tps_scripts_dir__}" 2> "/dev/null" | grep -E ".\\.(${extensions})$" | while read f; do echo ${f%.*}; done | __tps__unified_sort__ || true
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
$(add_prefix '  ' <<< "${available_commands}")"
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
		__tps_run_file__ "${command_bc_script_file}" "${bc_index}" "${bc_cursor_offset}" "$@"
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

