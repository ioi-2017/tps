import sys
import os
import json


def simple_usage_message(arguments_text):
    sys.stderr.write('Usage: python {} {}\n'.format(os.path.basename(sys.argv[0]), arguments_text))
    exit(2)


def wait_process_success(proc):
    try:
        ret = proc.wait()
        if ret != 0:
            exit(ret)
    except KeyboardInterrupt:
        proc.terminate()
        sys.stderr.write('[Interrupted]\n')
        exit(130)


def check_file_exists(file_path, error_prefix=""):
    if not os.path.isfile(file_path):
        dir = os.path.dirname(file_path)
        if not dir:
            dir = "."
        sys.stderr.write("{}File '{}' not found in directory '{}'.\n"
                         .format(error_prefix, os.path.basename(file_path), dir))
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
