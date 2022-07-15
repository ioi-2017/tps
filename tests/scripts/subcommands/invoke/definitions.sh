
function replace_invoke_time {
	# Replacing solution execution times in invoke outputs with "ATIME" in order to have a deterministic output.
	local -r out_file="replace_invoke_time.out.tmp"
	local -r err_file="replace_invoke_time.err.tmp"
	local _TT_rit_ret=0
	"$@" > "${out_file}" 2> "${err_file}" || _TT_rit_ret=$?
	function _handle_invoke_time {
		local -r file_name="$1"; shift
		sed 's/\(\][[:blank:]]*\)\([0-9.]\+\)\([[:blank:]]*check\)/\1ATIME\3/g' "${file_name}"
		rm -f "${file_name}"
	}
	_handle_invoke_time "${out_file}"
	>&2 _handle_invoke_time "${err_file}"
	return "${_TT_rit_ret}"
}

function tinvoke {
	_TT_dos2unixify replace_invoke_time tps invoke "$@"
	return $?
}
