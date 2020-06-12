#!/bin/bash

# Run script for tasks of unknown type
# Solution is ordinarily run in the current implementation.

set -euo pipefail

sandbox=$(dirname "$0")

"${sandbox}/exec.sh" "$@"
