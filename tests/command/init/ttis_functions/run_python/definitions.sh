set -euo pipefail


function run_init_run_python {
	local py_progs=()
	local py_prog
	while [ $# -gt 0 ]; do
		py_prog="$1"; shift
		[ "${py_prog}" != "--" ] || break
		py_progs+=("${py_prog}")
	done

	local py_args=()
	local py_arg
	while [ $# -gt 0 ]; do
		py_arg="$1"; shift
		[ "${py_arg}" != "--" ] || break
		py_args+=("${py_arg}")
	done

	local which_bash
	which_bash="$(which bash)"
	readonly which_bash

	local which_echo
	which_echo="$(which echo)"
	readonly which_echo

	local -r path_dir_name="the_path_dir"
	local absolute_path_dir
	absolute_path_dir="$(_TT_absolute_path "${path_dir_name}")"
	readonly absolute_path_dir

	mkdir "${path_dir_name}"

	for py_prog in ${py_progs[@]+"${py_progs[@]}"}; do
		local py_prog_file="${path_dir_name}/${py_prog}"
		cp "python_program_template" "${py_prog_file}"
		_TT_replace_in_file "_BASH_SHEBANG_PLACEHOLDER_" "${which_bash}" "${py_prog_file}"
		_TT_replace_in_file "_ECHO_PLACEHOLDER_" "${which_echo}" "${py_prog_file}"
		_TT_replace_in_file "_PROGRAM_NAME_PLACEHOLDER_" "${py_prog}" "${py_prog_file}"
		chmod +x "${py_prog_file}"
	done

	local -r out_dir_name="new-dir"
	local -r template_name="default"
	local -r templates_dir="templates_dir"
	local -r TTIS_filepath="${templates_dir}/${template_name}/task-template-instantiate.sh"
	_TT_replace_in_file "_PATH_PLACEHOLDER_" "${absolute_path_dir}" "${TTIS_filepath}"
	_TT_replace_in_file "_ARGS_PLACEHOLDER_" "${py_args[*]-}" "${TTIS_filepath}"

	run_ttis "${TTIS_filepath}" -T "${templates_dir}" -t "${template_name}" "${out_dir_name}" "$@"
}
