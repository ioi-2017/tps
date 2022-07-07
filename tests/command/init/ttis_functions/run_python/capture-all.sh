
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

function capture_run_python {
	echo
	capture_run stage_dir "stage"
	capture_exec "k-$((capture_exec_key_counter++))" run_init_run_python "$@"
}

function capture_different_configs {
	local p p3 mp args
	for p in "" "python"; do
		for p3 in "" "python3"; do
			for mp in "" "my_prog"; do
				for args in "" "-- abc"; do
					capture_run_python ${p} ${p3} ${mp} ${args}
				done
			done
		done
	done
}

echo
capture_run unset PYTHON

capture_different_configs

echo
capture_run export PYTHON=my_prog

capture_different_configs

end_capturing
popd_test_context
