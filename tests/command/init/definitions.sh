set -euo pipefail

function _TT_check_stage_not_in_a_tps_repo {
	local -r target_file="problem.json"
	# Looking for ${target_file} in stage and its parent directories...
	local curr_dir="${_TT_STAGE}"
	curr_dir="$(dirname "${curr_dir}")"
	local prev_dir=""
	while [ "${curr_dir}" != "${prev_dir}" ]; do
		if [ -f "${curr_dir}/${target_file}" ]; then
			_TT_errcho "\
The testing stage is in a tps repository.
'${target_file}' was found in '${curr_dir}'."
			exit 20
		fi
		prev_dir="${curr_dir}"
		curr_dir="$(dirname "${curr_dir}")"
	done
}
