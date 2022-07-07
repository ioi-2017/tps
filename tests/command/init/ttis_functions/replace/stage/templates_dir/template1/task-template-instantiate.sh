set -euo pipefail

clone_template_directory

rep_counter=0

function run_replace {
	local -r replaced_str="$1"; shift
	local -r replacing_str="$1"; shift

	local -r file_name="c-$((rep_counter++))"
	{
		echo "${replaced_str}"
		echo "${replacing_str}"
		echo "${in_file}"
	} > "${file_name}.args"
	local content_to_change
	content_to_change="$(cat "${in_file}")"
	replace_exact_text "${replaced_str}" "${replacing_str}" "${content_to_change}" > "${file_name}.out"
	cp "${in_file}" "${file_name}.txt"
	replace_in_file_contents "${replaced_str}" "${replacing_str}" "${file_name}.txt"
	diff "${file_name}.txt" "${file_name}.out"
}

in_file="c1.in"

run_replace 'hi' 'bye'
run_replace 'hi$' 'bye'
run_replace '^hi' 'bye'
run_replace '^hi$' 'bye'
run_replace 'hi\$' 'bye'
run_replace '(hi)' 'bye'

run_replace 'hi' 'bye&'
run_replace 'hi' '&bye'
run_replace 'hi' '&'
run_replace 'hi' '\&'
run_replace 'hi' '\\'
run_replace '\(hi\)' 'c\1'



rep_counter=0

function run_replace_dir {
	local -r replaced_str="$1"; shift
	local -r replacing_str="$1"; shift

	local -r dir_name="d-$((rep_counter++))"
	{
		echo "${replaced_str}"
		echo "${replacing_str}"
		echo "${in_dir}"
	} > "${dir_name}.args"
	cp -R "${in_dir}" "${dir_name}"
	replace_in_file_contents__unified "${replaced_str}" "${replacing_str}" "${dir_name}"
}

in_dir="in_dir1"

run_replace_dir 'hi' 'bye'
run_replace_dir 'hi$' 'bye'
run_replace_dir '^hi' 'bye'
run_replace_dir '^hi$' 'bye'
run_replace_dir 'hi\$' 'bye'
