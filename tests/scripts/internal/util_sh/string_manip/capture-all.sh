
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run source "../definition_source_util_sh.sh"

capture_exec_key_counter=0
function cap_ext {
    capture_exec "e-$((capture_exec_key_counter++))" extension "$@"
}

echo
capture_run stage_an_empty_dir
echo

cap_ext ""
# cap_ext "."
# cap_ext "a"
# cap_ext "txt"
# cap_ext ".a"
# cap_ext ".txt"
cap_ext "a.txt"
cap_ext ".a.txt"
cap_ext "a."
cap_ext ".a."
cap_ext "a.b.c"
cap_ext "a/b.txt"
cap_ext "a/b/c.txt"
cap_ext "a/b.c.txt"

end_capturing
popd_test_context
