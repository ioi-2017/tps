#!/bin/bash

problem="__TPARAM_SHORT_NAME__"

g++ -std=gnu++17 -O2 -Wall -pipe -static -o "${problem}" "${problem}.cpp"
