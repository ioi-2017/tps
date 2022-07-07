
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

function capture_move {
	local -r dest_dir="$1"; shift
	local -r move_cmd_and_args="$1"; shift

	capture_exec_k -fc "output_dir" run_move_func "template1" "${dest_dir}" "${move_cmd_and_args}"
}

echo
capture_move "" 'move_dir_contents'
capture_move "" 'move_dir_contents "aa"'
capture_move "" 'move_dir_contents "aa" "b" "extra"'
capture_move "" 'move_dir_contents "non-exist" "b"'
capture_move "" 'move_dir_contents "aa/ff" "b"'
capture_move "" 'move_dir_contents "b" "non-exist"'
capture_move "" 'move_dir_contents "b" "aa/ff"'
capture_move "" 'move_dir_contents ".hdir" ".hdir"'
capture_move "" 'move_dir_contents "b" "b"'
capture_move "" 'move_dir_contents "aa" "aa"'
capture_move "" 'move_dir_contents "aa" "aa/dd"'
capture_move "" 'move_dir_contents "aa/dd" "aa/dd"'

echo
capture_move "" 'move_dir_contents ".hdir" "b"'
capture_move "" 'move_dir_contents ".hdir" "aa"'
capture_move "" 'move_dir_contents ".hdir" "aa/dd"'
capture_move "" 'move_dir_contents "b" ".hdir"'
capture_move "" 'move_dir_contents "b" "aa"'
capture_move "" 'move_dir_contents "b" "aa/dd"'
capture_move "" 'move_dir_contents "aa" ".hdir"'
capture_move "" 'move_dir_contents "aa" "b"'
capture_move "" 'move_dir_contents "aa/dd" ".hdir"'
capture_move "" 'move_dir_contents "aa/dd" "b"'
capture_move "" 'move_dir_contents "aa/dd" "aa"'
capture_move "dest" 'move_dir_contents ".hdir" "dest"'
capture_move "dest" 'move_dir_contents "b" "dest"'
capture_move "dest" 'move_dir_contents "aa" "dest"'
capture_move "dest" 'move_dir_contents "aa/dd" "dest"'

echo
capture_exec_k -fc "output_dir" -fc "templates_dir/template2/dir1" -fc "templates_dir/template2/dir2" \
	run_move_func "template2" "" 'move_dir_contents "dir1" "dir2"'

end_capturing
popd_test_context
