
readonly runnable_extensions=("sh" "py" "exe")

function run_file {
	local -r file2run="$1"; shift
	local -r ext="${file2run##*.}"
	if [ "${ext}" == "sh" ]; then
		bash "${file2run}" "$@"
	elif [ "${ext}" == "py" ]; then
		"${PYTHON}" "${file2run}" "$@"
	elif [ "${ext}" == "exe" ]; then
		"${file2run}" "$@"
	else
		errcho "Unknown extension '${ext}' for running (illegal state)."
        exit 3
	fi
}

function filter_files_as_runnable_commands {
	local extensions=""
	for ext in "${runnable_extensions[@]}"; do
		[ -n "${extensions}" ] && extensions="${extensions}|"
		extensions="${extensions}${ext}"
	done
	local f
    grep -E ".\\.(${extensions})$" | while read f; do echo "${f%.*}"; done | unified_sort || true
}

function find_runnable_file {
	local -r cmd="$1"; shift
	local -r dir="$1"; shift
	local ext
	for ext in "${runnable_extensions[@]}"; do
		local file_name="${cmd}.${ext}"
		if [ -f "${dir}/${file_name}" ]; then
			echo "${file_name}"
			return
		fi
	done
}

function searched_runnable_files {
	local -r cmd="$1"; shift
	local -r dir="$1"; shift
	local ext
	for ext in "${runnable_extensions[@]}"; do
		echo "${cmd}.${ext}"
	done
}

function searched_runnable_files_str {
    local f
    local delim=""
    searched_runnable_files "$@" | while read f; do
        printf "%s'%s'" "${delim}" "${f}"
        delim=", "
    done
}
