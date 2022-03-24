
set -euo pipefail

_TT_pushdq_here

run_bash_on "*/capture-all.sh" "$@"

_TT_popdq
