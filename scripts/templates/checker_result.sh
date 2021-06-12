
# This file must be "source"d from "invoke_test.sh".
# This is the script for extracting the results from the checker outputs.
# You should modify this file if the checker is going to respond differently.

# The score is written on the first line of checker standard output.
score="$(sed -n 1p "${checker_stdout}")"

# The verdict is written on the first line of checker standard error.
verdict_str="$(sed -n 1p "${checker_stderr}")"

case "${verdict_str}" in
	"Correct"|"Accepted"|"Output is correct")
		verdict="Correct" ;;
	"Partially Correct"|"Output is partially correct")
		verdict="Partially Correct" ;;
	"Wrong Answer"|"Output isn't correct"|"Output is not correct")
		verdict="Wrong Answer" ;;
	*)
		verdict="${verdict_str}" ;;
esac

# The verdict reason (checker message) is written on the second line of checker standard error.
reason="$(sed -n 2p "${checker_stderr}")"
