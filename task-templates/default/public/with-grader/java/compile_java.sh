#!/bin/bash

problem="__TPARAM_SHORT_NAME__"
grader_name="grader"

set -e
rm -f "${problem}.jar" *.class
javac "${grader_name}.java" "${problem}.java" -Xlint:all
jar cfe "${problem}.jar" "${grader_name}" *.class
