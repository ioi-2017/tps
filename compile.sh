#!/bin/bash

source common.sh

solution=$1
filename=`basename $solution`

mkdir -p $sandbox
cp $solution $sandbox/
cp ../grader/`extension $filename`/* $sandbox/
cd $sandbox

if [ "`extension $filename`" == "cpp" ]; then
    g++ -std=gnu++14 -Wall -Wextra -Wshadow -O2 grader.cpp $filename -o ${filename%.cpp}.exe

    cat > run.sh << EOF
#!/bin/bash
sandbox=\`dirname \$0\`
\$sandbox/${filename%.cpp}.exe 2> /dev/null
EOF
fi

if [ "`extension $filename`" == "pas" ]; then
    echo "not supported yet"
fi

if [ "`extension $filename`" == "java" ]; then
    echo "not supported yet"
fi

chmod +x run.sh
