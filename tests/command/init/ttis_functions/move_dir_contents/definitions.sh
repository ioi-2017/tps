set -euo pipefail


function run_move_func {
	local -r template_name="$1"; shift
	local -r dest_dir="$1"; shift
	local -r move_str="$1"; shift
	[ $# -eq 0 ] ||
		_TT_error_exit 3 "invalid argument '$1'"

	local -r prompt_str="prompt string a_var"
	local -r out_dir_name="output_dir"
	local -r templates_dir="templates_dir"
	local -r TTIS_filepath="${templates_dir}/${template_name}/task-template-instantiate.sh"
	_TT_replace_in_file "_PROMPT_PLACEHOLDER_" "${prompt_str}" "${TTIS_filepath}"
	if [ -z "${dest_dir}" ]; then
		_TT_replace_in_file "_MKDIR_PLACEHOLDER_" "" "${TTIS_filepath}"
	else
		_TT_replace_in_file "_MKDIR_PLACEHOLDER_" "mkdir -p '${dest_dir}'" "${TTIS_filepath}"
	fi
	_TT_replace_in_file "_MOVE_PLACEHOLDER_" "${move_str}" "${TTIS_filepath}"

	run_ttis "${TTIS_filepath}" -T "${templates_dir}" -t "${template_name}" "${out_dir_name}" -D "a_var=a_value"
}
