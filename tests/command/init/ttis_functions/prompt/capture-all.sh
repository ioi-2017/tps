
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

function capture_prompt {
	echo
	capture_run stage_dir "stage"
	capture_exec "k-$((capture_exec_key_counter++))" "$@"
}


echo
capture_prompt run_plain_prompt "prompt"
capture_prompt run_plain_prompt "prompt string"
capture_prompt run_plain_prompt "prompt string my_var a_description extra"


echo
capture_prompt run_prompt an_invalid_type my_var
capture_prompt run_prompt an_invalid_type my_var "a description"
capture_prompt run_prompt string 1not_id


echo
capture_prompt -ih hi run_prompt string my_var
capture_prompt -ih hi run_prompt string my_var "a description"
capture_prompt -ih "hey you" run_prompt string my_var
capture_prompt -ih "" run_prompt string my_var
capture_prompt run_prompt string my_var -- -D my_var=hello
capture_prompt run_prompt string my_var "a description" -- --define my_var=hello


echo
capture_prompt -ih hi run_prompt identifier my_var
capture_prompt -ih2 "hey you" "hey_you" run_prompt identifier my_var
capture_prompt -ih hi3 run_prompt identifier my_var
capture_prompt -ih2 3hi h3i run_prompt identifier my_var
capture_prompt -ih2 "" t run_prompt identifier my_var
capture_prompt run_prompt identifier my_var -- --define my_var=aa
capture_prompt -ih hi run_prompt identifier my_var -- -D my_var=1a


echo
capture_prompt -ih 0 run_prompt int my_var
capture_prompt -ih 1 run_prompt int my_var
capture_prompt -ih +1 run_prompt int my_var
capture_prompt -ih -1 run_prompt int my_var
capture_prompt -ih 0 run_prompt integer my_var
capture_prompt -ih 30 run_prompt integer my_var
capture_prompt -ih +30 run_prompt integer my_var
capture_prompt -ih -30 run_prompt integer my_var
capture_prompt run_prompt integer my_var -- -D my_var=40
capture_prompt -ih -30 run_prompt int my_var -- -D my_var=x
capture_prompt -ih 30 run_prompt integer my_var "a description" -- -D my_var=x
capture_prompt -ih3 x 1.2 30 run_prompt int my_var

for val in "" "x" "1.2"; do
	capture_prompt -ih2 "${val}" 30 run_prompt int my_var
done


echo
capture_prompt -ih 0 run_prompt uint my_var
capture_prompt -ih 1 run_prompt uint my_var
capture_prompt -ih 0 run_prompt unsigned_integer my_var
capture_prompt -ih 30 run_prompt unsigned_integer my_var
capture_prompt -ih2 +30 20 run_prompt unsigned_integer my_var
capture_prompt -ih2 -30 20 run_prompt unsigned_integer my_var
capture_prompt run_prompt unsigned_integer my_var -- -D my_var=40
capture_prompt -ih 30 run_prompt uint my_var -- -D my_var=x
capture_prompt -ih 30 run_prompt unsigned_integer my_var "a description" -- -D my_var=-2
capture_prompt -ih3 -1 1.2 30 run_prompt uint my_var

for val in "" "-1" "+1" "x" "1.2"; do
	capture_prompt -ih2 "${val}" 30 run_prompt uint my_var
done


echo
capture_prompt -ih 0 run_prompt decimal my_var
capture_prompt -ih 1 run_prompt decimal my_var
capture_prompt -ih 1.2 run_prompt decimal my_var
capture_prompt -ih +1 run_prompt decimal my_var
capture_prompt -ih -1 run_prompt decimal my_var
capture_prompt -ih -1.2 run_prompt decimal my_var
capture_prompt -ih +1.2 run_prompt decimal my_var
capture_prompt run_prompt decimal my_var -- -D my_var=4.3
capture_prompt -ih -30 run_prompt decimal my_var -- -D my_var=x
capture_prompt -ih 3.0 run_prompt decimal my_var "a description" -- -D my_var=x
capture_prompt -ih3 x y 3.1 run_prompt decimal my_var

for val in "" "x"; do
	capture_prompt -ih2 "${val}" 3.5 run_prompt decimal my_var
done


echo
capture_prompt -ih 0 run_prompt udecimal my_var
capture_prompt -ih 1 run_prompt udecimal my_var
capture_prompt -ih 1.2 run_prompt udecimal my_var
capture_prompt -ih 0 run_prompt unsigned_decimal my_var
capture_prompt -ih 1 run_prompt unsigned_decimal my_var
capture_prompt -ih 1.2 run_prompt unsigned_decimal my_var
capture_prompt -ih2 "+1" "0.5" run_prompt unsigned_decimal my_var
capture_prompt -ih2 "-1" "0.5" run_prompt unsigned_decimal my_var
capture_prompt -ih2 "-1.2" "0.5" run_prompt unsigned_decimal my_var
capture_prompt -ih2 "+1.2" "0.5" run_prompt unsigned_decimal my_var
capture_prompt run_prompt udecimal my_var -- -D my_var=4.3
capture_prompt -ih 30 run_prompt unsigned_decimal my_var -- -D my_var=x
capture_prompt -ih 3.0 run_prompt unsigned_decimal my_var "a description" -- -D my_var=x
capture_prompt -ih3 x y 3.1 run_prompt udecimal my_var

for val in "" "+1" "-1" "+1.2" "-1.2" "x"; do
	capture_prompt -ih2 "${val}" 3.5 run_prompt udecimal my_var
done


echo
for val in "true" "yes" "y" "false" "no" "n"; do
	capture_prompt -ih "${val}" run_prompt bool my_var
	capture_prompt -ih "${val}" run_prompt bool my_var -- -D my_var=${val}
done
for val in "" "q" "1" "0"; do
	capture_prompt -ih2 "${val}" yes run_prompt bool my_var
done


capture_prompt -ih 0 run_prompt enum my_var
capture_prompt -ih 0 run_prompt enum: my_var
capture_prompt -ih 0 run_prompt enum:1dog my_var
capture_prompt -ih 0 run_prompt enum:cat:1dog my_var
capture_prompt -ih dog run_prompt enum:dog my_var
capture_prompt -ih cat run_prompt enum:cat:dog my_var
capture_prompt -ih dog run_prompt enum:cat:dog my_var
capture_prompt -ih cat run_prompt enum:cat:dog:hen my_var
capture_prompt -ih dog run_prompt enum:cat:dog:hen my_var
capture_prompt -ih hen run_prompt enum:cat:dog:hen my_var
capture_prompt -ih2 x dog run_prompt enum:cat:dog:hen my_var


end_capturing
popd_test_context
