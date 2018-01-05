#!/bin/bash

set -euo pipefail

if [ "${GRADER_TYPE}" == "judge" ]; then
    make -C "${GRADER_DIR}"
    cp "${GRADER_DIR}/manager.exe" "${SANDBOX}"
fi

