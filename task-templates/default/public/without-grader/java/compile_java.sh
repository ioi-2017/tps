#!/bin/bash

problem="__TPARAM_SHORT_NAME__"

set -e
rm -f "${problem}.jar" *.class
javac "${problem}.java" -Xlint:all
jar cfe "${problem}.jar" "${problem}" *.class
