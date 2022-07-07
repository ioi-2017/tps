set -euo pipefail


set -a

function unify_mid_lines {
	# Unifying the output to prevent test failures due to the nondeterministic ordering of the files.
	function _sort {
		local _sort_cmd
		_sort_cmd="$(which -a "sort" | grep -iv "windows" | head -1)"
		readonly _sort_cmd
		if [ -z "${_sort_cmd}" ]; then
			echo "Command 'sort' not found."
			exit 14
		fi
		LC_ALL=C "${_sort_cmd}" "$@"
	}

	local mid=""
	function flush_mid {
		[ -z "${mid}" ] ||
			_sort <<< "${mid}"
		mid=""
	}

	local -r new_line=$'\n'
	local line
	while IFS= read -r line; do
		if [[ "${line}" == Modifying* ]] || [[ "${line}" == Renaming* ]]; then
			if [ -z "${mid}" ]; then
				mid="${line}"
			else
				mid="${mid}${new_line}${line}"
			fi
		else
			flush_mid
			echo "${line}"
		fi
	done
	flush_mid
}

function replace_in_file_names__unified {
	replace_in_file_names "$@" 2>&1 | unify_mid_lines >&2
}

function replace_in_file_contents__unified {
	replace_in_file_contents "$@" 2>&1 | unify_mid_lines >&2
}

function replace_in_file_names_and_contents__unified {
	replace_in_file_names_and_contents "$@" 2>&1 | unify_mid_lines >&2
}

set +a


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

