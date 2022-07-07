set -euo pipefail


function run_replace_func {
	local -r template_name="$1"; shift
	local -r prompt_str="$1"; shift
	local -r replace_str="$1"; shift
	if [ $# -gt 0 ]; then
		if [ "$1" == "--" ]; then
			shift
		else
			_TT_error_exit 3 "invalid argument '$1'"
		fi
	fi

	local -r out_dir_name="output_dir"
	local -r templates_dir="templates_dir"
	local -r TTIS_filepath="${templates_dir}/${template_name}/task-template-instantiate.sh"
	_TT_replace_in_file "_PROMPT_PLACEHOLDER_" "${prompt_str}" "${TTIS_filepath}"
	_TT_replace_in_file "_MODIFICATION_PLACEHOLDER_" "${replace_str}" "${TTIS_filepath}"

	run_ttis "${TTIS_filepath}" -T "${templates_dir}" -t "${template_name}" "${out_dir_name}" "$@"
}

