
set -euo pipefail

pushd_test_context_here
begin_capturing

set_mask_capturing_nonzero_return_codes "true"

capture_run source "../../definition_get_head.sh"
capture_run source "../../definition_not_web_terminal.sh"
capture_run source "definitions.sh"

capture_exec_key_counter=0
function capture_exec_k {
    capture_exec "k-$((capture_exec_key_counter++))" "$@"
}

function restage {
    echo
    echo
    capture_run stage_dir_with_scripts "${stage_dir}"
    echo
}

function clear_sandbox {
    echo
    capture_run_in_stage rm -rf "sandbox"
}

function capture_compile {
    echo
    capture_exec_k tcompile "$@"
}

function capture_compile_head {
    local -r n1="$1"; shift
    local -r n2="$1"; shift
    echo
    capture_exec_k get_head "${n1}" "${n2}" tcompile "$@"
}


function capture_crun {
    capture_exec_k tcrun "$@"
}

function capture_crun_i {
    local -r input="$1"; shift
    capture_exec_k -ih "${input}" tcrun "$@"
}

function capture_crun_head {
    local -r n1="$1"; shift
    local -r n2="$1"; shift
    capture_exec_k get_head "${n1}" "${n2}" tcrun "$@"
}


stage_dir="stage-without-grader"

restage

capture_compile --help
capture_compile
capture_compile "solution/correct1.cpp" "another-arg"
capture_compile "solution/correct1.cpp" --unknown-flag

capture_compile -p "solution/correct1.cpp"

capture_compile "solution/correct1.cpp"
capture_compile -w "solution/correct1.cpp"
capture_exec_k -ih "2 3" trun

capture_compile "solution/wrong1.cpp"
capture_exec_k -ih "2 3" trun

clear_sandbox
capture_compile "solution/correct-args1.cpp"
capture_exec_k -ih "2 3" trun
capture_exec_k -ih "2 3" trun "a"
capture_exec_k -ih "2 3" trun "a" "b"

capture_compile "solution/rte1.cpp"
capture_exec_k -ih "2 3" trun

capture_compile_head -1 0 "solution/correct1-warn.cpp"
capture_exec_k -ih "2 3" trun
capture_compile_head -1 0 -w "solution/correct1-warn.cpp"

capture_compile_head -1 0 "solution/compile_error1.cpp"
capture_compile_head -1 0 -w "solution/compile_error1.cpp"


function test_java_solutions {
    : Commenting out java solutions as some test environments may not have java
    # clear_sandbox
    # capture_compile "solution/correct1.java"
    # capture_compile -w "solution/correct1.java"
    # capture_exec_k -ih "2 3" trun

    # capture_compile "solution/wrong1.java"
    # capture_exec_k -ih "2 3" trun

    # clear_sandbox
    # capture_compile "solution/correct-args1.java"
    # capture_exec_k -ih "2 3" trun
    # capture_exec_k -ih "2 3" trun "a"
    # capture_exec_k -ih "2 3" trun "a" "b"

    # capture_compile "solution/rte1.java"
    # capture_exec_k -ih "2 3" trun

    # : We could not make java compile produce warnings.
    # capture_compile "solution/correct1-warn.java"
    # capture_exec_k -ih "2 3" trun
    # capture_compile -w "solution/correct1-warn.java"

    # capture_compile_head -1 0 "solution/compile_error1.java"
    # capture_compile_head -1 0 -w "solution/compile_error1.java"
}

test_java_solutions

clear_sandbox
capture_compile_head -1 0 "solution/correct1.py"
capture_compile_head -1 0 -w "solution/correct1.py"
capture_exec_k -ih "2 3" trun

capture_compile_head -1 0 "solution/wrong1.py"
capture_exec_k -ih "2 3" trun

clear_sandbox
capture_compile_head -1 0 "solution/correct-args1.py"
capture_exec_k -ih "2 3" trun
capture_exec_k -ih "2 3" trun "a"
capture_exec_k -ih "2 3" trun "a" "b"

capture_compile_head -1 0 "solution/rte1.py"
capture_exec_k -ih "2 3" trun

function test_problematic_py_solutions {
    : Commenting out problematic python solutions as some test environments may not have enough tools
    # capture_compile_head -1 0 "solution/correct1-warn.py"
    # capture_exec_k -ih "2 3" trun
    # capture_compile_head -1 0 -w "solution/correct1-warn.py"

    # capture_compile_head -1 0 "solution/compile_error1.py"
    # capture_compile_head -1 0 -w "solution/compile_error1.py"
}

test_problematic_py_solutions



clear_sandbox
capture_crun --help
capture_crun
capture_crun "solution/correct1.cpp" "another-arg"
capture_crun "solution/correct1.cpp" --unknown-flag

capture_crun -p "solution/correct1.cpp"

clear_sandbox
capture_crun_i "2 3" "solution/correct1.cpp"
capture_crun_i "2 3" -w "solution/correct1.cpp"
capture_crun_i "2 3" "solution/wrong1.cpp"

clear_sandbox
capture_crun_i "2 3" "solution/correct-args1.cpp"
capture_crun_i "2 3" "solution/correct-args1.cpp" --
capture_crun_i "2 3" "solution/correct-args1.cpp" -- "a"
capture_crun_i "2 3" "solution/correct-args1.cpp" -- "a" "b"

echo
capture_crun_i "2 3" "solution/rte1.cpp"
capture_crun_i "2 3" "solution/correct1-warn.cpp"
capture_crun_head -1 5 -w "solution/correct1-warn.cpp"
capture_crun_head -1 1 "solution/compile_error1.cpp"
capture_crun_head -1 1 -w "solution/compile_error1.cpp"

clear_sandbox
capture_crun_i "2 3" "solution/correct1.py"
capture_crun_i "2 3" -w "solution/correct1.py"
capture_crun_i "2 3" "solution/wrong1.py"

clear_sandbox
capture_crun_i "2 3" "solution/correct-args1.py"
capture_crun_i "2 3" "solution/correct-args1.py" --
capture_crun_i "2 3" "solution/correct-args1.py" -- "a"
capture_crun_i "2 3" "solution/correct-args1.py" -- "a" "b"

echo
capture_crun_i "2 3" "solution/rte1.py"



stage_dir="stage-with-grader"

restage

capture_compile "solution/correct1.cpp"
capture_compile -w "solution/correct1.cpp"
capture_exec_k -ih "2 3" trun

capture_compile -p "solution/correct1.cpp"
capture_compile -pw "solution/correct1.cpp"
capture_exec_k -ih "2 3" trun


function test_java_solutions2 {
    : Commenting out java solutions as some test environments may not have java
    # clear_sandbox
    # capture_compile "solution/correct1.java"
    # capture_compile -w "solution/correct1.java"
    # capture_exec_k -ih "2 3" trun

    # capture_compile -p "solution/correct1.java"
    # capture_compile -pw "solution/correct1.java"
    # capture_exec_k -ih "2 3" trun
}

test_java_solutions2

clear_sandbox
capture_compile_head -1 0 "solution/correct1.py"
capture_compile_head -1 0 -w "solution/correct1.py"
capture_exec_k -ih "2 3" trun

capture_compile_head -1 0 -p "solution/correct1.py"
capture_compile_head -1 0 -pw "solution/correct1.py"
capture_exec_k -ih "2 3" trun



clear_sandbox
capture_crun_i "2 3" "solution/correct1.cpp"
capture_crun_i "2 3" -w "solution/correct1.cpp"

capture_crun_i "2 3" -p "solution/correct1.cpp"
capture_crun_i "2 3" -pw "solution/correct1.cpp"


clear_sandbox
capture_crun_i "2 3" "solution/correct1.py"
capture_crun_i "2 3" -w "solution/correct1.py"

capture_crun_i "2 3" -p "solution/correct1.py"
capture_crun_i "2 3" -pw "solution/correct1.py"


set_mask_capturing_nonzero_return_codes "false"

end_capturing
popd_test_context
