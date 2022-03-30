
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run stage_dir "stage"

echo
capture_exec "no-cmd" tps
capture_exec "no-cmd-d" -d "a_dir" tps
capture_exec "cmd" tps a_command
capture_exec "cmd-d" -d "a_dir" tps a_command
capture_exec "cmd-p" tps a_command a_param
capture_exec "cmd-p-d" -d "a_dir" tps a_command a_param

echo
capture_exec "bc-0" tps_bc 1 0
capture_exec "bc-1-0" tps_bc 1 0 a_command
capture_exec "bc-1-1" tps_bc 1 1 a_command
capture_exec "bc-2-0" tps_bc 1 0 a_command a_param
capture_exec "bc-2-1" tps_bc 1 1 a_command a_param
capture_exec "bc-3-0" tps_bc 1 0 i_command
capture_exec "bc-3-1" tps_bc 1 1 i_command
capture_exec "bc-3-2" tps_bc 1 2 i_command
capture_exec "bc-4-0" tps_bc 1 0 i_command a_param
capture_exec "bc-4-1" tps_bc 1 1 i_command a_param
capture_exec "bc-4-2" tps_bc 1 2 i_command a_param
capture_exec "bc-5-0" tps_bc 2 0 i_command a_param
capture_exec "bc-5-1" tps_bc 2 1 i_command a_param

end_capturing
popd_test_context
