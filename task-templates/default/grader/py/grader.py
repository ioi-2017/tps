import sys
import __TPARAM_SHORT_NAME__

def main():
# $Secret
    # BEGIN SECRET
# $SecretI
    input_secret = "__TPARAM_INPUT_SECRET__"
# $SecretO
    output_secret = "__TPARAM_OUTPUT_SECRET__"
# $SecretI
    secret = input()
# $SecretI
    if secret != input_secret:
# $SecretIO
        print(output_secret)
# $SecretI
        print("PV")
# $SecretI
        print("Possible tampering with the input")
# $SecretI
        sys.stdout.close()
# $SecretI
        return
# $Secret
    # END SECRET
    n = int(input())
    sys.stdin.close()

    res = __TPARAM_SHORT_NAME__.__TPARAM_GRADER_FUNCTION_NAME__(n)

    # BEGIN SECRET
# $SecretO
    print(output_secret)
    print("OK")
    # END SECRET
    print(res)
    sys.stdout.close()

if __name__ == '__main__':
    main()
