import json
import os
import subprocess

import sys


def run_bash_command(command):
    p = None
    try:
        p = subprocess.Popen(' '.join(command), shell=True)
        ret = p.wait()
        if ret != 0:
            exit(ret)
    except KeyboardInterrupt:
        p.terminate()
        sys.stderr.write('[Interrupted]\n')
        exit(130)


def check_file_exists(file_path):
    if not os.path.isfile(file_path):
        sys.stderr.write("File '%s' not found\n" % file_path)
        exit(4)


def load_json(file_path):
    check_file_exists(file_path)
    with open(file_path, 'r') as f:
        try:
            return json.load(f)
        except ValueError as e:
            sys.stderr.write("Invalid json file '%s'\n" % file_path)
            sys.stderr.write("%s\n" % e.message)
            exit(3)
    return None


def log_warning(message):
    warnfile = os.environ.get('WARN_FILE')

    if warnfile is None:
        return

    with open(warnfile, 'a') as f:
        f.write("%s\n" % message)
