import sys
import json


def usage():
    print('Usage: python extract.py json_file path')
    exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        usage()

    json_file = sys.argv[1]
    path = sys.argv[2]

    with open(json_file, 'r') as f:
        data = json.load(f)
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

        if isinstance(data, dict):
            for key in data.keys():
                print(key)
        elif isinstance(data, list):
            for key in range(len(data)):
                print(key)
        else:
            print(data)
