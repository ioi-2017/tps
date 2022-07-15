
function get_head {
	local -r stdout_lines="$1"; shift
	local -r stderr_lines="$1"; shift
	local -r out_file="get_head.out.tmp"
	local -r err_file="get_head.err.tmp"
	local _TT_gh_ret=0
	"$@" > "${out_file}" 2> "${err_file}" || _TT_gh_ret=$?
	function _get_head_handle {
		local -r num_lines="$1"; shift
		local -r file_name="$1"; shift
		if ((${num_lines} >= 0)); then
			head -${num_lines} "${file_name}"
		else
			cat "${file_name}"
		fi
		rm -f "${file_name}"
	}
	_get_head_handle "${stdout_lines}" "${out_file}"
	>&2 _get_head_handle "${stderr_lines}" "${err_file}"
	return "${_TT_gh_ret}"
}
