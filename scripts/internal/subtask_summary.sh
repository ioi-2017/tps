#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"

subtask_name="$1"; shift
score="$1"; shift
verdict="$1"; shift
test_name="$1"; shift

printf "%-${STATUS_PAD}s" "${subtask_name}"
printf "%5s" "${score}"
hspace 2
export BOX_PADDING=20
echo_verdict "${verdict}"

printf "${test_name}"

echo
