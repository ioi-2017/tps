#!/bin/bash

source common.sh

sol=$1
data=data
validator=../validator/validator.cpp

function gen {
	target=$1; shift
	./gen $@ > $target
}

function sol {
	./sol < $1 > $2
}

mkdir -p $sandbox

echo -n "gencode"
cp * $sandbox/
protect "compile" 20 make -C $sandbox all
echo

if [ -e $validator ]; then
	echo -n "validator"
    cp ../validator/* $sandbox/
	protect "compile" 20 make -C $sandbox validator.exe
	echo
fi

echo -n "solution"
protect "compile" 20 $compile $sol -o sol
echo

echo
exit

mkdir -p $tests
case=1
for sample in $samples; do
	echo -n "sample $case"

	cp $sample $tests/$case.in
	protect "sol" 25 sol $tests/$case.in $tests/$case.out
	[ -e validator ] && protect "val" 35 ./validator < $tests/$case.in
	echo

	case=`expr $case + 1`
done

while read line; do
	[ "$line" == "" ] && continue
	echo -n "test $case"

	protect "gen" 15 gen $tests/$case.in $line
	protect "sol" 25 sol $tests/$case.in $tests/$case.out
	[ -e validator ] && protect "val" 35 ./validator < $tests/$case.in
	echo

	case=`expr $case + 1`
done < data

rm -f sol gen validator log