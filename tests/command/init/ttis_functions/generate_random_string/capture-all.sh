
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

function capture_gen {
	local -r gen_cmd_and_args="$1"; shift
	capture_exec_k run_plain_gen "${gen_cmd_and_args}"
}


capture_gen 'generate_random_string'
capture_gen 'generate_random_string "1"'
capture_gen 'generate_random_string "1" "a" "s" "extra"'
capture_gen 'generate_random_string "x" "a" "s"'
capture_gen 'generate_random_string "-1" "a" "s"'

echo
capture_gen 'generate_random_string "0" "a" "s"'
capture_gen 'generate_random_string "1" "a" "s"'
capture_gen 'generate_random_string "2" "a" "s"'

echo
template_name="template2"
templates_dir="templates_dir"
TTIS_filepath="${templates_dir}/${template_name}/task-template-instantiate.sh"
capture_exec_k run_ttis "${TTIS_filepath}" -T "${templates_dir}" -t "${template_name}" "new-dir"

end_capturing
popd_test_context
