#!/bin/bash

problem="__TPARAM_SHORT_NAME__"
grader_name="grader"

g++ -std=gnu++17 -O2 -Wall -pipe -static -o "${problem}" "${grader_name}.cpp" "${problem}.cpp"
