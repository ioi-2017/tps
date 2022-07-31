
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run source "../definition_source_util_sh.sh"

capture_exec_key_counter=0
function cap {
    capture_exec "k-$((capture_exec_key_counter++))" "$@"
}

echo
capture_run stage_an_empty_dir
echo

cap errcho
cap errcho aha
cap errcho aha ehe
cap errcho "aha ehe"
cap errcho aha ehe oho
cap errcho aha "ehe oho"
cap errcho -n
cap errcho -n aha
cap errcho -n aha ehe
cap errcho -n "aha ehe"
cap errcho -n aha ehe oho
cap errcho -n aha "ehe oho"

cap errcho "aha\tehe"
cap errcho -e "aha\tehe"

echo

cap hspace 0
cap hspace 1
cap hspace 2
cap hspace 3
cap hspace 10

end_capturing
popd_test_context
