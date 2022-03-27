

function tps {
	bash -euo pipefail "${PROJECT_ROOT}/tps.sh" "$@"
}

function tps_bc {
	if [ $# -lt 2 ]; then
		_TT_errcho "tps_bc: At least 2 parameters 'index' and 'cursor_location' are required."
		return 3
	fi
	local -r index="$1"; shift
	local -r cursor_location="$1"; shift
	tps "--bash-completion" "${index}" "${cursor_location}" "tps" "$@"
}

PROJECT_SCRIPTS_DIR="${PROJECT_ROOT}/scripts"
