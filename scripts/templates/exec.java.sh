#!/bin/bash

problem_name=PROBLEM_NAME_PLACE_HOLDER
sandbox=$(dirname "$0")

java -jar ${JAVA_OPTS} "${sandbox}/${problem_name}.jar" "$@"
