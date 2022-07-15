
set -euo pipefail

pushd_test_context_here

run_bash_on "*/test-all.sh" "$@"

popd_test_context
