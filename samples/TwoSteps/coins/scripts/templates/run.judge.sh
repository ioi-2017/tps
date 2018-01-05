#!/bin/bash

sandbox=$(dirname "$0")
fifo="${sandbox}/pipe.fifo"
pass1_in="${sandbox}/pass1.in"
pass1_out="${sandbox}/pass1.out"
pass1_err="${sandbox}/pass1.err"
pass2_in="${sandbox}/pass2.in"
pass2_out="${sandbox}/pass2.out"
pass2_err="${sandbox}/pass2.err"

cat > "${pass1_in}"
touch "${pass2_in}"

"${sandbox}/exec.sh" "0" "${fifo}" < "${pass1_in}" > "${pass1_out}" 2> "${pass1_err}"
"${sandbox}/exec.sh" "1" "${fifo}" < "${pass2_in}" > "${pass2_out}" 2> "${pass2_err}"

cat "${pass2_out}"
