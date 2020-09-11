#!/bin/bash

# Run script for communication tasks
# Solution is run against the manager.
# The two programs interact through pipes.

set -euo pipefail

sandbox=$(dirname "$0")
manager_in="${sandbox}/manager.in"
manager_out="${sandbox}/manager.out"
manager_err="${sandbox}/manager.err"
manager_ret="${sandbox}/manager.ret"

NUM_SOL_PROCESSES=NUM_SOL_PROCESSES_PLACE_HOLDER

pipe_sol2mgr=()
pipe_mgr2sol=()
solution_in=()
solution_out=()
solution_err=()
solution_ret=()
for ((i=0; i<NUM_SOL_PROCESSES; i++)); do
	pipe_sol2mgr+=("${sandbox}/sol2mgr_${i}.fifo")
	pipe_mgr2sol+=("${sandbox}/mgr2sol_${i}.fifo")
	solution_in+=("${sandbox}/solution_${i}.in")
	solution_out+=("${sandbox}/solution_${i}.out")
	solution_err+=("${sandbox}/solution_${i}.err")
	solution_ret+=("${sandbox}/solution_${i}.ret")
done

if [ $# -gt 0 ]; then
	manager_log="$1"
else
	manager_log="${sandbox}/manager.log"
fi


function signal_handler {
	local -r sig="$1"; shift
	for ((i=0; i<NUM_SOL_PROCESSES; i++)); do
		kill "${sig}" "-${solution_pid[$i]}" > /dev/null 2>&1 || true
	done
	kill "${sig}" "${manager_pid}" > /dev/null 2>&1 || true
	echo "${manager_ret_value}" > "${manager_ret}"
}

trap "signal_handler -9" SIGKILL
trap "signal_handler -1" SIGTERM EXIT

for ((i=0; i<NUM_SOL_PROCESSES; i++)); do
	rm -f "${pipe_sol2mgr[$i]}" "${pipe_mgr2sol[$i]}"
	mkfifo "${pipe_sol2mgr[$i]}" "${pipe_mgr2sol[$i]}"
	touch "${solution_in[$i]}"
done

manager_args=()
for ((i=0; i<NUM_SOL_PROCESSES; i++)); do
	manager_args+=("${pipe_sol2mgr[$i]}" "${pipe_mgr2sol[$i]}")
done
manager_args+=("${manager_log}")

cat > "${manager_in}"
"${sandbox}/manager.exe" "${manager_args[@]}" < "${manager_in}" > "${manager_out}" 2> "${manager_err}" &
manager_pid=$!

solution_pid=()
for ((i=0; i<NUM_SOL_PROCESSES; i++)); do
	set -m
	bash "${sandbox}/exec.sh" "${pipe_mgr2sol[$i]}" "${pipe_sol2mgr[$i]}" "$i" < "${solution_in[$i]}" > "${solution_out[$i]}" 2> "${solution_err[$i]}" &
	solution_pid+=($!)
	set +m
done

manager_ret_value=0
wait "${manager_pid}" || manager_ret_value=$?
echo "${manager_ret_value}" > "${manager_ret}"

solution_ret_value=()
for ((i=0; i<NUM_SOL_PROCESSES; i++)); do
	s=0
	wait "${solution_pid[$i]}" || s=$?
	echo "${s}" > "${solution_ret[$i]}"
	solution_ret_value+=("${s}")
done

cat "${manager_out}"
1>&2 cat "${manager_err}"

[ "${manager_ret_value}" -eq 0 ] || exit "${manager_ret_value}"
for ((i=0; i<NUM_SOL_PROCESSES; i++)); do
	[ "${solution_ret_value[$i]}" -eq 0 ] || exit "${solution_ret_value[$i]}"
done
