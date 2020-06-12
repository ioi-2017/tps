
# This is the template for checking a solution output
#  assuming the solution is run in the sandbox against a testcase.

set -euo pipefail

# Testcase name (provided to be used, just in case!)
test_name="$1"

# Location of the input file
input="$2"

# Location of judge answer file
judge_answer="$3"

# Location of solution standard output file
sol_stdout="$4"

# Location of solution standard error file
sol_stderr="$5"

if "${HAS_CHECKER}"; then
	"${CHECKER_DIR}/checker.exe" "${input}" "${judge_answer}" "${sol_stdout}"
	# Not using test_name & sol_stderr
elif "${HAS_MANAGER}"; then
	# If there is no checker, then the manager outputs should be in the format of checker outputs.
	cat "${sol_stdout}"
	>&2 cat "${sol_stderr}"
	# Not using test_name & input & judge_answer
else
	# There is no checker or manager. Comparing solution standard output with judge answer file.
	# Not using test_name & input & sol_stderr
	DIFF="diff"
	DIFF_FLAGS="-bq"
	if ! command -v "${DIFF}" >/dev/null 2>&1 ; then
		echo "0"
		>&2 echo "Judge Failure; Contact staff!"
		>&2 echo "Command '${DIFF}' not found."
	elif "${DIFF}" "${DIFF_FLAGS}" "${judge_answer}" "${sol_stdout}" >/dev/null; then
		echo "1"
		>&2 echo "Correct"
	else
		echo "0"
		>&2 echo "Wrong Answer"
		>&2 echo "The output differs from the correct answer."
	fi
fi

