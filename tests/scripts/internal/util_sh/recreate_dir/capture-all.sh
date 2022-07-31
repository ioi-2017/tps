
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run source "../definition_source_util_sh.sh"

capture_exec_key_counter=0
function recdir {
    local -r _TT_rdir="$1"; shift
    capture_exec "k-$((capture_exec_key_counter++))" -fc "${_TT_rdir}" recreate_dir "${_TT_rdir}"
}

echo
capture_run stage_dir "stage"
recdir ".hdir"
recdir "aa/dd"
recdir "aa/d-new"
recdir "aa/.h2"
recdir "aa"
recdir "b"
recdir "a_new_dir"
recdir "b1/b2"
recdir "c1/c2/c3"
recdir "d1/.d2/d3/d4"
recdir "d1/.d2/d5/d6"
capture_run_in_stage mkdir "e1"
recdir "e1"
capture_run_in_stage mkdir ".a_hidden_dir"
recdir ".a_hidden_dir"

echo
capture_run stage_dir "stage"
recdir "aa"
recdir "another_new_dir"
recdir ".another_hidden_dir"

end_capturing
popd_test_context
