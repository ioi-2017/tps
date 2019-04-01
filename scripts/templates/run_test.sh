
# This is the template for running a solution against a testcase
#  assuming the solution being compiled in the sandbox

# testcase name (provided to be used, just in case!)
test_name="$1"

# location of input file
input="$2"

# location of solution output file
sol_output="$3"

bash "${SCRIPTS}/run.sh" < "${input}" > "${sol_output}"

