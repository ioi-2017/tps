#!/bin/bash

problem=prize
memory=1640

java -XX:+UseSerialGC -Xbatch -XX:-TieredCompilation -XX:CICompilerCount=1 -XX:NewRatio=3 -Xmx${memory}M -Xss64M -cp $problem.jar grader
