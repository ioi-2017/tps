#!/bin/bash

# Run script for two-step tasks
# Solution is run two times (passes).
# Output of the first pass is the input for the second pass.

set -euo pipefail

sandbox=$(dirname "$0")
intermediate_file="${sandbox}/intermediate.data"
pass1_in="${sandbox}/pass1.in"
pass1_out="${sandbox}/pass1.out"
pass1_err="${sandbox}/pass1.err"
pass2_in="${sandbox}/pass2.in"
pass2_out="${sandbox}/pass2.out"
pass2_err="${sandbox}/pass2.err"

cat > "${pass1_in}"
touch "${pass2_in}"

"${sandbox}/exec.sh" "0" "${intermediate_file}" < "${pass1_in}" > "${pass1_out}" 2> "${pass1_err}"
"${sandbox}/exec.sh" "1" "${intermediate_file}" < "${pass2_in}" > "${pass2_out}" 2> "${pass2_err}"

cat "${pass2_out}"
