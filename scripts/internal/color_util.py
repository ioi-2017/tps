'''\
Utility module for coloring texts.

Important note for windows users:
This module uses "colorama" package.
You have to install it (e.g. using pip) or no coloring happens.
'''

import sys
import os
import platform
import subprocess


class InvalidColorNameException(Exception):
    pass

class colors(object):
    RESET = "\033[0m"
    
    BLACK = "\033[30m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"
    
    INTENSIVE_BLACK = "\033[1;2;30m"
    INTENSIVE_RED = "\033[1;31m"
    INTENSIVE_GREEN = "\033[1;32m"
    INTENSIVE_YELLOW = "\033[1;33m"
    INTENSIVE_BLUE = "\033[1;34m"
    INTENSIVE_MAGENTA = "\033[1;35m"
    INTENSIVE_CYAN = "\033[1;36m"
    INTENSIVE_WHITE = "\033[1;37m"
    
    FAINT_BLACK = "\033[2;2;30m"
    FAINT_RED = "\033[2;31m"
    FAINT_GREEN = "\033[2;32m"
    FAINT_YELLOW = "\033[2;33m"
    FAINT_BLUE = "\033[2;34m"
    FAINT_MAGENTA = "\033[2;35m"
    FAINT_CYAN = "\033[2;36m"
    FAINT_WHITE = "\033[2;37m"
    
    OK = GREEN
    SUCCESS = GREEN
    FAIL = RED
    ERROR = RED
    WARN = YELLOW
    SKIPPED = FAINT_WHITE
    IGNORED = FAINT_WHITE
    OTHER = MAGENTA
    
    @classmethod
    def get(cls, color_name):
        if not hasattr(cls, color_name):
            raise InvalidColorNameException()
        return getattr(cls, color_name)
      


def _is_windows():
    return platform.system()=="Windows"

def _is_web():
    return os.environ.get('WEB_TERMINAL') == "true"

def _is_tty():
    return sys.stdout.isatty()

def _term_color_support():
    try:
        return _is_tty() and (8 <= int(subprocess.check_output(["tput", "colors"])))
    except:
        return False

def _should_use_colors():
#     sys.stderr.write("is_windows():  {}\n".format(_is_windows()))
#     sys.stderr.write("term_color_support():  {}\n".format(_term_color_support()))
#     sys.stderr.write("is_web():  {}\n".format(_is_web()))
    if not _is_windows():
        return _term_color_support() or _is_web()
    if not _is_tty():
        return _is_web()
    try:
        import colorama
        colorama.init()
        return True
    except ImportError:
        pass
    return False

_use_colors = _should_use_colors()

def colored(color, text):
    global _use_colors
    return color+text+colors.RESET if _use_colors else text

def cprint(color, text):
    print(colored(color, text))

