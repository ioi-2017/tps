"""Public Grader Generator
Script to generate public graders from judge graders by removing the private lines.

Usage: python pgg.py <input-file> <output-file>

Secret markers depend on the file name extension of <input-file>.

"""

import sys


def edit_distance(s1, s2):
    m = len(s1) + 1
    n = len(s2) + 1

    tbl = {}
    for i in range(m):
        tbl[i, 0] = i
    for j in range(n):
        tbl[0, j] = j
    for i in range(1, m):
        for j in range(1, n):
            cost = 0 if s1[i - 1] == s2[j - 1] else 1
            tbl[i, j] = min(tbl[i, j - 1] + 1, tbl[i - 1, j] + 1, tbl[i - 1, j - 1] + cost)

    return tbl[i, j]


def canonical(s):
    return s.strip().lower().replace(' ', '').replace('-', '').replace('_', '')


def similar(string, pattern):
    return edit_distance(canonical(string), canonical(pattern)) <= 2



def run_pgg(input_file_path, output_file_path):

    lineNo = 0

    def die(msg):
        nonlocal lineNo
        sys.stderr.write('error: line %s: %s\n' % (lineNo, msg))
        sys.exit(1)

    if input_file_path.lower().endswith((".py", ".py2")):
        BEGIN_SECRET = '# BEGIN SECRET'
        END_SECRET = '# END SECRET'
    else:
        BEGIN_SECRET = '// BEGIN SECRET'
        END_SECRET = '// END SECRET'

    printLine = True
    output_str = ""
    with open(input_file_path, 'r') as input_f:
        for line in input_f:
            lineNo += 1
            if line.strip() == BEGIN_SECRET:
                if not printLine:
                    die('already in secret')
                printLine = False
            elif similar(line, BEGIN_SECRET):
                die('similar to "%s"' % BEGIN_SECRET)
            if printLine:
                if 'secret' in line.lower():
                    die('secret found in line "%s"' % line)
                output_str += line
            if line.strip() == END_SECRET:
                if printLine:
                    die('not in secret')
                printLine = True
            elif similar(line, END_SECRET):
                die('similar to "%s"' % END_SECRET)
        if not printLine:
            die('ends in secret')

    with open(output_file_path, 'w') as output_f:
        output_f.write(output_str)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        from util import simple_usage_message
        simple_usage_message("<input-file> <output-file>")

    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    run_pgg(input_file_path, output_file_path)
