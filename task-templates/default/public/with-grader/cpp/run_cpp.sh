#!/bin/bash

problem="__TPARAM_SHORT_NAME__"
memory=2097152  # 2GB
stack_size=2097152  # 2GB

ulimit -v "${memory}"
ulimit -s "${stack_size}"
"./${problem}"
