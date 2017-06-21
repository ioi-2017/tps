#!/bin/bash

set -e

#TODO this should be removed
export base=$(dirname "$0")
source ${base}/scripts/common.sh

function usage {
    echo "Usage: compile.sh [--public] solution_path"
    exit 1
}

[ $# -gt 0 ] || usage

if [ "$1" == "--public" ]; then
    grader_type=public; shift
else
    grader_type=grader
fi

[ $# -gt 0 ] || usage
solution=$1; shift

[ $# -gt 0 ] && usage

if [ -z ${cpp_std+x} ]; then
    cpp_std="--std=gnu++14"
fi


ext=$(extension ${solution})
prog=${problem_name}.${ext}

grader_dir=${base}/${grader_type}/${ext}
rm -rf ${sandbox}
mkdir ${sandbox}
cp ${solution} ${sandbox}/${prog}


if [ "${ext}" == "cpp" ] ; then
	cp "${grader_dir}/${problem_name}.h" "${grader_dir}/grader.cpp" ${sandbox}
	pushd ${sandbox} > /dev/null
	g++ -DEVAL ${cpp_std} -Wall -Wextra -Wshadow -O2 -c grader.cpp -o grader.o
	rm grader.cpp
	g++ -DEVAL ${cpp_std} -Wall -Wextra -Wshadow -O2 grader.o ${prog} -o ${problem_name}.exe
    cat > run.sh << EOF
#!/bin/bash

sandbox=\$(dirname "\$0")
\${sandbox}/${problem_name}.exe
EOF
    chmod +x run.sh
	popd > /dev/null
elif [ "${ext}" == "pas" ] ; then
	cp "${grader_dir}/grader.pas" ${sandbox}
	[ -e "$grader_dir/graderlib.pas" ] && cp "${grader_dir}/graderlib.pas" ${sandbox}
	pushd ${sandbox} > /dev/null
	fpc -dEVAL -XS -O2 grader.pas -o${problem_name}.exe
    cat > run.sh << EOF
#!/bin/bash

sandbox=\$(dirname "\$0")
\${sandbox}/${problem_name}.exe
EOF
    chmod +x run.sh
	popd > /dev/null
elif [ "${ext}" == "java" ] ; then
	cp "${grader_dir}/grader.java" ${sandbox}
	pushd ${sandbox} > /dev/null
	javac grader.java ${prog}
	jar cfe ${problem_name}.jar grader *.class
	rm *.class
    cat > run.sh << EOF
#!/bin/bash

sandbox=\$(dirname "\$0")
java -jar \${sandbox}/${problem_name}.jar
EOF
    chmod +x run.sh
	popd > /dev/null
else
	echo "unknown extension: ${ext}"
	exit 2
fi
