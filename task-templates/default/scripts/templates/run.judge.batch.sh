#!/bin/bash

# Run script for tasks of type batch or output-only
# Solution is just run ordinarily.

set -euo pipefail

sandbox=$(dirname "$0")

"${sandbox}/exec.sh" "$@"
