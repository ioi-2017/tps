#!/usr/bin/env python
# This script converts an input/output file of IOI 2017 task nowruz to .ppm format, and then converts it to png.
# It needs convert and display commands on your OS. If your OS does not have these commands, you can set tempfile=False and use the ppm file.
tempfile=True
import sys
import os
from tempfile import NamedTemporaryFile
from random import randint
from subprocess import call

inf_name = sys.argv[1]
with open(inf_name, 'r') as inf:
    lines = [line.strip() for line in inf.readlines()]
    if lines[0][0] >= '0' and lines[0][0] <= '9':
        lines = lines[1:]

def is_av(x, y):
    global lines
    if x < 0 or y < 0:
        return False
    try:
        lines[x][y]
    except IndexError:
        return False
    return True


def main():
    dx = [-1, 0, 1, 0]
    dy = [0, 1, 0, -1]
    res = [[2] * len(lines[0]) * 3 for tmp in range(len(lines) * 3)]
    for x in range(len(lines)):
        for y in range(len(lines[x])):
            if lines[x][y] == '.':
                res[3 * x + 1][3 * y + 1] = 0
                res[3 * x][3 * y] = 1
                res[3 * x][3 * y + 2] = 1
                res[3 * x + 2][3 * y] = 1
                res[3 * x + 2][3 * y + 2] = 1
                cnt = 0
                for k in range(4):
                    nx = x + dx[k]
                    ny = y + dy[k]
                    if is_av(nx, ny) and lines[nx][ny] == '.':
                        cnt += 1
                        res[3 * x + 1 + dx[k]][3 * y + 1 + dy[k]] = 0
                    else:
                        res[3 * x + 1 + dx[k]][3 * y + 1 + dy[k]] = 1
                if cnt == 1:
                    res[3 * x + 1][3 * y + 1] = -1
            elif lines[x][y] == '#':
                for nx in range(3 * x, 3 * x + 3):
                    for ny in range(3 * y, 3 * y + 3):
                        res[nx][ny] = 3
    if tempfile:
	f = NamedTemporaryFile(suffix=".ppm", delete=False)
    else:
	f = open(inf_name + '.ppm', 'w')
    print >> f, "P3"
    print >> f, "{} {}".format(len(res[0])*10, len(res)*10)
    print >> f, 255
    for x in range(len(res)):
    	for tmp in range(10):
            for y in range(len(res[0])):
                for tmp2 in range(10):
                    if res[x][y] == -1:
                        f.write("0 0 0 ")
                    elif res[x][y] == 0:
                        f.write("0 0 0 ")
                    elif res[x][y] == 1:
                        f.write("128 128 128 ")
                    elif res[x][y] == 2:
                        f.write("0 {} 0 ".format(randint(64, 128)))
                    else:
                        f.write("73 56 41 ")
                    print >> f
    f.close();
    call(["convert", f.name, inf_name+".png"])
    os.unlink(f.name)
if __name__ == "__main__":
    main()
