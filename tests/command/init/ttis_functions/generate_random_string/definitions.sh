set -euo pipefail

function run_plain_gen {
	local -r gen_str="$1"; shift
	local -r out_dir_name="new-dir"
	local -r template_name="template1"
	local -r templates_dir="templates_dir"
	local -r TTIS_filepath="${templates_dir}/${template_name}/task-template-instantiate.sh"
	_TT_replace_in_file "_GEN_PLACEHOLDER_" "${gen_str}" "${TTIS_filepath}"
	run_ttis "${TTIS_filepath}" -T "${templates_dir}" -t "${template_name}" "${out_dir_name}" "$@"
}
