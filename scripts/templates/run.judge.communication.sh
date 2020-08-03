#!/bin/bash

# Run script for communication tasks
# Solution is run against the manager.
# The two programs interact through pipes.

set -euo pipefail

sandbox=$(dirname "$0")
pipe_sol2mgr="${sandbox}/sol2mgr.fifo"
pipe_mgr2sol="${sandbox}/mgr2sol.fifo"
manager_in="${sandbox}/manager.in"
manager_out="${sandbox}/manager.out"
manager_err="${sandbox}/manager.err"
manager_ret="${sandbox}/manager.ret"
solution_in="${sandbox}/solution.in"
solution_out="${sandbox}/solution.out"
solution_err="${sandbox}/solution.err"
solution_ret="${sandbox}/solution.ret"

if [ $# -gt 0 ]; then
	manager_log="$1"
else
	manager_log="${sandbox}/manager.log"
fi


function signal_handler {
	kill $1 ${manager_pid} > /dev/null 2>&1 || true
	echo ${manager_ret_value} > "${manager_ret}"
}

trap "signal_handler -9" SIGKILL
trap "signal_handler -1" SIGTERM EXIT

rm -f "${pipe_sol2mgr}" "${pipe_mgr2sol}"
mkfifo "${pipe_sol2mgr}" "${pipe_mgr2sol}"
touch "${solution_in}"
cat > "${manager_in}"
"${sandbox}/manager.exe" "${pipe_sol2mgr}" "${pipe_mgr2sol}" "${manager_log}" < "${manager_in}" > "${manager_out}" 2> "${manager_err}" &
manager_pid=$!
solution_ret_value=0
bash "${sandbox}/exec.sh" "${pipe_mgr2sol}" "${pipe_sol2mgr}" < "${solution_in}" > "${solution_out}" 2> "${solution_err}" || solution_ret_value=$?
echo ${solution_ret_value} > "${solution_ret}"
manager_ret_value=0
wait $manager_pid || manager_ret_value=$?
echo ${manager_ret_value} > "${manager_ret}"
cat "${manager_out}"
1>&2 cat "${manager_err}"
if [ ${manager_ret_value} -ne 0 ] ; then
    exit ${manager_ret_value}
fi
exit ${solution_ret_value}
