
set -euo pipefail

index="$1"; shift
[ ${index} -gt 0 ] || exit 0

readonly cursor_location="$1"; shift
[ ${cursor_location} -ge 0 ] || exit 0

if [ "${index}" -le $# ]; then
	readonly current_token="${!index}"
else
	readonly current_token=""
fi
readonly current_token_prefix="${current_token:0:${cursor_location}}"


function _unified_sort {
	local _sort
	_sort=$(which -a "sort" | grep -iv "windows" | head -1)
	readonly _sort
	if [ -n "${_sort}" ] ; then
		"${_sort}" -u "$@"
	else
		cat "$@"
	fi
}

function _add_space_options {
	local tmp
	while read -r tmp; do
		if [[ ${tmp} != *= ]]; then
			printf '%s \n' "${tmp}"
		else
			printf '%s\n' "${tmp}"
		fi
	done
}

function _fix_file_endings {
	local tmp
	while read -r tmp; do
		if [ -d "${tmp}" ]; then
			printf '%s/\n' "${tmp}"
		else
			printf '%s \n' "${tmp}"
		fi
	done
}

function _complete_with_files {
	compgen -f -- "$1" | _unified_sort | _fix_file_endings || true
}

if [[ ${current_token_prefix} == --*=* ]]; then
	_complete_with_files "${current_token_prefix#*=}"
else
	compgen -W "--hello --type=" -- "${current_token_prefix}" | _add_space_options || true
	_complete_with_files "${current_token_prefix}"
fi
