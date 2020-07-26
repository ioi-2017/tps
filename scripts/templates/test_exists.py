from os.path import join, isfile

def test_exists(tests_dir, test_name):
    test_input = join(tests_dir, test_name+".in")
    test_output = join(tests_dir, test_name+".out")
    return isfile(test_input) and isfile(test_output)
