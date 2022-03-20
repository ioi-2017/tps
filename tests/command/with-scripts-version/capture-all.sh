
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run stage_dir "stage"
echo
capture_exec "no-arg" tps

end_capturing
popd_test_context
