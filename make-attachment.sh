#!/bin/bash

#TODO this should be removed
export base=$(dirname "$0")
source ${base}/scripts/common.sh

attachment_name=${problem_name}

pushd public/ > /dev/null

rm -f ${attachment_name}.zip
cat << EOF | zip -@ ${attachment_name}.zip
EOF
# list the files which sould be inside the zip package
popd > /dev/null

mv public/${attachment_name}.zip .
