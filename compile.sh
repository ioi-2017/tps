#!/bin/bash

source common.sh

compile_cpp=
compile_pas=fpc -O2

solution=$1
filename=`basename $solution`

mkdir -p $sandbox

echo -ne $filename
cp $solution $sandbox/

if [ "`extension $filename`" == "cpp" ]; then
    grader=../grader/cpp/grader.cpp
    g++ -std=gnu++14 -Wall -Wextra -Wshadow -O2 $grader $solution -o $sandbox/{$filename%.cpp}.exe

    cat > run.sh << EOF
    #!/bin/bash
    $sandbox/{$filename%.cpp}.exe
    EOF
fi

if [ "`extension $filename`" == "pas" ]; then
    echo "not supported yet"
fi

if [ "`extension $filename`" == "java" ]; then
    echo "not supported yet"
fi
