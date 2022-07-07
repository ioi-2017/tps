
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

function capture_select {
	local -r select_cmd_and_args="$1"; shift
	local -r selected_value="$1"; shift
	local -r select_varname="myvar"

	capture_exec_k -fc "output_dir" run_select_func "template1" "prompt string ${select_varname}" "${select_cmd_and_args}" -- -D "${select_varname}=${selected_value}"
}

echo
capture_select 'select_file_by_value' "aaa"
capture_select 'select_file_by_value "${myvar}"' "aaa"
capture_select 'select_file_by_value "${myvar}" "dest"' "aaa"
capture_select 'select_file_by_value "${myvar}" "dest" "x"' "aaa"
capture_select 'select_file_by_value "${myvar}" "b" "aaa" "aa"' "aaa"
capture_select 'select_file_by_value "${myvar}" "dest" "aaa" "non-exist"' "aaa"
capture_select 'select_file_by_value "${myvar}" "dest" "aaa" "aa" "aaa" "b"' "aaa"
capture_select 'select_file_by_value "${myvar}" "dest" "aaa" "aa" "bbb" "aa"' "aaa"
capture_select 'select_file_by_value "${myvar}" "dest" "aaa" "aa" "bbb" "b"' "aaa"
capture_select 'select_file_by_value "${myvar}" "dest" "aaa" "aa" "bbb" "b"' "bbb"
capture_select 'select_file_by_value "${myvar}" "dest" "aaa" "aa" "bbb" "b"' "oo"

echo
for selected_val in "ad" "bd" "hd" "hf" "tf" "oo"; do
	capture_select 'select_file_by_value "${myvar}" "dest" "ad" "aa" "bd" "b" "hd" ".hdir" "hf" ".h.txt" "tf" "t.txt"' "${selected_val}"
done

echo
for selected_val in "ad" "ah" "af1" "aff" "ay" "bd" "t" "qq"; do
	capture_select 'select_file_by_value "${myvar}" "aa/dest" "ad" "aa/dd" "ah" "aa/.hh" "af1" "aa/f1.in" "aff" "aa/ff" "ay" "aa/y.txt" "bd" "b" "t" "t.txt"' "${selected_val}"
done

echo
capture_exec_k -fc "output_dir" -fc "templates_dir/template2/dir1" -fc "templates_dir/template2/dir2" -fc "templates_dir/template2/dest" \
	run_select_func "template2" "" 'select_file_by_value "a" "dest" "a" "dir1" "b" "dir2"'

end_capturing
popd_test_context
