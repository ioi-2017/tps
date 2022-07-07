set -euo pipefail

clone_template_directory

rep_counter=0

function run_replace {
	local -r pattern_str="$1"; shift
	local -r substitute_str="$1"; shift

	local -r file_name="c-$((rep_counter++))"
	{
		echo "${pattern_str}"
		echo "${substitute_str}"
		echo "${in_file}"
	} > "${file_name}.args"
	cp "${in_file}" "${file_name}.txt"
	py_regex_replace_in_files "${pattern_str}" "${substitute_str}" "${file_name}.txt"
}

in_file="c1.in"

run_replace 'hi' 'bye'
run_replace 'hi+' 'bye'
run_replace 'h+i' 'bye'
run_replace 'h+i+' 'bye'
run_replace 'a b' 'ASB'
run_replace 'a\tb' 'ASB'
run_replace 'a\nb' 'ASB'
run_replace 'a\sb' 'ASB'
run_replace 'a\s*b' 'ASB'
run_replace 'xy*z' 'XYZ'
run_replace 'xy+z' 'XYZ'

run_replace '/def' 'U'
run_replace '/def/' 'U'
run_replace '/def/g' 'U'
run_replace '//def' 'U'
run_replace '/\\def' 'U'
run_replace 'c/def' 'U'
run_replace 'c//def' 'U'
run_replace 'c\\def' 'U'
run_replace '/' 'U'
run_replace '//' 'U'
run_replace '\\' 'U'
run_replace '/(def)/' 'P\1Q'
