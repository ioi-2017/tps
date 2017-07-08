#!/bin/bash

problem_name=PROBLEM_NAME_PLACE_HOLDER
sandbox=$(dirname "$0")

java -jar "${sandbox}/${problem_name}.jar" "$@"
