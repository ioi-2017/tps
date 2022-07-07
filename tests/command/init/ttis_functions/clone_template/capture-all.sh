
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

function capture_clone {
	local -r template_name="$1"; shift
	local output_dir_name="a_new_dir"
	capture_exec_k -fc "${output_dir_name}" -fc "templates_dir/${template_name}" -ih 1 run_clone "${template_name}" "${output_dir_name}" "with_prompt" "$@"
	capture_exec_k -fc "${output_dir_name}" -fc "templates_dir/${template_name}" run_clone "${template_name}" "${output_dir_name}" "with_prompt" "$@" -- --define a_variable=5
	output_dir_name="another_new_dir"
	capture_exec_k -fc "${output_dir_name}" -fc "templates_dir/${template_name}" run_clone "${template_name}" "${output_dir_name}" "$@"
}

echo
capture_clone "default"
capture_clone "empty"
capture_clone "single"

end_capturing
popd_test_context
