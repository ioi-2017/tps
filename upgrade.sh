#!/bin/bash

problem_dir=$1

set -ex

mkdir -p "${problem_dir}/scripts"

"rm ${problem_dir}/
cp verify.py $problem_dir/scripts
cp common.sh $problem_dir/scripts/
cp compile.sh $problem_dir/
cp gen.sh $problem_dir/gen/
cp test.sh $problem_dir/gen/
cp validate.sh $problem_dir/gen/
cp problem.gitignore $problem_dir/.gitignore

for folder in gen validator checker; do
    cat > $problem_dir/$folder/Makefile << EOF
all:`cd $problem_dir/$folder/; for file in \`ls *.cpp\`; do echo -n " ${file%.cpp}.exe"; done`

clean:
	rm -f *.exe

%.exe: %.cpp testlib.h
	g++ -std=gnu++1y -Wall -Wextra -Wshadow -O2 $< -o \$@
EOF
done"
