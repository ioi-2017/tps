
set -euo pipefail

pushd_test_context_here
begin_capturing

echo

capture_run source "../../definitions.sh"
capture_run source "../definitions.sh"
capture_run source "definitions.sh"

echo
capture_run _TT_check_stage_not_in_a_tps_repo

capture_exec_key_counter=0

function capture_gprompt {
	echo
	capture_run stage_dir "stage"
	capture_exec "k-$((capture_exec_key_counter++))" "$@"
}


echo
capture_gprompt run_gprompt "1badvar" "cat" "A_prompt_message"


echo
capture_gprompt run_gprompt "my_var" "non_existing_cmd_123" "A_prompt_message"
capture_gprompt run_gprompt "my_var" "non_existing_cmd_123" "A_prompt_message" "a description"


echo
gp_args=(run_gprompt "my_var" "cat")
capture_gprompt -ih hi "${gp_args[@]}" "Enter any string:"
capture_gprompt -ih hi "${gp_args[@]}" "Enter some string:" "a description"
capture_gprompt -ih "hey you" "${gp_args[@]}" "Enter some string:"
capture_gprompt -ih "" "${gp_args[@]}" "Enter any string:"
capture_gprompt "${gp_args[@]}" "Enter any string:" -- -D my_var=hello
capture_gprompt "${gp_args[@]}" "Enter any string:" "a description" -- --define my_var=hello


echo
gp_args=(run_gprompt "my_var" "at_least_3_long_validation_command" "Enter a string of length at least 3:")
capture_gprompt -ih "bye" "${gp_args[@]}"
capture_gprompt -ih2 "hi" "hey you" "${gp_args[@]}"
capture_gprompt -ih "h 3" "${gp_args[@]}"
capture_gprompt -ih2 "" "h3i" "${gp_args[@]}"
capture_gprompt -ih3 "" "t" "cool" "${gp_args[@]}"
capture_gprompt "${gp_args[@]}" -- --define my_var=aaa
capture_gprompt -ih "bye" "${gp_args[@]}" -- -D my_var=aa


echo
gp_args=(run_gprompt "my_var" "remove_starting_aa_validation_command" "Enter a string starting with aa:")
capture_gprompt -ih "aab" "${gp_args[@]}"
capture_gprompt -ih2 "ab" "aabc" "${gp_args[@]}"
capture_gprompt -ih "aa c" "${gp_args[@]}"
capture_gprompt -ih2 "" "aad" "${gp_args[@]}"
capture_gprompt -ih3 "" "ab" "aacool" "${gp_args[@]}"
capture_gprompt "${gp_args[@]}" -- --define my_var=aaf
capture_gprompt -ih "aart" "${gp_args[@]}" -- -D my_var=cc


end_capturing
popd_test_context
