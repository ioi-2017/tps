from os.path import join, isfile

def test_exists(tests_dir, test_name):
    test_input = join(tests_dir, test_name+".in")
    test_output = join(tests_dir, test_name+".out")
    return isfile(test_input) and isfile(test_output)



if __name__ == '__main__':
    from sys import stderr, argv
    if len(argv) != 3:
        from util import simple_usage_message
        simple_usage_message("<tests-dir> <test-name>")

    tests_dir=argv[1]
    test_name=argv[2]
    
    exit(0 if test_exists(tests_dir, test_name) else 1)
