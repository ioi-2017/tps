import random

# This code works only with python 3.5+
#  because it uses type hints.

def bernoulli(probab: float) -> bool:
    """Returns a random boolean value with Bernoulli distribution
    Probability of the returning True is `probab`.
    """
    error_prefix = "Error in calling 'bernoulli': "
    if not isinstance(probab, (int, float)):
        raise ValueError(error_prefix+"Given argument 'probab' is not a float.")
    if probab < 0:
        raise ValueError(error_prefix+"Argument 'probab' ({}) must not be negative.".format(probab))
    if probab > 1:
        raise ValueError(error_prefix+"Argument 'probab' ({}) must not be greater than 1.".format(probab))
    return random.random() < probab


def crange(start: str, finish: str) -> str:
    """Returns a string of all the characters from `start` to `finish`, inclusive.
    The arugments `start` and `finish` must be characters, i.e. strings of length 1.
    The argument 'start' must not be after the argument 'finish'.
    """
    error_prefix = "Error in calling 'crange': "
    if not isinstance(start, str):
        raise ValueError(error_prefix+"Given argument 'start' is not a string.")
    if not isinstance(finish, str):
        raise ValueError(error_prefix+"Given argument 'finish' is not a string.")
    if len(start) != 1:
        raise ValueError(error_prefix+"Length of argument 'start' ({}) is not 1.".format(start))
    if len(finish) != 1:
        raise ValueError(error_prefix+"Length of argument 'finish' ({}) is not 1.".format(finish))
    ostart = ord(start)
    ofinish = ord(finish)
    if ostart > ofinish:
        raise ValueError(error_prefix+"Argument 'start' ({}) must not be after argument 'finish' ({}).".format(start, finish))
    return "".join(chr(i) for i in range(ostart, ofinish+1))


__DEFAULT_STR_CHARS__ = crange('A', 'Z') + crange('a', 'z') + crange('0','9') + "-_"


def _uchar(chars: str) -> str:
    return random.choice(chars)


def uchar(chars: str = __DEFAULT_STR_CHARS__) -> str:
    '''Returns a character chosen uniformly from the characters of 'chars'.
    '''
    error_prefix = "Error in calling 'uchar': "
    if not isinstance(chars, str):
        raise ValueError(error_prefix+"Given argument 'chars' is not a string.")
    if not chars:
        raise ValueError(error_prefix+"Given string argument 'chars' is empty.")
    return _uchar(chars)


def ustr(minLen: int, maxLen: int, chars: str = __DEFAULT_STR_CHARS__) -> str:
    '''Returns a random string of length in range [minLen, maxLen] from the characters of 'chars'.
    The string is generated uniformly among all valid outputs.
    '''
    error_prefix = "Error in calling 'ustr': "
    if not isinstance(minLen, int):
        raise ValueError(error_prefix+"Given argument 'minLen' is not an integer.")
    if not isinstance(maxLen, int):
        raise ValueError(error_prefix+"Given argument 'maxLen' is not an integer.")
    if minLen < 0:
        raise ValueError(error_prefix+"Argument 'minLen' ({}) must not be negative.".format(minLen))
    if minLen > maxLen:
        raise ValueError(error_prefix+"Argument 'minLen' ({}) must not be greater than argument 'maxLen' ({}).".format(minLen, maxLen))
    if not isinstance(chars, str):
        raise ValueError(error_prefix+"Given argument 'chars' is not a string.")
    if not chars:
        raise ValueError(error_prefix+"Given string argument 'chars' is empty.")

    k = len(chars)
    if k == 1:
        l = random.randint(minLen, maxLen)
    else:
        l = maxLen
        while l > minLen:
            eps = k ** -(l-minLen)
            # Probability of selecting 'l' as the length of the string
            probab = (k-1) / (k-eps)
            if bernoulli(probab):
                break
            l -= 1
    return "".join(_uchar(chars) for _ in range(l))
