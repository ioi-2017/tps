
# This is the template for checking a solution output
#  assuming the solution is run in the sandbox against a testcase

# testcase name (provided to be used, just in case!)
test_name="$1"

# location of input file
input="$2"

# location of judge answer file
judge_answer="$3"

# location of solution standard output file
sol_stdout="$4"

# location of solution standard error file
sol_stderr="$5"

"${CHECKER_DIR}/checker.exe" "${input}" "${judge_answer}" "${sol_stdout}"
# Not using test_name & sol_stderr

