
set -euo pipefail

pushd_test_context_here
begin_capturing

echo

capture_run source "../../definitions.sh"
capture_run source "../definitions.sh"
capture_run source "definitions.sh"

echo
capture_run _TT_check_stage_not_in_a_tps_repo

capture_exec_key_counter=0
function capture_exec_k {
	echo
	capture_run stage_dir "stage"
	capture_exec "k-$((capture_exec_key_counter++))" "$@"
}

echo
capture_exec_k -fc "output_dir" run_ttis "templates_dir/template1/task-template-instantiate.sh" -T "templates_dir" -t "template1" "output_dir" "$@"

function capture_replace {
	local -r replace_args="$1"; shift
	local -r replaced_value="$1"; shift

	local replace_cmd_and_args
	if [ -z "${replace_args}" ]; then
		replace_cmd_and_args="${replace_cmd}"
	else
		replace_cmd_and_args="${replace_cmd} ${replace_args}"
	fi
	readonly replace_cmd_and_args
	capture_exec_k -fc "output_dir" run_replace_func 'template2' "prompt string ${replace_varname}" "${replace_cmd_and_args}" -- -D "${replace_varname}=${replaced_value}"
}

function capture_replace_before_clone {
	local -r replace_cmd_and_args="$1"; shift
	echo
	capture_exec_k -fc "output_dir" -fc "templates_dir/template3/dir1" run_replace_func 'template3' "" "${replace_cmd_and_args}"
}

replace_varname="myvar"

echo
replace_cmd='replace_in_file_names__unified'
capture_replace '' "trs2"
capture_replace '"str1"' "trs2"
capture_replace '"str1" "${myvar}"' "trs2"
capture_replace '"str1" "${myvar}" "vis"' "trs2"
capture_replace '"str1" "${myvar}" "vis" "non-exist"' "trs2"
capture_replace '"str1" "${myvar}" "."' "trs2"
capture_replace '"str1" "${myvar}" "vis" ".str1"' "trs.2"
capture_replace '"str1" "${myvar}" ".str1.py" "str1/.str1.sh"' "trs.2"
capture_replace '"str1.py" "${myvar}" "."' "trs2.py"

echo
replace_cmd='replace_in_file_contents__unified'
capture_replace '' "trs2"
capture_replace '"str1"' "trs2"
capture_replace '"str1" "${myvar}"' "trs2"
capture_replace '"str1" "${myvar}" "vis"' "trs2"
capture_replace '"str1" "${myvar}" "vis" "non-exist"' "trs2"
capture_replace '"str1" "${myvar}" "."' "trs2"
capture_replace '"str1" "${myvar}" "vis" ".str1"' "trs.2"
capture_replace '"str1" "${myvar}" ".str1.py" "str1/.str1.sh"' "trs.2"

echo
replace_cmd='replace_in_file_names_and_contents__unified'
capture_replace '' "trs2"
capture_replace '"str1"' "trs2"
capture_replace '"str1" "${myvar}"' "trs2"
capture_replace '"str1" "${myvar}" "vis"' "trs2"
capture_replace '"str1" "${myvar}" "vis" "non-exist"' "trs2"
capture_replace '"str1" "${myvar}" "."' "trs2"
capture_replace '"str1" "${myvar}" "vis" ".str1"' "trs.2"
capture_replace '"str1" "${myvar}" ".str1.py" "str1/.str1.sh"' "trs.2"
capture_replace '"str1.py" "${myvar}" "."' "trs2.py"

capture_replace_before_clone 'replace_in_file_names "str" "rep" "dir1"'

capture_replace_before_clone 'replace_in_file_contents "str" "rep" "dir1"'

capture_replace_before_clone 'replace_in_file_names_and_contents "str" "rep" "dir1"'

end_capturing
popd_test_context
