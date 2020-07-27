
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run stage_dir '"stage-without-init"'
echo
capture_exec "no-cmd-wo" tps
capture_exec "show-wo" tps show
echo
capture_run stage_dir '"stage-with-init"'
echo
capture_exec "no-cmd-w" tps
capture_exec "show-w" tps show

end_capturing
popd_test_context
