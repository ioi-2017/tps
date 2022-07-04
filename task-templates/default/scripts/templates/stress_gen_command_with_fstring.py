import os
import builtins
import importlib

from stress_test_gen_utils import *

# This code works only with python 3.6+
#  because it uses f-strings.



# The function source: https://stackoverflow.com/a/54700827/12824330
def fstr_eval(_s: str, raw_string=False, eval=builtins.eval):
    r"""str: Evaluate a string as an f-string literal.

    Args:
       _s (str): The string to evaluate.
       raw_string (bool, optional): Evaluate as a raw literal
           (don't escape \). Defaults to False.
       eval (callable, optional): Evaluation function. Defaults
           to Python's builtin eval.

    Raises:
        ValueError: Triple-apostrophes ''' are forbidden.
    """
    # Prefix all local variables with _ to reduce collisions in case
    # eval is called in the local namespace.
    _TA = "'''" # triple-apostrophes constant, for readability
    if _TA in _s:
        raise ValueError("Triple-apostrophes ''' are forbidden. " + \
                         'Consider using """ instead.')

    # Strip apostrophes from the end of _s and store them in _ra.
    # There are at most two since triple-apostrophes are forbidden.
    if _s.endswith("''"):
        _ra = "''"
        _s = _s[:-2]
    elif _s.endswith("'"):
        _ra = "'"
        _s = _s[:-1]
    else:
        _ra = ""
    # Now the last character of s (if it exists) is guaranteed
    # not to be an apostrophe.

    _prefix = 'rf' if raw_string else 'f'
    return eval(_prefix + _TA + _s + _TA) + _ra


MODULES_TO_IMPORT_VAR_NAME='MODULES_TO_IMPORT'
MODULES_TO_IMPORT = os.environ.get(MODULES_TO_IMPORT_VAR_NAME)
if MODULES_TO_IMPORT is not None:
    # Importing the modules so that they become available/usable
    #  during the evaluation of the test case generation format string.
    for module_to_import in MODULES_TO_IMPORT.split():
        globals()[module_to_import] = importlib.import_module(module_to_import)


TEST_GEN_FORMAT_STRING_VAR_NAME='TEST_GEN_FORMAT_STRING'
TEST_GEN_FORMAT_STRING = os.environ.get(TEST_GEN_FORMAT_STRING_VAR_NAME)
if TEST_GEN_FORMAT_STRING is None:
    raise Exception("Environment variable '{}' is not set".format(TEST_GEN_FORMAT_STRING_VAR_NAME))


def gen_command():
    return fstr_eval(TEST_GEN_FORMAT_STRING, raw_string=True, eval=(lambda expr: eval(expr)))
