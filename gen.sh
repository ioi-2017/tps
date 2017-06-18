#!/bin/bash

source common.sh

sol=$1
data=data
validator=../validator/validator.cpp
manuals=manual/

mkdir -p $sandbox

echo -n "gencode"
cp Makefile *.cpp $sandbox/
protect --verbose "compile" 20 make -C $sandbox all

if [ -e $validator ]; then
	echo -n "validator"
    cp ../validator/* $sandbox/
	protect --verbose "compile" 20 make -C $sandbox validator.exe
fi

echo -n "solution"
protect --verbose "compile" 20 ./compile.sh $sol

echo


function generate {
	target=$1; shift
	generator=$1; shift
	if [ "$generator" == "manual" ]; then
	    cat $manuals/$@ > $target
	else
	    $sandbox/$generator.exe $@ > $target
	fi
}

function solve {
	$sandbox/run.sh < $1 > $2
}

function validate {
    $sandbox/validator.exe < $1
}

mkdir -p $tests

subtask=-1
index=1
while read line; do
	[ "$line" == "" ] && continue
	if [[ $line == [* ]]; then
	    echo $line; subtask=`expr $subtask + 1`; index=1; continue
	fi

	test=$subtask-`printf "%02d" $index`
	echo -n "test $test"

	protect --stack "gen" 15 generate $tests/$test.in $line
	[ -e $validator ] && protect --stack "val" 25 validate $tests/$test.in
	protect "sol" 35 solve $tests/$test.in $tests/$test.out

	index=`expr $index + 1`
done < data
