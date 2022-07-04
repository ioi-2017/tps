from collections import namedtuple
import itertools
import re
import os
import glob
import posixpath


def print_all(l):
    for e in l:
        print(e)


def add_space_all(l):
    return ('{} '.format(s) for s in l)


def add_space_options(l):
    return (('{}' if s.endswith("=") else '{} ').format(s) for s in l)


def fix_filename_endings(l):
    return (('{}/' if os.path.isdir(s) else '{} ').format(s) for s in l)


def compgen_w(options, prefix):
    return (o for o in options if o.startswith(prefix))


def compgen_f(prefix):
    l = glob.iglob(prefix+"*")
    if os.name == 'nt':
        l = (posixpath.join(*s.split('\\')) for s in l)
    return l


def complete_with_files(prefix):
    return fix_filename_endings(compgen_f(prefix))


CurrentTokenInfo = namedtuple('CurrentTokenInfo', [
    'index', 'cursor_offset', 'token', 'prefix', 'previous_token',
])


def extract_current_token_info(argv):
    if len(argv) < 3:
        return None
    try:
        index = int(argv[1])
        cursor_offset = int(argv[2])
        argv[1:3] = []
        token = argv[index] if 1 <= index < len(argv) else ""
        prefix = token[:cursor_offset]
        previous_token = argv[index-1] if 1 <= index-1 < len(argv) else None
        return CurrentTokenInfo(
            index=index,
            cursor_offset=cursor_offset,
            token=token,
            prefix=prefix,
            previous_token=previous_token,
        )
    except ValueError:
        return None


def is_option_with_value(token):
    return re.match('--.*=', token)


def empty_completion_function(prefix):
    # pylint: disable=unused-argument
    return []


def simple_option_value_completion_function(values):
    return lambda prefix: add_space_all(compgen_w((values() if callable(values) else values), prefix))


def simple_argument_completion(
        current_token_info,
        available_options,
        *,
        enable_file_completion=True,
        option_value_completion_functions=None,
):
    def find_option_value_completion_func(option, check_none, default_func=None):
        if option_value_completion_functions:
            for key, func in option_value_completion_functions.items():
                if key is None:
                    continue
                options = (key,) if isinstance(key, str) else key
                if option in options:
                    return func
            if check_none and None in option_value_completion_functions:
                return option_value_completion_functions[None]
        return default_func

    if not current_token_info:
        return []
    arg_prefix = current_token_info.prefix

    if current_token_info.previous_token is not None:
        value_completion_func = find_option_value_completion_func(
            option=current_token_info.previous_token,
            check_none=False,
        )
        if value_completion_func:
            return value_completion_func(arg_prefix)

    if is_option_with_value(arg_prefix):
        option, value_prefix = arg_prefix.split('=', 1)
        value_completion_func = find_option_value_completion_func(
            option=option,
            check_none=True,
            default_func=complete_with_files if enable_file_completion else empty_completion_function,
        )
        return value_completion_func(value_prefix)

    completion_item_lists = [add_space_options(compgen_w(available_options, arg_prefix))]
    if enable_file_completion:
        completion_item_lists += [complete_with_files(arg_prefix)]
    return itertools.chain.from_iterable(completion_item_lists)
