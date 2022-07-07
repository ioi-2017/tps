set -euo pipefail

function run_plain_prompt {
	local -r prompt_str="$1"; shift
	local -r out_dir_name="new-dir"
	local -r template_name="template1"
	local -r templates_dir="templates_dir"
	local -r TTIS_filepath="${templates_dir}/${template_name}/task-template-instantiate.sh"
	_TT_replace_in_file "_PROMPT_PLACEHOLDER_" "${prompt_str}" "${TTIS_filepath}"
	run_ttis "${TTIS_filepath}" -T "${templates_dir}" -t "${template_name}" "${out_dir_name}" "$@"
}

function run_prompt {
	local -r var_type="$1"; shift
	local -r var_name="$1"; shift
	local var_desc_optional=""
	if [ $# -gt 0 ]; then
		if [ "$1" != "--" ]; then
			var_desc_optional="'$1'"; shift
		fi
	fi
	readonly var_desc_optional

	if [ $# -gt 0 ]; then
		if [ "$1" == "--" ]; then
			shift
		else
			_TT_error_exit 3 "invalid argument '$1'"
		fi
	fi

	local -r out_dir_name="new-dir"
	local -r template_name="default"
	local -r templates_dir="templates_dir"
	local -r TTIS_filepath="${templates_dir}/${template_name}/task-template-instantiate.sh"
	_TT_replace_in_file "_VAR_NAME_PLACEHOLDER_" "${var_name}" "${TTIS_filepath}"
	_TT_replace_in_file "_VAR_TYPE_PLACEHOLDER_" "${var_type}" "${TTIS_filepath}"
	_TT_replace_in_file "_VAR_DESCRIPTION_PLACEHOLDER_" "${var_desc_optional}" "${TTIS_filepath}"

	run_ttis "${TTIS_filepath}" -T "${templates_dir}" -t "${template_name}" "${out_dir_name}" "$@"
}
