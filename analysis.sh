#!/bin/bash

tps_url="https://tps.ioi2017.org/gitted/problem"

commit=$(git log --pretty=format:'%H' -n 1)

analysis_url=${tps_url}/${problem_name}/${commit}/analysis

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