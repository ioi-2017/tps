import sys
import json


def usage():
    print('Usage: python extract.py <json-file> <json-path>')
    exit(1)


def load_json(file_path):
    with open(file_path, 'r') as f:
        data = json.load(f)
    return data


def navigate_json(data, path):
    for part in path.split('/'):
        try:
            if isinstance(data, dict):
                data = data[part]
            elif isinstance(data, list):
                data = data[int(part)]
            else:
                raise KeyError
        except (KeyError, IndexError):
            print('requested key %s not found in %s' % (path, json_file))
            exit(2)
    return data


if __name__ == '__main__':
    if len(sys.argv) != 3:
        usage()

    json_file = sys.argv[1]
    json_path = sys.argv[2]

    result = navigate_json(load_json(json_file), json_path)

    if isinstance(result, dict):
        for key in result.keys():
            print(key)
    elif isinstance(result, list):
        for key in range(len(result)):
            print(key)
    else:
        print(result)
