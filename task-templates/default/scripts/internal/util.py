import sys
import os
import json


def simple_usage_message(arguments_text):
    sys.stderr.write('Usage: python {} {}\n'.format(os.path.basename(sys.argv[0]), arguments_text))
    sys.exit(2)


def wait_process_success(proc):
    try:
        ret = proc.wait()
        if ret != 0:
            sys.exit(ret)
    except KeyboardInterrupt:
        proc.terminate()
        sys.stderr.write('[Interrupted]\n')
        sys.exit(130)


def check_file_exists(file_path, error_prefix=""):
    if not os.path.isfile(file_path):
        parent_dir = os.path.dirname(file_path)
        if not parent_dir:
            parent_dir = "."
        sys.stderr.write("{}File '{}' not found in directory '{}'.\n"
                         .format(error_prefix, os.path.basename(file_path), parent_dir))
        sys.exit(4)


def load_json(file_path):
    check_file_exists(file_path)
    with open(file_path, 'r') as f:
        try:
            return json.load(f)
        except ValueError as e:
            sys.stderr.write("Invalid json file '%s'\n" % file_path)
            sys.stderr.write("%s\n" % e)
            sys.exit(3)
    return None


def bool2bash(b):
    return "true" if b else "false"


def get_bool_environ(var_name, default_value=None):
    var_value = os.environ.get(var_name)
    if var_value is None:
        return default_value
    if var_value == "true":
        return True
    if var_value == "false":
        return False
    raise ValueError("Invalid value '{}' for environment variable '{}'.".format(var_value, var_name))


def log_warning(message):
    warnfile = os.environ.get('WARN_FILE')

    if warnfile is None:
        return

    with open(warnfile, 'a') as f:
        f.write("%s\n" % message)


def unify_list(l):
    seen = []
    for e in l:
        if e not in seen:
            seen.append(e)
    return seen
