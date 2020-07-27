
set -euo pipefail

pushdq_here

run_bash_on "*/test-all.sh" "$@"

popdq
