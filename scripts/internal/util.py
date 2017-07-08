import json
import os
import subprocess

import sys


def run_bash_command(command):
    try:
        ret = subprocess.call(' '.join(command), shell=True)
        if ret != 0:
            exit(ret)
    except KeyboardInterrupt:
        sys.stderr.write('[Interrupted]\n')
        exit(130)


def check_file_exists(file_path):
    if not os.path.isfile(file_path):
        sys.stderr.write("File '%s' not found\n" % file_path)
        exit(4)


def load_json(file_path):
    check_file_exists(file_path)
    with open(file_path, 'r') as f:
        data = json.load(f)
    return data


def log_warning(message):
    warnfile = os.environ.get('warn_file')

    if warnfile is None:
        return

    with open(warnfile, 'a') as f:
        f.write("%s\n" % message)
