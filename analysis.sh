#!/bin/bash

tps_url="https://tps.ioi2017.org/gitted/problem"

commit=$(git log --pretty=format:'%H' -n 1)

repo_url=$(git config --local remote.origin.url)

if [ -z ${repo_url+x} ]; then
    errcho "Cannot find the 'origin' remote url to extract repo name"
    exit 1
fi

repo_name=$(basename -s .git ${repo_url})

analysis_url=${tps_url}/${repo_name}/${commit}/analysis


echo ${analysis_url}

if which xdg-open; then
    xdg-open ${analysis_url}
elif which gnome-open; then
    gnome-open ${analysis_url}
elif which open; then
    open ${analysis_url}
elif which start; then
    start ${analysis_url}
elif which cygstart; then
    cygstart ${analysis_url}
else
    python -mwebbrowser ${analysis_url}
fi