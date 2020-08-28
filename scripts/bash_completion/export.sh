#!/bin/bash

# Smart bash completion works only when the version of 'tps' command is 1.3 or higher.

set -euo pipefail

readonly __tps_init_file__="${BASE_DIR}/scripts/internal/tps_init.sh"
if [ -f "${__tps_init_file__}" ]; then
	source "${__tps_init_file__}"
fi

bash "${SCRIPTS}/export.sh" "--bash-completion" "$@"
