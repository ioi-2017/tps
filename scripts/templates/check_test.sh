
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

# Designed for CMS checker protocol

function issue_score_verdict_reason {
	local -r _local_score="$1"; shift
	local -r _local_verdict="$1"; shift
	local -r _local_reason="$1"; shift
	# The behavior shall be consistent with the checker behavior.
	echo "${_local_score}"
	>&2 echo "${_local_verdict}"
	>&2 echo "${_local_reason}"
	exit 0
}

function raise_failure {
	local -r exit_code="$1"; shift
	local -r failure_reason="$1"; shift
	>&2 echo "${failure_reason}"
	exit "${exit_code}"
}


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
	command -v "${DIFF}" &> "/dev/null" ||
		raise_failure 4 "Command '${DIFF}' not found."
	if "${DIFF}" "${DIFF_FLAGS}" "${judge_answer}" "${sol_stdout}" > "/dev/null"; then
		issue_score_verdict_reason "1" "Correct" ""
	else
		issue_score_verdict_reason "0" "Wrong Answer" "The output differs from the correct answer."
	fi
fi
