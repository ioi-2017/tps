import sys

a, b = [int(x) for x in input().split()]

if a > 10:
    sys.exit(20)

print(a+b)
