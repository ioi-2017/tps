import sys
import os
import json
import argparse
import tempfile
import shutil

from util import load_json, get_bool_environ
from color_util import cprint, colors
import bash_completion as bc
from verbose import VerbosePrinter
from json_extract import navigate_json
import tests_util as tu


PROBLEM_NAME = os.environ.get("PROBLEM_NAME")
BASE_DIR = os.environ.get("BASE_DIR")
TESTS_DIR = os.environ.get("TESTS_DIR")

warnings = []


def warn(message):
    warnings.append(message)
    cprint(colors.WARN, message)


vp = VerbosePrinter()


class ExportFailureException(Exception):
    pass


def check_dir_exists(dir_name, title):
    if not os.path.exists(dir_name):
        raise ExportFailureException("{} not found: '{}'.".format(title, dir_name))
    if not os.path.isdir(dir_name):
        raise ExportFailureException(
            "{} not a valid directory: '{}'.".format(title, dir_name)
        )


def wrapped_run(func_name, func):
    def f(*args, **kwargs):
        try:
            return vp.run(func_name, func, *args, **kwargs)
        except (OSError, IOError):
            raise ExportFailureException(
                "Error in calling {}".format(vp.func_repr(func_name, *args, **kwargs))
            )

    return f


mkdir = wrapped_run("mkdir", os.mkdir)
makedirs = wrapped_run("makedirs", os.makedirs)
copyfile = wrapped_run("copyfile", shutil.copyfile)
move = wrapped_run("move", shutil.move)
make_archive = wrapped_run("make_archive", shutil.make_archive)


class QueraExporter:
    def __init__(self, temp_prob_dir):
        self.temp_prob_dir = temp_prob_dir
        self.counter = 0
        self.test_id = dict()

    def get_absolute_path(self, path):
        return os.path.join(self.temp_prob_dir, path)

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

    def copy_file(self, file, relative_dest):
        absolute_dest = self.get_absolute_path(relative_dest)
        copyfile(file, absolute_dest)

    CONFIG_NAME = "config.json"
    TESTS_INPUT_DIR_NAME = "in"
    TESTS_OUTPUT_DIR_NAME = "out"

    def get_id(self, test_name):
        if test_name not in self.test_id:
            self.counter += 1
            self.test_id[test_name] = self.counter
        return self.test_id[test_name]

    def export_subtasks(self):
        vp.print("Exporting subtasks...")
        try:
            subtasks_tests = tu.get_subtasks_tests_dict_from_tests_dir(TESTS_DIR)
        except tu.MalformedTestsException as e:
            raise ExportFailureException(str(e))

        SUBTASKS_JSON = os.environ.get("SUBTASKS_JSON")
        subtasks_json_data = load_json(SUBTASKS_JSON)
        subtasks_data = dict(
            navigate_json(subtasks_json_data, "subtasks", SUBTASKS_JSON)
        )
        subtasks_list = []
        for subtask_name, subtask_data in subtasks_data.items():
            vp.print("Export subtask: {}".format(subtask_name))
            subtasks_list.append(
                {
                    "score": subtask_data["score"],
                    "tests": [self.get_id(t) for t in subtasks_tests[subtask_name]],
                }
            )

        self.write_to_file(self.CONFIG_NAME, json.dumps({"packages": subtasks_list}))

    def export_checker(self):
        HAS_CHECKER = get_bool_environ("HAS_CHECKER")
        if not HAS_CHECKER:
            vp.print("No checker to export.")
            return
        else:
            warn("Can not export checker.")
            return

    def export_testcases(self):
        vp.print("Copying test data...")
        try:
            test_name_list = tu.get_test_names_from_tests_dir(TESTS_DIR)
        except tu.MalformedTestsException as e:
            raise ExportFailureException(str(e))
        available_tests, missing_tests = tu.divide_tests_by_availability(
            test_name_list, TESTS_DIR
        )
        if missing_tests:
            warn("Missing tests: " + (", ".join(missing_tests)))
        vp.print_var("available_tests", available_tests)
        try:
            subtasks_tests = tu.get_subtasks_tests_dict_from_tests_dir(TESTS_DIR)
        except tu.MalformedTestsException as e:
            raise ExportFailureException(str(e))

        tests = set()
        SUBTASKS_JSON = os.environ.get("SUBTASKS_JSON")
        subtasks_json_data = load_json(SUBTASKS_JSON)
        vp.print_var("subtasks_json_data", subtasks_json_data)
        subtasks_data = dict(
            navigate_json(subtasks_json_data, "subtasks", SUBTASKS_JSON)
        )
        vp.print_var("subtasks_data", subtasks_data)
        for subtask_name, subtask_data in subtasks_data.items():
            tests = tests.union(subtasks_tests[subtask_name])
        vp.print_var("tests", tests)
        self.create_directory(self.TESTS_INPUT_DIR_NAME)
        self.create_directory(self.TESTS_OUTPUT_DIR_NAME)
        for test_name in sorted(tests):
            if test_name in available_tests:
                self.copy_file(
                    os.path.join(TESTS_DIR, "{}.in".format(test_name)),
                    os.path.join(
                        self.TESTS_INPUT_DIR_NAME,
                        "input{}.txt".format(self.get_id(test_name)),
                    ),
                )
                self.copy_file(
                    os.path.join(TESTS_DIR, "{}.out".format(test_name)),
                    os.path.join(
                        self.TESTS_OUTPUT_DIR_NAME,
                        "output{}.txt".format(self.get_id(test_name)),
                    ),
                )

    def export(self):
        # We don't export generators or validators. Tests are already generated/validated.
        # We don't export checkers, as Quera handles checkers differently.
        self.export_testcases()
        self.export_subtasks()


def export(
    file_name,
):
    """
    returns the export file name
    """
    vp.print("Exporting '{}'.zip ...".format(file_name))
    with tempfile.TemporaryDirectory(prefix=file_name) as temp_root:
        vp.print_var("temp_root", temp_root)
        temp_prob_dir_name = PROBLEM_NAME
        temp_prob_dir = os.path.join(temp_root, temp_prob_dir_name)
        mkdir(temp_prob_dir)

        QueraExporter(temp_prob_dir).export()

        archive_full_path = make_archive(
            os.path.join(temp_root, file_name),
            "zip",
            root_dir=temp_prob_dir,
        )
        final_export_file = move(archive_full_path, BASE_DIR)
        vp.print_var("final_export_file", final_export_file)
        return final_export_file


def check_zip_format_exists():
    return any(
        archive_format[0].lower() == "zip"
        for archive_format in shutil.get_archive_formats()
    )


def bash_completion_list(argv):
    current_token_info = bc.extract_current_token_info(argv)
    return bc.simple_argument_completion(
        current_token_info=current_token_info,
        available_options=[
            "--help",
            "--verbose",
            "--output-name=",
        ],
        enable_file_completion=False,
        option_value_completion_functions={
            ("-o", "--output-name"): bc.empty_completion_function,
        },
    )


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--bash-completion":
        sys.argv.pop(1)
        bc.print_all(bash_completion_list(sys.argv))
        sys.exit(0)

    parser = argparse.ArgumentParser(
        prog="tps export Quera",
        description="Exporter for Quera -- Programming Website.",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Prints verbose details on values, decisions, and commands being executed.",
    )
    parser.add_argument(
        "-o",
        "--output-name",
        metavar="<export-output-name>",
        help="Creates the export output with the given name.",
    )
    args = parser.parse_args()

    if not check_zip_format_exists():
        cprint(colors.FAIL, "Exporting failed: ZIP format is not available")
        return

    vp.enabled = args.verbose
    task_data = load_json(os.environ.get("PROBLEM_JSON"))
    file_name = args.output_name if args.output_name else "problem"

    try:
        export_file = export(file_name)
        if warnings:
            cprint(
                colors.WARN,
                "Successfully exported to '{}', but with warnings.".format(export_file),
            )
        else:
            cprint(colors.SUCCESS, "Successfully exported to '{}'.".format(export_file))
    except ExportFailureException as e:
        cprint(colors.FAIL, "Exporting failed: {}".format(e))


if __name__ == "__main__":
    main()
