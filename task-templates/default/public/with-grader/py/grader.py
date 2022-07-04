import sys
import __TPARAM_SHORT_NAME__

def main():
    n = int(input())
    sys.stdin.close()

    res = __TPARAM_SHORT_NAME__.__TPARAM_GRADER_FUNCTION_NAME__(n)

    print(res)
    sys.stdout.close()

if __name__ == '__main__':
    main()
