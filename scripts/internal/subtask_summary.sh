#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"

subtask_name="$1"; shift
num_tests="$1"; shift

printf "%-${STATUS_PAD}s" "${subtask_name}"
if [ $# -gt 0 ]; then
  num_tests_run="$1"; shift
  subtask_score="$1"; shift
  full_subtask_score="$1"; shift
  verdict="$1"; shift
  test_name="$1"; shift

  if [ "${num_tests_run}" -eq "${num_tests}" ]; then
    tests_color="ok"
  else
    tests_color="warn"
  fi
  export BOX_PADDING=11
  boxed_echo "${tests_color}" "${num_tests_run}/${num_tests} tests"
  hspace 2
  export BOX_PADDING=20
  echo_verdict "${verdict}"

  export BOX_PADDING=11
  if [ "${subtask_score}" == "0" ] && [ "${verdict}" != "Correct" ]; then
    subtask_score_color="fail"
  elif [ "${subtask_score}" == "${full_subtask_score}" ]; then
    subtask_score_color="ok"
  else
    subtask_score_color="warn"
  fi
  boxed_echo "${subtask_score_color}" "${subtask_score}/${full_subtask_score} pts"

  if [ $# -gt 0 ]; then    
    expected_verdict_message="$1"; shift

    hspace 2
    export BOX_PADDING=30
    expected_verdict_message_color="fail"
    if [ "${expected_verdict_message}" == "match with expected" ]; then
      expected_verdict_message_color="ok"
    fi
    boxed_echo "${expected_verdict_message_color}" "${expected_verdict_message}"
  fi

  hspace 2
  echo "${test_name}"
else
  boxed_echo "fail" "0/${num_tests} tests"
  echo
fi
