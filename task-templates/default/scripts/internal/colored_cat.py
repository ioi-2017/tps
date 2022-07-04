"""
This script gets a color_name as an argument and prints its input with that color.
For example "echo hello | python colored_cat.py red" prints hello with red color.
"""
import sys
from color_util import cwrite, colors, InvalidColorNameException


if __name__ == '__main__':
    if len(sys.argv) != 2:
        from util import simple_usage_message
        simple_usage_message("<color-name>")

    color_name = sys.argv[1].upper()

    try:
        color = colors.get(color_name)
    except InvalidColorNameException as e:
        sys.stderr.write("{}\n".format(e))
        sys.exit(4)

    try:
        for line in sys.stdin:
            cwrite(sys.stdout, color, line)
    except KeyboardInterrupt:
        sys.exit(1)
