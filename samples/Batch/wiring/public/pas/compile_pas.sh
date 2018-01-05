#!/bin/bash

problem=wiring

fpc -XS -O2 -o$problem grader.pas
