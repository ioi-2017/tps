set -euo pipefail


function _TT_escape_sed_substitute_first_arg {
	local -r first_arg="$1"; shift
	# Source: https://stackoverflow.com/a/29613573
	sed -e 's/[^^]/[&]/g' -e 's/\^/\\^/g' <<<"${first_arg}"
	# Alternative: sed -e 's/[]\/$*.^[]/\\&/g' <<<"${first_arg}"
}

function _TT_escape_sed_substitute_second_arg {
	local -r second_arg="$1"; shift
	sed -e 's/[&\/]/\\&/g' <<<"${second_arg}"
}

function _TT_replace_in_text {
	[ $# -eq 3 ] ||
		_TT_test_error_exit 3 "Usage: _TT_replace_in_text <old_text> <new_text> <text_to_change>"
	local -r old_text="$1"; shift
	local -r new_text="$1"; shift
	local -r text_to_change="$1"; shift

	local escaped_old_text
	escaped_old_text="$(_TT_escape_sed_substitute_first_arg "${old_text}")"
	readonly escaped_old_text
	local escaped_new_text
	escaped_new_text="$(_TT_escape_sed_substitute_second_arg "${new_text}")"
	readonly escaped_new_text
	echo "${text_to_change}" | sed -e "s/${escaped_old_text}/${escaped_new_text}/g"
}

function _TT_replace_in_file {
	[ $# -ge 2 ] ||
		_TT_test_error_exit 3 "Usage: _TT_replace_in_file <old_text> <new_text> <file_paths>..."
	local -r old_text="$1"; shift
	local -r new_text="$1"; shift
	local -ra file_paths=("$@")

	local escaped_old_text
	escaped_old_text="$(_TT_escape_sed_substitute_first_arg "${old_text}")"
	readonly escaped_old_text
	local escaped_new_text
	escaped_new_text="$(_TT_escape_sed_substitute_second_arg "${new_text}")"
	readonly escaped_new_text
	local file_path
	for file_path in ${file_paths[@]+"${file_paths[@]}"}; do
		# Do not try to delete the backup removal code by omitting '.sed_tmp'.
		# Implementation of 'sed' in GNU (Linux) is different from BSD (Mac).
		# For any change of this code you have to test it both in Linux and Mac.
		sed -i.sed_tmp -e "s/${escaped_old_text}/${escaped_new_text}/g" "${file_path}"
		rm -f "${file_path}.sed_tmp"
	done
}


function run_ttis {
	local TTIS_filepath="$1"; shift

	local -r start_line_marker="============ TTIS START ============"
	local -r finish_line_marker="============ TTIS FINISH ============"

	local -r orig_name="task-template-instantiate.orig-ttis.sh"
	local orig_path
	orig_path="$(dirname "${TTIS_filepath}")/${orig_name}"
	mv "${TTIS_filepath}" "${orig_path}"
	{
		echo -n '
echo "_START_LINE_PLACEHOLDER_"
>&2 echo "_START_LINE_PLACEHOLDER_"

ret=0
orig_ttis="$(dirname "$0")/'; echo -n "${orig_name}"; echo -n '"
bash "${orig_ttis}" || ret=$?

echo "_FINISH_LINE_PLACEHOLDER_"
>&2 echo "_FINISH_LINE_PLACEHOLDER_"

rm -f "${output_dir_name}/'; echo -n "${orig_name}"; echo -n '"

exit "${ret}"
'
	} > "${TTIS_filepath}"

	_TT_replace_in_file "_START_LINE_PLACEHOLDER_" "${start_line_marker}" "${TTIS_filepath}"
	_TT_replace_in_file "_FINISH_LINE_PLACEHOLDER_" "${finish_line_marker}" "${TTIS_filepath}"

	local ret=0
	tps init "$@" > "tps-init-temp.out"  2> "tps-init-temp.err" || ret=$?

	function print_ttis_portion {
		local -r filename="$1"; shift

		local start_line_number
		start_line_number="$(grep -n "${start_line_marker}" "${filename}" | cut -d: -f1 | head -1)"
		if [ -z "${start_line_number}" ]; then
			cat "${filename}"
			return 0
		fi
		_TT_increment "start_line_number"
		local finish_line_number
		finish_line_number="$(grep -n "${finish_line_marker}" "${filename}" | cut -d: -f1 | tail -1)"
		if [ -n "${finish_line_number}" ]; then
			sed -n "${start_line_number},${finish_line_number}p;$((finish_line_number+1))q" "${filename}" |
				head --bytes=-$((${#finish_line_marker}+1))
		else
			sed -n "${start_line_number},\$p" "${filename}"
		fi
	}
	print_ttis_portion "tps-init-temp.out"
	print_ttis_portion "tps-init-temp.err" >&2
	return "${ret}"
}
