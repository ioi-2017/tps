import sys
import os

from util import load_json, bool2bash


def navigate_json(data, path, json_file_name):
    for part in path.split('/'):
        if part == '.':
            continue
        try:
            if isinstance(data, dict):
                data = data[part]
            elif isinstance(data, list):
                data = data[int(part)]
            else:
                raise KeyError
        except (KeyError, IndexError):
            sys.stderr.write("Requested key '%s' not found in '%s'\n" % (path, os.path.basename(json_file_name)))
            sys.exit(4)
    return data


def navigate_json_file(file, path):
    return navigate_json(load_json(file), path, file)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        from util import simple_usage_message
        simple_usage_message("<json-file> <json-path>")

    json_file = sys.argv[1]
    json_path = sys.argv[2]

    result = navigate_json_file(json_file, json_path)

    if isinstance(result, dict):
        for key in result.keys():
            print(key)
    elif isinstance(result, list):
        for item in result:
            print(item)
    elif isinstance(result, bool):
        print(bool2bash(result))
    else:
        print(result)
