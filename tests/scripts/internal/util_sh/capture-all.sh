
set -euo pipefail

pushd_test_context_here

run_bash_on "*/capture-all.sh" "$@"

popd_test_context
