
# This is the template for running a solution against a testcase
#  assuming the solution being compiled in the sandbox

# testcase name (provided to be used, just in case!)
test_name="$1"

# location of input file
input="$2"

# location of solution standard output file
sol_stdout="$3"

# location of solution standard error file
sol_stderr="$4"

bash "${SCRIPTS}/run.sh" < "${input}" > "${sol_stdout}" 2> "${sol_stderr}"

