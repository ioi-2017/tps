"""Public Grader Generator
Script to generate public graders from judge graders by removing the private lines
"""

import sys


lineNo = 0


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


def die(msg):
    sys.stderr.write('error: line %s: %s\n' % (lineNo, msg))
    sys.exit(1)


def canonical(s):
    return s.strip().lower().replace(' ', '').replace('-', '').replace('_', '')


def similar(string, pattern):
    return edit_distance(canonical(string), canonical(pattern)) <= 2


BEGIN_SECRET = '// BEGIN SECRET'
END_SECRET = '// END SECRET'

printLine = True
output = []
for line in sys.stdin:
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
        output.append(line.rstrip('\n'))
    if line.strip() == END_SECRET:
        if printLine:
            die('not in secret')
        printLine = True
    elif similar(line, END_SECRET):
        die('similar to "%s"' % END_SECRET)
if not printLine:
    die('ends in secret')

print('\n'.join(output))
