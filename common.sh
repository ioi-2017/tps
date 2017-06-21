#!/bin/bash

# Enter the problem name here
problem_name=
#TODO extract problem_name from problem.json

tests=${base}/tests
sandbox=${base}/sandbox

reset='\033[00m'
green='\033[01;32m'
red='\033[01;31m'

OK="[${green}OK${reset}]"
FAIL="[${red}FAIL${reset}]"

function protect {
    stacked=false
    verbose=false
    [ "$1" == "--stack" ] && stacked=true && shift
    [ "$1" == "--verbose" ] && verbose=true && shift
	name=$1 && shift
	place=$1 && shift

    error=$sandbox/tmperror

	echo -ne "\033[${place}G${reset}${name}"
	if $@ &> $error; then
		echo -ne "$OK"
        clean_sources
	else
		echo -ne "$FAIL"
		$verbose && echo && cat $error && exit 1
	fi
	$stacked || echo
}

function extension {
    echo $1 | rev | cut -d. -f1 | rev
}

function clean_sources {
    ls -1 ${sandbox} | while read file; do
        [ "`extension ${file}`" == "exe" ] || \
        [ "`extension ${file}`" == "sh" ] || \
        [ "${file}" == "tmperror" ] || \
        rm ${sandbox}/${file}
    done
}
