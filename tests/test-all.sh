
set -euo pipefail

_TT_pushdq_here

run_bash_on "*/test-all.sh" "$@"

_TT_popdq
