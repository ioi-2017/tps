
# This is the template for checking a solution output
#  assuming the solution is run in the sandbox against a testcase

# testcase name (provided to be used, just in case!)
test_name="$1"

# location of input file
input="$2"

# location of judge answer file
judge_answer="$3"

# location of solution output file
sol_output="$4"

"${CHECKER_DIR}/checker.exe" "${input}" "${judge_answer}" "${sol_output}"

