import sys
import os


def _unified_sort(l):
    return sorted(set(l))

def _add_space_options(l):
    return [('{}' if tmp.endswith("=") else '{} ').format(tmp) for tmp in l]


def _fix_file_endings(l):
    return [('{}/' if os.path.isdir(tmp) else '{} ').format(tmp) for tmp in l]


def compgen_w(l, prefix):
    return [e for e in l if e.startswith(prefix)]


def compgen_f(prefix):
    return compgen_w(os.listdir('.'), prefix)


def _complete_with_files(prefix):
    return _fix_file_endings(_unified_sort(compgen_f(prefix)))


def _bc():
    if len(sys.argv) < 3:
        return
    index = int(sys.argv[1])
    cursor_location = int(sys.argv[2])
    args = sys.argv[3:]
    index -= 1
    current_token = args[index] if index < len(args) else ""
    current_token_prefix = current_token[:cursor_location]

    if current_token_prefix.startswith("--") and "=" in current_token_prefix:
        return _complete_with_files(current_token_prefix[current_token_prefix.find('=')+1:])
    else:
        return _add_space_options(compgen_w(["--hello", "--type="],  current_token_prefix)) + \
            _complete_with_files(current_token_prefix)


if __name__ == '__main__':
    for e in _bc():
        print(e)
