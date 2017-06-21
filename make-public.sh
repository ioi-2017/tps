#!/bin/bash

set -e

#TODO this should be removed
export base=$(dirname "$0")
source ${base}/scripts/common.sh

grader=${base}/grader
public=${base}/public

function pgg() {
	echo pgg: $1
	python ${base}/pgg.py < "${grader}/$1" > "${public}/$1"
	fix $1
}

function copy() {
	echo copy: $1
	cp "${grader}/$1" "${public}/$1"
	fix $1
}

function fix() {
	echo fix: $1
	dos2unix "${public}/$1" &> /dev/null
}

# Check problem files using the define functions

echo ok.
