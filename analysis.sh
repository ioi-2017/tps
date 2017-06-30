#!/bin/bash

tps_url="https://tps.ioi2017.org/gitted/problem"

commit=$(git log --pretty=format:'%H' -n 1)

analysis_url=${tps_url}/${problem_name}/${commit}/analysis

echo ${analysis_url}

if which -s xdg-open; then
    xdg-open ${analysis_url}
elif which -s gnome-open; then
    gnome-open ${analysis_url}
elif which -s open; then
    open ${analysis_url}
elif which -s start; then
    start ${analysis_url}
elif which -s cygstart; then
    cygstart ${analysis_url}
else
    python -mwebbrowser ${analysis_url}
fi