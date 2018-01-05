#!/bin/bash

sandbox=$(dirname "$0")
g2m="${sandbox}/g2m"
m2g="${sandbox}/m2g"
manager_in="${sandbox}/manager.in"
manager_out="${sandbox}/manager.out"
manager_err="${sandbox}/manager.err"
manager_ret="${sandbox}/manager.ret"
grader_in="${sandbox}/grader.in"
grader_out="${sandbox}/grader.out"
grader_err="${sandbox}/grader.err"
grader_ret="${sandbox}/grader.ret"

function signal_handler {
	kill $1 ${manager_pid} > /dev/null 2>&1 || true
	echo ${manager_ret_value} > "${manager_ret}"
}

trap "signal_handler -9" SIGKILL
trap "signal_handler -1" SIGTERM EXIT

rm -f "${g2m}" "${m2g}"
mkfifo "${g2m}" "${m2g}"
touch "${grader_in}"
cat > "${manager_in}"
"${sandbox}/manager.exe" "${g2m}" "${m2g}" < "${manager_in}" > "${manager_out}" 2> "${manager_err}" &
manager_pid=$!
"${sandbox}/exec.sh" "${m2g}" "${g2m}" < "${grader_in}" > "${grader_out}" 2> "${grader_err}"
grader_ret_value=$?
echo ${grader_ret_value} > "${grader_ret}"
wait $manager_pid
manager_ret_value=$?
echo ${manager_ret_value} > "${manager_ret}"
cat "${manager_out}"
if [ ${manager_ret_value} -ne 0 ] ; then
    exit ${manager_ret_value}
fi
exit ${grader_ret_value}
