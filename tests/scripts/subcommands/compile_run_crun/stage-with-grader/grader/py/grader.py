import sys
import add1

def main():
    a, b = [int(x) for x in input().split()]
    sys.stdin.close()

    res = add1.solve(a, b)

    # BEGIN SECRET
    print("OK")
    # END SECRET
    print(res)
    sys.stdout.close()

if __name__ == '__main__':
    main()
