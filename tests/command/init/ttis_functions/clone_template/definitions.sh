set -euo pipefail


function run_clone {
	local -r template_name="$1"; shift
	local -r out_dir_name="$1"; shift
	local with_prompt="false"
	if [ $# -gt 0 ] && [ "$1" == "with_prompt" ]; then
		with_prompt="true"
		shift
	fi
	if [ $# -gt 0 ]; then
		if [ "$1" == "--" ]; then
			shift
		else
			_TT_error_exit 3 "invalid argument '$1'"
		fi
	fi

	local -r templates_dir="templates_dir"
	local -r TTIS_filepath="${templates_dir}/${template_name}/task-template-instantiate.sh"
	if "${with_prompt}"; then
		_TT_replace_in_file "_PROMPT_PLACEHOLDER_" 'prompt "int" "a_variable"' "${TTIS_filepath}"
		_TT_replace_in_file "_MODIFICATION_PLACEHOLDER_" 'echo "${a_variable}" > "result.txt"' "${TTIS_filepath}"
	else
		_TT_replace_in_file "_PROMPT_PLACEHOLDER_" '# Having no prompt' "${TTIS_filepath}"
		_TT_replace_in_file "_MODIFICATION_PLACEHOLDER_" 'echo "Nothing" > "result.txt"' "${TTIS_filepath}"
	fi

	run_ttis "${TTIS_filepath}" -T "${templates_dir}" -t "${template_name}" "${out_dir_name}" "$@"
}

