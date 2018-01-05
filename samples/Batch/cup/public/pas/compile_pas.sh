#!/bin/bash

problem=cup

fpc -XS -O2 -o$problem grader.pas
