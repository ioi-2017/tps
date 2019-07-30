import sys
import os
from color_util import colored, colors, InvalidColorNameException


'''
This script gets a color_name as an argument and prints its input with that color.
For example "echo hello | python colored_cat red" prints hello with red color. 
'''
if __name__ == '__main__':
    if len(sys.argv) != 2:
        from util import simple_usage_message
        simple_usage_message("<color-name>")

    color_name = sys.argv[1].upper()
    try:
        for line in sys.stdin:
            sys.stdout.write(colored(colors.get(color_name), line))
    except InvalidColorNameException:
        sys.stderr.write('Invalid color name: {}\n'.format(color_name))
        exit(4)
    except KeyboardInterrupt:
        sys.stdout.write(colors.RESET)
        exit(1)
