#!/bin/bash

problem_dir=$1

set -x

cp manage.py $problem_dir/
cp common.sh $problem_dir/gen/
cp compile.sh $problem_dir/gen/
cp gen.sh $problem_dir/gen/
cp test.sh $problem_dir/gen/
cp validate.sh $problem_dir/gen/

