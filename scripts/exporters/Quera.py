import os
import sys
import json
import shutil
import tempfile
import argparse

from json_extract import navigate_json
from color_util import cprint, colors
from verbose import VerbosePrinter
from util import load_json
import bash_completion as bc
import tests_util as tu


PROBLEM_NAME = os.environ.get('PROBLEM_NAME')
BASE_DIR = os.environ.get('BASE_DIR')
TESTS_DIR = os.environ.get('TESTS_DIR')

warnings = []
vp = VerbosePrinter()

def warn(message):
    warnings.append(message)
    cprint(colors.WARN, message)

class ExportFailureException(Exception):
    pass

def wrapped_run(func_name, func):
    def f(*args, **kwargs):
        try:
            return vp.run(func_name, func, *args, **kwargs)
        except (OSError, IOError):
            raise ExportFailureException("Error in calling {}".format(vp.func_repr(func_name, *args, **kwargs)))
    return f

mkdir = wrapped_run("mkdir", os.mkdir)
move = wrapped_run("move", shutil.move)
makedirs = wrapped_run("makedirs", os.makedirs)
copyfile = wrapped_run("copyfile", shutil.copyfile)
make_archive = wrapped_run("make_archive", shutil.make_archive)


class QueraExporter:
    def __init__(self, temp_prob_dir):
        self.temp_prob_dir = temp_prob_dir
        self.index = {}

    def get_absolute_path(self, path):
        return os.path.join(self.temp_prob_dir, path)

    def copy_file(self, file, relative_dest):
        absolute_dest = self.get_absolute_path(relative_dest)
        copyfile(file, absolute_dest)

    def create_directory(self, path):
        absolute_path = self.get_absolute_path(path)
        makedirs(absolute_path, exist_ok=True)

    def write_to_file(self, path, content):
        absolute_path = self.get_absolute_path(path)
        if isinstance(content, str):
            file_ = open(absolute_path, "w")
        else:
            file_ = open(absolute_path, "wb")
        file_.write(content)
        file_.close()

    INPUTS_DIR_NAME = "in"
    OUTPUTS_DIR_NAME = "out"
    TESTER_FILE_NAME = "tester.cpp"
    CONFIG_FILE_NAME = "config.json"

    def export_config(self):
        vp.print("Exporting subtasks config...")
        try:
            subtasks_tests = tu.get_subtasks_tests_dict_from_tests_dir(TESTS_DIR)
        except tu.MalformedTestsException as e:
            raise ExportFailureException(str(e))
        
        SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')
        subtasks_json_data = load_json(SUBTASKS_JSON)
        subtasks_data = dict(navigate_json(subtasks_json_data, 'subtasks', SUBTASKS_JSON))

        config = {"packages": []}
        for subtask_name, subtask_data in subtasks_data.items():
            if subtask_data['score'] == 0:
                vp.print("Skipping subtask with score 0: {}".format(subtask_name))
                continue

            vp.print("Export subtask: {}".format(subtask_name))
            config['packages'].append({
                "score": subtask_data['score'],
                "tests": [
                    self.index[test_name]
                    for test_name in subtasks_tests[subtask_name]
                ]
            })

        self.write_to_file(
            self.CONFIG_FILE_NAME,
            json.dumps(config, indent=4),
        )

    def export_and_index_testcases(self):
        vp.print("Copying test data...")
        try:
            test_name_list = tu.get_test_names_from_tests_dir(TESTS_DIR)
        except tu.MalformedTestsException as e:
            raise ExportFailureException(str(e))
        vp.print_var("test_name_list", test_name_list)
        available_tests, missing_tests = tu.divide_tests_by_availability(test_name_list, TESTS_DIR)
        if missing_tests:
            warn("Missing tests: "+(", ".join(missing_tests)))
        vp.print_var("available_tests", available_tests)

        self.create_directory(self.INPUTS_DIR_NAME)
        self.create_directory(self.OUTPUTS_DIR_NAME)
        for index, test_name in enumerate(sorted(available_tests + missing_tests)):
            self.index[test_name] = index + 1
            self.copy_file(
                os.path.join(TESTS_DIR, "{}.in".format(test_name)),
                os.path.join(self.INPUTS_DIR_NAME, "input{}.txt".format(index + 1)),
            )
            self.copy_file(
                os.path.join(TESTS_DIR, "{}.out".format(test_name)),
                os.path.join(self.OUTPUTS_DIR_NAME, "output{}.txt".format(index + 1)),
            )
        
    def export_tester(self, tester_path):
        if not tester_path:
            return
        vp.print("Copying tester...")
        self.copy_file(tester_path, self.TESTER_FILE_NAME)

    def export(self, tester_path, exclude_subtasks):
        self.export_and_index_testcases()
        if not exclude_subtasks:
            self.export_config()
        if tester_path:
            self.export_tester(tester_path)


def export(file_name, tester_path, exclude_subtasks):
    """
    returns the export file name
    """
    vp.print("Exporting '{}'.zip ...".format(file_name))
    with tempfile.TemporaryDirectory(prefix=file_name) as temp_root:
        vp.print_var("temp_root", temp_root)
        temp_prob_dir_name = PROBLEM_NAME
        temp_prob_dir = os.path.join(temp_root, temp_prob_dir_name)
        mkdir(temp_prob_dir)

        QueraExporter(temp_prob_dir).export(tester_path, exclude_subtasks)

        archive_full_path = make_archive(
            os.path.join(temp_root, file_name),
            "zip",
            root_dir=temp_prob_dir,
        )
        final_export_file = move(archive_full_path, BASE_DIR)
        vp.print_var("final_export_file", final_export_file)
        return final_export_file
    
def file_completion_function(current_token_info):
    current_token = current_token_info.current_token
    directory = os.path.dirname(current_token) or "."
    try:
        files = os.listdir(directory)
    except FileNotFoundError:
        return []
    return [os.path.join(directory, file) for file in files if file.startswith(current_token)]

def bash_completion_list(argv):
    current_token_info = bc.extract_current_token_info(argv)
    return bc.simple_argument_completion(
        current_token_info=current_token_info,
        available_options=[
            "--help",
            "--verbose",
            "--exclude-subtasks",
            "--tester-path=",
            "--output-name=",
        ],
        enable_file_completion=False,
        option_value_completion_functions={
            ("-o", "--output-name"):
                bc.empty_completion_function,
            ("-t", "--tester-path"):
                file_completion_function,
        },
    )


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--bash-completion':
        sys.argv.pop(1)
        bc.print_all(bash_completion_list(sys.argv))
        sys.exit(0)

    parser = argparse.ArgumentParser(
        prog="tps export Quera",
        description="Exporter for CMS -- Contest Management System for Persian users",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Prints verbose details on values, decisions, and commands being executed.",
    )
    parser.add_argument(
        "-o", "--output-name",
        metavar="<export-output-name>",
        help="Creates the export output with the given name.",
    )
    parser.add_argument(
        "-t", "--tester-path",
        help="Specifies a path to the tester file (if any).",
    )
    parser.add_argument(
        "-s", "--exclude-subtasks",
        action="store_true",
        help="Excludes subtasks config file from the export.",
    )
    args = parser.parse_args()

    vp.enabled = args.verbose
    task_data = load_json(os.environ.get('PROBLEM_JSON'))
    file_name = args.output_name if args.output_name else task_data['name']

    try:
        export_file = export(file_name, args.tester_path, args.exclude_subtasks)
        if warnings:
            cprint(colors.WARN, "Successfully exported to '{}', but with warnings.".format(export_file))
        else:
            cprint(colors.SUCCESS, "Successfully exported to '{}'.".format(export_file))
    except ExportFailureException as e:
        cprint(colors.FAIL, "Exporting failed: {}".format(e))


if __name__ == '__main__':
    main()
