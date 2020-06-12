
# This is the template for running a solution against a testcase
#  assuming the solution being compiled in the sandbox.

set -euo pipefail

# Testcase name (provided to be used, just in case!)
test_name="$1"

# Location of the input file
input="$2"

# Location of the standard output file
sol_stdout="$3"

# Location of the standard error file
sol_stderr="$4"

# Arguments for running the solution
if "${HAS_MANAGER}"; then
	# Location of the solution log file
	sol_log="${SANDBOX}/${test_name}.log"
	sol_run_args=("${sol_log}")
else
	sol_run_args=()
fi

# Using ${sol_run_args[@]+"${sol_run_args[@]}"} instead of "${sol_run_args[@]}" because
#   simple usage of empty arrays causes unbound variable error in old versions of bash with 'set -u'.

bash "${SCRIPTS}/run.sh" ${sol_run_args[@]+"${sol_run_args[@]}"} < "${input}" > "${sol_stdout}" 2> "${sol_stderr}"

