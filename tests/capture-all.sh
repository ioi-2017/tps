
set -euo pipefail

pushdq_here

run_bash_on "*/capture-all.sh" "$@"

popdq
