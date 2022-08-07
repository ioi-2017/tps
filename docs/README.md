# Task Preparation System (TPS)

Version 1.13

Host Technical Committee, Host Scientific Committee

IOI 2017, Tehran, Iran


# TPS Interfaces

The TPS has two interfaces:
 a command-line interface
 that is ideal for those who love terminal,
 and a web interface with a GUI.
Currently the web interface is read-only,
 hence any changes to the task statement or test material
 should be done through the git interface.
The main functionality of the web interface is to invoke solutions over the whole set of tests
 to see how they perform on the real contest machines, in parallel.

The following sections describe these interfaces.

# Installing command-line interface

It is possible to install the TPS command-line interface
 using an online installer,
 or through a manual installation process.

## Online installation

Run the following command to install TPS on Linux/MacOS/Windows (with WSL):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ioi-2017/tps/master/online-installer/install.sh)"
```

Online installer assumes you have `git` installed in your system.
It clones the tps repo and installs it.

You can customize its installation
 by setting these environment variables before running the above command:

| Variable                  | Description                               | Default                               |
| ------------------------- | ----------------------------------------- | ------------------------------------- |
| `TPS_LOCAL_REPO`          | Directory to store TPS code repository in | `$HOME/.local/share/tps`              |
| `TPS_REMOTE_REPO_GIT_URL` | Git URL of the remote repo                | `https://github.com/ioi-2017/tps.git` |
| `TPS_REMOTE_BRANCH`       | Branch to install from                    | `master`                              |

### Manual installation

Clone the `tps` repository,
 and install it using the following commands (in Linux):

```
cd tps
sudo ./install-tps.sh
```

Windows users can run `install-tps.bat`.
The Windows installer assumes you have `MinGW`/`MSYS` installed and
  the directory `C:\msys\scripts` is in your PATH.
Command completion is not supported in windows `CMD`.


# Prerequisites for the command-line interface

It is recommended to install bash completion
 if it is not already installed
 (there is a manual for OS/X [here](http://davidalger.com/development/bash-completion-on-os-x-with-brew/)).

TPS currently supports C++, Pascal, Java, and Python for solutions.
The `gcc` compiler is mandatory,
 and `fpc` (Free Pascal) and java compilers are required
 if there are invocations of those languages.

Python is an essential dependency for executing the TPS scripts.
It is also needed for invocations of Python solutions.
You can set the environment variable `PYTHON` to `python3`, `python2`, `python`,
 or any other Python interpreter with which you want to run the solution.
If the environment variable `PYTHON` is not set,
 TPS first looks for the command `python3`
 (or `python2` if the solution extension is `py2` instead of `py`),
 and if it was not available, it falls back to the command `python`.

Windows users should install the python package `colorama`
 in order to have colorful outputs.
In return, non-windows users should install the python package `psutil`
 to be able to invoke solutions (using `tps invoke`).

You can install a python package by running:

```
sudo pip install package-name
```

or:

```
sudo python -m pip install package-name
```

The `dos2unix` command is required for making public directories
 and task attachments (using `tps make-public`).
It is also suggested to be available
 when generating tests (using `tps gen`).
You may install it in linux using:

```
sudo apt install dos2unix
```

and in OS/X using:

```
brew install dos2unix
```

You can install `dos2unix` on Windows through GnuWin32 packages.

The system should have the GNU `make` command (for `Makefile`s).


# Task Directory Structure

Let's explain the current directory structure of tasks.
Consider the task *mountains* for instance.
It is available in the samples directory.
It contains the statement, codes, and all test material for the task.
Here is a brief description of files and subdirectories in each task directory:

## problem.json

This file contains the general description of the task.
It has several attributes:

`name`: The short name of the task.

`code`: A unique code assigned to each task in the TPS web-interface.
Usually it is the same as the `name`,
 but the `code` is fixed even if the `name` is changed.

`title`: Task title, as appears in the task statement.

`type`: Task type, that can be `Batch`, `Communication`, `OutputOnly`, or `TwoSteps`.

`time_limit`: A real number, the maximum CPU time (in seconds) of the main process
 (does not include CPU time of manager or IO).

`memory_limit`: the maximum memory that can be used by the main process, in MB.

`description`: An optional description of the task.

Below is a sample `problem.json`:

```
{
    "name": "mountains",
    "code": "mountains",
    "title": "Mountains",
    "memory_limit": 256,
    "time_limit": 1.0,
    "type": "Batch",
    "description": "Find maximum number of Deevs"
}
```

Other attributes may appear in `problem.json` occasionally:

* `tps_web_url`:
  URL as a base for TPS web URL of the same task.
  It has no use if TPS web interface is not used.

* `has_grader`:
  It specifies
  if the solution files are standalone programs
  or compiled against a provided grader.
  Default value: `false` in OutputOnly tasks, `true` in other task types.

* `grader_name`:
  The name of grader file against which the solution files are compiled.
  You may need to set `grader_name` to `stub` in Communication tasks.
  Default value: `grader`

* `has_checker`:
  It specifies
  if the solution outputs are compared using `diff`
  or judged with a checker.
  Default value: `false` in Communication tasks, `true` in other task types.

* `has_manager`:
  It specifies
  if the solution files are interacting with a manager program
  during a test case scenario.
  Default value: `true` in Communication tasks, `false` in other task types.

* `num_processes`:
  It specifies
  the number of times
  the contestant solution must be executed
  during a test case scenario
  in Communication tasks.
  Default value: $1$.


Attributes for enabling/disabling programming languages in `problem.json`:
* `cpp_enabled`: Default: true
* `java_enabled`: Default: true
* `pascal_enabled`: Default: false
* `python_enabled`: Default: false


## gen/

All the required files for generating test data are here.
It contains `testlib.h`, `Makefile`,
 and all the codes that are used to generate the test data.
It can contain a directory `manual`
 that contains manually created test data,
 so that they can be used in `gen/data`.

## gen/data

This file contains the arguments used to generate test data,
 and their mapping to the subtasks.
It is separated into several test-sets.
Each test-set can include other test-sets by a line starting with `@include`.
A test-set can be an actual subtask (`@subtask`),
 or just a test-set (`@testset`)
 that can be included in the other subtasks.

There are two special test generation commands,
 available to be used in `gen/data`:
* `copy`: Gets a single argument;
  a file path
  that is copied as a test case input.
* `manual`: Gets a single argument;
  a file name which shall be available in directory `gen/manual`
  and is copied as a test case input.


Below is an example:

```
@subtask samples
copy ../public/examples/01.in
copy ../public/examples/02.in
# Copies the sample test case inputs from directory "public/examples".

# A comment is here
@testset ABC
gencode random 2
# Another comment
gencode slow_up 19 asdgs

@subtask 2^n
gencode slow_up 19 sfgrev
@include ABC
gencode wall-envlope 19
gencode semi-manual 19
gencode magic 19
manual man-01.in
# Uses the manually created test from directory "manual".

@testset apple
gencode random 40 qwetf
gencode sqr 40 cefut
gencode random 40 sadfa

@subtask bt
@include 2^n apple
# Inclusion is transitive, so it also includes ABC
gencode magic 40

@subtask full
@include bt
gencode random 1000 ovuef
gencode random 2000 ocewu
gencode magic 2000
```

## grader/

This directory is used
 only if the task has graders
 (e.g. `has_grader` is not `false` in `problem.json`).
It contains the program that have the main routine,
 which will be compiled with a solution or contestant's source code
 and call its functions.
It contains one directory for each programming language (cpp/pas/java/py),
 which contains a specific grader for that language.
The `cpp` directory usually contains a `.h` interface file
 that is included in grader
 (and possibly in contestant's program).
It contains the graders that are used by the judging system.
The public grader,
 which is given to the contestants during the contest,
 can be the same as this graders,
 or can be automatically created from the grader by removing the secret parts,
 which are bounded between `// BEGIN SECRET` and `// END SECRET` lines
 (`# BEGIN SECRET` and `# END SECRET` in case of python language),
 or can be prepared separately.

## checker/

This directory is used
 only if the task has checker
 (e.g. `has_checker` is not `false` in `problem.json`).
It contains a program, `checker.cpp`,
 that takes the input, output and answer of a test
 and checks if the output is correct or wrong,
 or evaluates the output in partial-scoring tasks.
It also contains `testlib.h`
 that the checker file usually uses.
The file `testlib.h` used in TPS directories
 is a little bit different from
 [its official version](https://github.com/MikeMirzayanov/testlib).
The modifications are to make it compatible with CMS and TPS.

Note:
As based on protocol,
 TPS and CMS read the first lines of standard output/error of the checker
 (written by `testlib` on quitting the checker),
 make sure not to print to these streams in the checker code.
Otherwise, the judgment behavior is undefined.

## solution/

It contains all solutions
 that are prepared and used in development of the task,
 for different programming languages (all in the same directory).
Each solution has a verdict that are listed in `solutions.json` file.

## solutions.json

This file specifies the verdict of each solution.
It is used by the web-interface
 to check if the behavior of each solution is expected on the test data.
The verdicts can be
 `correct`,
 `time_limit`,
 `memory_limit`,
 `incorrect`,
 `runtime_error`,
 `failed`,
 `time_limit_and_runtime_error`,
 `partially_correct`.
There is also a special verdict `model_solution`
 which should be used exactly once.
The model solution is used to generate the correct outputs for test data.
Below is an example:

```
{
	"main-solution.cpp": {"verdict": "model_solution"},
	"alternative-sol.cpp": {"verdict": "correct"},
	"correct-sol.java": {"verdict": "correct"},
	"greedy.cpp": {
		"verdict": "incorrect",
		"except": {"samples": "correct", "n2": "time_limit"}
	}
}
```

## validator/

This directory contains validators
 for the whole set of test data (global validators),
 or for each/multiple subtask(s),
 and a Makefile for compiling validators.
It also contains `testlib.h`
 that the validators usually use.

## subtasks.json

It contains the information of all subtasks, including:
* `index`: the number of the subtask.
  It naturally should start with $0$ when there is a `samples` subtask.
  In output-only tasks which usually do not have the sample tests as subtask,
  the subtasks indices should start with $1$.
* `score`: the score of the subtask.
  The total scores over all subtasks should be $100$.
* `validators`: the list of validators specific to the subtask.

In addition, it contains the list of global validators (`global_validators`).
A global validator validates each test exactly once
 regardless of the subtasks it belongs.
There may also be the list of subtask-sensitive validators (`subtask_sensitive_validators`)
 which validate each test once for each subtask containing the test.
The subtask name is passed to the subtask-sensitive validator
 through the `{subtask}` argument placeholder.
Passing arguments to the validators is supported.

Below is an example:

```
{
    "global_validators": ["validator.cpp"],
    "subtask_sensitive_validators": ["subtask-val.cpp --group {subtask}"],
    "subtasks": {
          "samples": {
               "index": 0,
               "score": 0,
                "validators": []
          },
          "2^n": {
                "index": 1,
                "score": 20,
                "validators": ["validator_sub1.cpp", "grep hello"]
          },
          "bt": {
                "index": 2,
                "score": 20,
                "validators": ["validator_sub2.java"]
          },
          "n3": {
                "index": 3,
                "score": 30,
                "validators": ["validator_sub3.py arg1", "my-bash-val.sh"]
          },
          "full": {
                "index": 4,
                "score": 30,
                "validators": []
          }
    }
}
```

## statement/

This directory contains the task statement
 which is usually in markdown or latex format.
The source file is then something like `index.md` or `some-file.tex`,
 from which HTML, PDF, or other formats will be created.
The pictures can be placed here as well.


## scripts/

All the scripts used by the TPS command for this task are stored here.
If you invoke
```
tps mycommand ...
```
it will look in this directory for `mycommand.sh`, `mycommand.py`, and `mycommand.exe`.

The `scripts` directory has the following subdirectories:

* `bash_completion`:
This directory contains the data used for bash completion.

* `internal`:
The private scripts (those that are not going to be invoked directly) are kept in this directory.

* `templates`:
Some code fragments are more prone to change in customized tasks.
These fragments are extracted from the scripts
 and kept in this directory,
 so that they can be found and modified more easily.

* `exporters`:
This directory contains the task exporter scripts.
Read  [the export section](#export) for details.


## public/

All the public graders,
 example test data,
 sample source codes
 and compile scripts
 to be given to the contestants
 are stored here.
The public package of task files is created
 using `tps make-public`
 according to file `public/files`.


## public/files

This file defines how
 the public package of task files given to the contestants
 is prepared.
Every file
 that is going to be put in the archive
 should be explicitly mentioned in this file.
The following commands can be used to add a file:

* `public <public-file-path>`:
  The same file in the `public` directory is used
  after some fixing (dos2unix).

* `grader <grader-file-path>`:
  The file is going to be generated
  from the equivalent file in the `grader` directory,
  using the `pgg` (Public Grader Generator) script.
  This script removes the secret parts of the judge grader
  that are specified through `BEGIN SECRET`/`END SECRET` markers.

* `copy_test_inputs <gen/data file> <public tests dir> <generated tests dir>`:
  This command is mainly used in output-only tasks.
  It copies all test inputs
  based on file `gen/data`
  from directory `tests`
  to directory `public/tests`.
  **Important**:
  It assumes that
  the test data is already generated
  and available in the `tests` directory
  (naturally, using `tps gen`).

Note that the keywords
 `PROBLEM_NAME_PLACE_HOLDER`
 and
 `GRADER_NAME_PLACE_HOLDER`
 in file names
 are representing the task name and the grader name respectively
 (specified in `problem.json`)
 and are automatically replaced during the execution.
So, it is not needed
 to replace them with their real values in the file.



Example:

```
public cpp/compile_cpp.sh
public cpp/PROBLEM_NAME_PLACE_HOLDER.cpp
grader cpp/PROBLEM_NAME_PLACE_HOLDER.h
grader cpp/GRADER_NAME_PLACE_HOLDER.cpp

public py/compile_py.sh
public py/PROBLEM_NAME_PLACE_HOLDER.py
grader py/GRADER_NAME_PLACE_HOLDER.py

public java/compile_java.sh
public java/run_java.sh
public java/PROBLEM_NAME_PLACE_HOLDER.java
grader java/GRADER_NAME_PLACE_HOLDER.java

#this is a comment

public examples/01.in
public examples/01.out
public examples/02.in
public examples/02.out
```



## tests/

After running the generators (using `tps gen`),
 it will contain the following material:
* The generated test data (both input and output files).
* A file named `mapping`
  that specifies the mapping of test cases to subtasks.
  For each test case $c$ and subtask $s$ containing $c$,
  there is a line containing $s$ and $c$.
  The same test can be mapped to multiple subtasks.
  This mapping is used during the validation of test cases,
  and also in exporting to CMS.
* A file named `gen_summary` which contains a summary of data generation process.
  For each line of test generation in file `gen/data`,
  its line number,
  its contents,
  and name of the corresponding generated test
  is written to `gen_summary`.

## sandbox/

A directory that is used to compile solutions,
 and run them over the test data.

## logs/

Contains all compile and run logs
 on the last execution of `gen` or `invoke`.


## Derived directories

Note that `logs`, `sandbox`, and `tests` are _derived_ directories
 i.e. their content is computed based on other files.
So, these directories are in `.gitignore`.


## Note on `Makefile`s

While solutions are compiled in the sandbox
 (every time, from scratch),
 the other codes which should be compiled
 are built with `Makefile`s.
This covers input generators,
 input validators,
 and the checker.

TPS has the ability to detect compilation warnings.
For being able to do that,
 the `Makefile`s should not only generate the executables,
 but also write the compilation outputs/logs in separate files.
These files are then processed by TPS
 to check if there was a compilation warning.
A `Makefile` should also have a special target named `compile_outputs_list`
 which prints the list of file names for all compilation outputs generated.

One may ask
 why the output of the `make` command itself is not processed to detect the warnings.
That's because
 the `make` command does not perform the compilation again
 if the executables are already built and up-to-date.
So, if it was implemented that way,
 no warning could be detected in such cases.

[A well-implemented version of `Makefile` (named `Makefile.sample`)](../extra-assets/Makefile.sample)
 is available in the [`extra-assets` directory](../extra-assets/).

# TPS commands

TPS provides a `tps` command
 with bash auto-completion functionality.
Here is the usage:

```
tps &lt;command&gt; &lt;arguments&gt;...
```

Below are the list of commands
 that can usually be used with `tps`.
The exact list of commands depends on
 the contents of the `scripts` directory in the task package.


## verify

This command verifies the whole directory structure,
  and reports error or warning messages accordingly.
It is quite useful in finding inconsistencies.

## compile

This command gets a single solution and does the following:
* Detects the programming language.
* Puts the solution in the `sandbox` directory with the appropriate name
  (naturally, renamed to the task name).
* Puts the necessary grader files in the sandbox.
* Compiles and links the solution with the grader.
* Creates `exec.sh` in the sandbox.
  This script runs the program based on the detected programming language.
  The complexities due to the different programming languages
  are wrapped by this script.
  So, one would rather use this script
  instead of directly running the compiled binary.
* Creates `run.sh` in the sandbox.
  This script uses `exec.sh`
  and implements the logic of running the program based on the task type.
  For example,
  it handles the pipes and interactions with the manager
  in tasks of type `Communication`,
  or it runs both two phases of execution in tasks of type `TwoSteps`.
  Naturally, it is more common to run the solution
  using `run.sh` instead of running through `exec.sh`.
* If the compile process is finished successfully,
  the script then looks for `scripts/templates/post_compile.sh`
  and runs it if it is available.
  This hook script is useful in some task types,
  when something special should be done
  in addition to the normal compile process.
  For example,
  in compiling `Communication` tasks,
  a "manager" file should also be compiled
  and put beside the grader.
  In older implementations
  (where the compilation process was not specialized for `Communication` tasks),
  this was achieved using `post_compile.sh`,
  without the need for modifying the main compile script itself.

Here is the usage format:

```
tps compile [options] &lt;solution-path&gt;
```


In addition to the solution path,
 the command can get some options:
* `-h, --help`:
  Shows the help.
* `-v, --verbose`:
  Prints verbose details during the execution.
  It prints the value of important variables,
  the decisions made based on the state, and commands being executed.
* `-w, --warning-sensitive`:
  Fails (exits with a nonzero code)
  when warnings were detected during the compilation process.
* `-p, --public`:
  Uses the public graders (in directory `public`) for compiling and linking with the solution,
  instead of the judge graders (in directory `grader`).
  This is mainly useful for
  verifying and testing the public graders and example tests.


## run

In short, it runs the compiled solution in the sandbox.
But, there is more to say!

As mentioned in the description of the `compile` command,
  it also creates a script `run.sh` in `sandbox`
  which wraps both the complexities of having different programming languages
  and the complexities of having different task types.
When being in different directories,
  directly executing `run.sh` needs annoying relative addressings like `../../sandbox/run.sh`.
The `run` command in TPS handles this addressing issue.
So, being in any location of the task directory structure,
 the same thing should be entered in the command-line:

```
tps run  < input-file  > output-file
```

This command seems quite basic.
It gets the solution input from the standard input
 and sends the solution output to the standard output.
It does not consider task constraints like time limit.
You should use the `invoke` command (discussed in the next sections)
 to consider those limits and run against the test cases.


## crun

This command is a shortcut for `compile` and `run` commands.
It gets a single solution, then will compile and run it.
This simplifies the testing of
 the solutions that could be
 tested using standard input and standard output.

Here is the usage:

```
tps crun [options] &lt;solution-path&gt;  [ -- &lt;solution-run-arguments&gt... ]
```

In addition to the solution path,
 the command can get some options
 that are similar to the options from the `compile` command above.
* `-h, --help`:
  Shows the help.
* `-w, --warning-sensitive`:
  Fails (exits with a nonzero code)
  when warnings were detected during the compilation process.
* `-p, --public`:
  Uses the public graders (in directory `public`)
  for compiling and linking with the solution,
  instead of the judge graders (in directory `grader`).

If the compilation fails,
 the process is terminated
 after printing the error details.
Otherwise,
 a single line about the compilation result
 is printed to the standard error
 and then the compiled solution is executed.

Just in case,
 if it is needed to pass arguments to the solution program,
 you should place the arguments after a "`--`" argument.
Example:
```
tps crun "path/to/sol.cpp" -w -- "arg-being-passed-to-sol"
```



## gen

Compiles generator, model-solution, and validator,
  and then generates and validates the test inputs
  and runs the model solution on them to generate the test outputs.
The generated test cases are placed in the `tests` directory.

Each test is assigned a test name by the TPS.
Currently, the test names are in `X-YY` format,
  where `X` is the subtask name (or testset number, starting from `0`),
  and `YY` is the test number,
  starting from `01`, in the same order of their presence in the `gen/data` file.
This format is set in `scripts/templates/test_name.py`
 and can be changed per task, if required.
Default naming of the tests is different in output-only tasks;
 it is just `YY` where `YY` is the test number.

The command options are:

* `-h, --help`:
  Shows the help.
* `-s, --sensitive`:
  Terminates the generation process
  on the first error and shows the error details.
* `-w, --warning-sensitive`:
  Terminates the generation process
  on the first warning or error and shows the details.
  It also enables the `--sensitive` flag implicitly.
* `-u, --update`:
  Updates the currently existing set of tests.
  This option prevents the initial cleanup of the `tests` directory
  and is used when a subset of test data needs to be generated again.
  *Warning:* Use this feature only when
  the other tests are not needed or already generated correctly.
* `-t, --test=<test-name-pattern>`:
  Runs the process of test generation for a subset of tests.
  A test is generated if and only if its name matches the given pattern.
  Example patterns are `1-01`, `'1-*'`, and `'1-0?'`.
  Multiple patterns can be given using commas or pipes.
  Examples of multiple patterns are "`1-01, 2-*`", "`?-01|*2|0-*`".
  Note:
  When using wildcards,
  do not forget to use quotation marks or escaping (using `\`) in the pattern
  to prevent shell expansion.
  Also, use escaping (with `\`) when separating multiple patterns using pipes.
* `-m, --model-solution=<model-solution-path>`:
  Overrides the model solution used for generating test outputs.
* `-d, --gen-data=<gen-data-file>`:
  Overrides the location of meta-data file used for test generation
  (instead of `gen/data`).
* `--tests-dir=<tests-directory-path>`:
  Overrides the location of the tests directory
  (instead of `tests`).
* `--no-gen`:
  Skips running the generators for generating test inputs.
  This option prevents the initial cleanup of the tests directory
  and is used when test inputs are already thoroughly generated
  and only test outputs need to be generated.
* `--no-sol`:
  Skips running the model solution for generating test outputs.
* `--no-val`:
  Skips validating test inputs.
* `--no-sol-compile`:
  Skips compiling the model solution
  and uses the solution already compiled and available in the sandbox.

Here are some notes/features on this command:
* The contents of the `tests` directory
  (or the directory specified with `--tests-dir`)
  is completely cleared in the beginning of execution.
  The exception is when flags `-u`, `--update`, or `--no-gen` are set.
* The script warns for each test if it has no validator.
* Files `mapping` and `gen_summary` in the `tests` directory
  are also generated when this command is run.
* If file `input.header` is available in the `gen` directory,
  its contents is inserted in the beginning of each input.
* If file `output.header` is available in the `gen` directory,
  its contents is appended to the end of each input.
* A `dos2unix` is applied on the generated inputs
  if the command is available.
* The `logs` directory is completely cleared
  in the beginning of this script.
  All the steps are logged in separate files in this directory.



## invoke

This command is used to compile a solution and the checker,
 run the solution over the test data
 (with the problem constraints, e.g. time limit)
 and check its output.
Here is the usage:

```
tps invoke [options] &lt;solution-path&gt;
```

Below are the command options:
* `-h, --help`:
  Shows the help.
* `-s, --sensitive`:
  Terminates the invocation process on the first error.
  Note that
  solution failures such as `Wrong Answer` or `Runtime Error`
  are not considered an error here,
  but the verdict `Judge Failure` is considered as an error.
* `-w, --warning-sensitive`:
  Terminates the invocation process on the first warning or error
  and shows the details.
  It also enables the `--sensitive` flag implicitly.
* `-r, --show-reason`:
  Displays the failure reason for each test case.
  The checker message is written in the case of `Wrong Answer`.
* `-t, --test=<test-name-pattern>`:
  Runs the invocation process on a subset of tests.
  The invocation is run on each test
  if and only if its name matches the given pattern.
  Example patterns are `1-01`, `'1-*'`, and `'1-0?'`.
  Multiple patterns can be given using commas or pipes.
  Examples of multiple patterns are "`1-01, 2-*`", "`?-01|*2|0-*`".
  Note:
  When using wildcards,
  do not forget to use quotation marks or escaping (using `\`) in the pattern
  to prevent shell expansion.
  Also, use escaping (with `\`) when separating multiple patterns using pipes.
* `--tests-dir=<tests-directory-path>`:
  Overrides the location of the tests directory
  (instead of `tests`).
* `--no-check`:
  Skips running the checker on solution outputs.
* `--no-sol-compile`:
  Skips compiling the solution
  and uses the solution already compiled and available in the sandbox.
* `--no-tle`:
  Removes the default time limit on the execution of the solution.
  It actually sets the time limit to $24$ hours.
* `--time-limit=<time-limit>`:
  Overrides the time limit (specified in `problem.json`) on the solution execution.
  The time limit is given in seconds.
  For example, `--time-limit=1.2` means $1.2$ seconds.
* `--hard-time-limit=<hard-time-limit>`:
  Specifies the hard time limit on solution execution,
  i.e. the time after which the solution process will be killed.
  This limit is also given in seconds
  and its default value is $2$ seconds more than the (soft) time limit.
  Note that
  the hard time limit must be greater than the (soft) time limit.


Here are some notes/features on this command:
* This script runs based on the assumption that
  the test data is already generated and placed in the `tests` directory
  (or the directory specified with `--tests-dir`).
* The script needs the file `gen_summary` in the tests directory
  (generated by the `gen` command)
  in order to detect the test cases.
  Make sure
  the file is not removed or modified manually.
* The script reports the test cases
  which are (for any reason) not available in the tests directory
  but the invocation should have been run on them.
* The script prints a summary for each subtask
  that includes the score,
  the number of invoked test cases,
  and the comparison with the expected verdict.
* The `logs` directory is completely cleared
  in the beginning of this script.
  All the steps are logged in separate files in this directory.
* In addition to the verdict,
  the running time and the score of the solution is printed for each test case.
  The score is usually zero or one,
  unless the verdict is `Partially Correct`.


## stress

This command puts a solution under stress testing.
More specifically,
 it runs the solution against a series of (randomly) generated test cases
 in order to find a test case for
 which the solution fails,
 or so called, is "hacked".
This process is done through a series of rounds.
The following steps are performed in each round:
1. A "test case generation string" is first produced
  (we will later explain how this is done).
  This string is a single-line text
  similar to the test generation lines in file `gen/data`.
1. The test case input is generated
  from the test case generation string.
1. The generated test case input
  is validated by the global validators.
1. The corresponding test case output
  is produced by the model solution.
1. The stressed solution is invoked
  with the generated test case as input.
  The score and verdict of the invocation
  is specified similar to the command `tps invoke`.
1. The stressed solution is considered
  to be hacked by the generated test case
  if it does not get the required score.


In addition to the presentations in the standard output,
 test case generation strings by which the solution is hacked
 are written into `logs/hacked.txt` too.


Here is the usage format:

```
tps stress [options] &lt;solution-file&gt; &lt;test-case-generation-arg&gt;
```

The first positional argument (`<solution-file>`)
 specifies the path of the solution file to be stressed.
The second positional argument (`<test-case-generation-arg>`)
 is one of the following:
* The path to a _test case generation file_;
  a python file
  which produces the test case generation strings.
  The python file must implement a function "`gen_command()`"
  that gets no arguments as input.
  Upon each call, this function must return a test case generation string.
  Here is an example of a test case generation file:

  ```
  from stress_test_gen_utils import *

  def gen_command():
      return "gen 100 {} {}".format(
          random.randint(1, 100),
          ustr(8, 10),
      )
  ```
  As seen in the example,
  the module `stress_test_gen_utils`
  (located at `scripts/templates/stress_test_gen_utils.py`)
  is available for the test case generation file for importing
  and provides utilities such as the function "`ustr`"
  (which generates a uniformly random string with length in the specified range).
  It also imports the module `random`.

* A _test case generation format string_;
  a general string used for producing test case generation strings.
  The string must be in the shape of a format string in python.
  Upon each evaluation,
  the format string must produce a test case generation string.
  Here is the test case generation format string
  equivalent to the test case generation file
  in the example above.

  ```
  "gen 100 {random.randint(1, 100)} {ustr(8, 10)}"
  ```
  The elements of the module `stress_test_gen_utils`
   (and thus also the module `random`)
   are automatically imported when evaluating the format string.
  For using other modules in the format string,
   the option `-i`/`--import` can be used
   (for multiple times).
  Here is an example:

   ```
   tps stress "solution/x.cpp" -i math --import string \
              "gen 100 {math.factorial(random.randint(1, 5))} \
                       {ustr(7, 13, string.ascii_uppercase)}"
   ```
  Limitations:
  * This feature requires python `3.6+`,
  * Triple-apostrophes (`'''`) are not allowed in the format string
   (due to the issues in the current version of implementation).

The second positional argument (`<test-case-generation-arg>`)
 will be interpreted as a test case generation file path
 if an ordinary file exists with the same path as that argument.
Otherwise, it will be interpreted as a test case generation format string.
In a rare case that a test case generation format string
 happens to be also the path to an existing ordinary file,
 a simple work around can be changing the format string "`the-path-to-some-file`"
 to something like "`{ 'the-path-to-some-file' }`".

Below are the command options:
* `-h, --help`:
  Shows the help.
* `-s`, `--sensitive`:
  Terminates on the first unexpected error and shows the error details.
* `-w`, `--warning-sensitive`:
  Terminates on the first warning or error and shows the details.
* `-k`, `--hack-sensitive`:
  Terminates on the first hacking test case.
* `-m`, `--model-solution=<model-solution-path>`:
  Generates test outputs using the given solution.
* `-r`, `--rounds=<number-of-rounds>`:
  The number of tests to generate to stress the solution.
  If not specified, the stress process continues infinitely.
* `-i`, `--import <python-module-name>`:
  Imports the given module and makes it available
  to be used during the evaluation of test case generation format string.
  This option can be used for multiple times.
  This option has no effect if a test case generation file path
  is given instead of a test case generation format string.
* `--seed=<random-seed>`:
  The random seed given to the python module `random`
  for producing the test case generation strings.
  If the seed option is not given,
  no seed will be set and the module `random` will have its default behavior.
  The seed can be any string.
  This seed does not have any effect on the generation of the test case input files
  (when the test case generation string is fixed).
* `--no-val`:
  Skips validating test inputs.
* `--no-sol-compile`:
  Skips compiling the model and stressed solutions.
  It assumes that they are already compiled
  and still available in the sandbox.
* `--no-model`:
  Skips running the model on the test.
  The checker should be able to work without having the correct answer.
* `--no-check`:
  Skips running the checker on the outputs of the stressed solution.
  Generally used to only verify if the solution finishes successfully
  (within the time limits and with no runtime errors).
* `--no-tle`:
  Removes the default time limit on the execution of the solution.
  Actually, a limit of $24$ hours is applied.
* `--time-limit=<time-limit>`:
  Overrides the (soft) time limit on the solution execution.
  Given in seconds, e.g. `--time-limit=1.2` means $1.2$ seconds
* `--hard-time-limit=<hard-time-limit>`:
  Solution process will be killed after `<hard-time-limit>` seconds.
  Defaults to `<time-limit>` $+ 2$.
  Note: The hard time limit must be greater than the (soft) time limit.
* `--min-score=<min-score>`:
  Minimum value as a valid score.
  Given as a decimal value, typically in the range $[0, 1]$.
  This option is generally used in tasks with partial scoring.
  Default value is $1$.


## make-public

This command updates the `public` directory
 and provides the package
 that is given to the contestants.
It contains
 the public graders for each language,
 example test data,
 sample solution,
 the compile/run scripts,
 and test inputs for the output-only tasks.
The script finally generates a ZIP file
 (in the root of task directory structure)
 which can be shared with the contestants during the contest
 (directly put in CMS, etc).
The behavior of the script for each public file
 is explicitly specified in `public/files`.



## export

This command is used for exporting the task data
 into external systems,
 especially contest systems and online judges.
The general format of its usage is in this form:
```
tps export &lt;exporter-name&gt; &lt;exporter-parameters...&gt;
```
The specified exporter
 then generates an artifact (usually a zip archive)
 that can be used in the target system
 for adding the task data.

Generally, the exporters assume that
 the task structure is complete.
For example,
 they usually assume that
 test data is already generated (using `tps gen`).

Currently, these exporters are implemented and available:
* CMS
* DOMjudge

Each exporter is explained
 in the following subsections.
In order to add more exporters,
 you have to add its corresponding Bash/Python script
 in directory `scripts/exporters`.


### Exporting for CMS

In order to export for CMS,
 contest management system
 generally used for contests like IOI,
we use the following command:
```
tps export CMS [options] &lt;protocol-version&gt;
```

This command gets the protocol version of the exported package
 as a positional argument.
Currently, the available protocol versions are:
* $1$: The traditionally-used protocol (used up to $2022$).
* $2$: Supports more flexible setting of task type parameters (defined in $2022$).

You need to make sure that
 the target CMS server supports the specified protocol version.

In addition to the protocol version,
 the command can get some options:

* `-h, --help`:
  Shows the help.
* `-v, --verbose`:
  Prints verbose details during the execution.
  It prints the value of important variables,
  the decisions made based on the state,
  and commands being executed.
* `-o <export-output-name>, --output-name <export-output-name>`:
  Creates the export output with the given name.
* `-a <archive-format>`, `--archive-format <archive-format>`:
  Creates the export archive with the given format.
  Available archive formats are
  (the exact list depends on the environment
  on which the export command is run):
  * `none`: No archiving; exporting as a directory
  * `bztar`: bzip2'ed tar-file
  * `gztar`: gzip'ed tar-file
  * `tar`: uncompressed tar file
  * `xztar`: xz'ed tar-file
  * `zip`: ZIP file
  Default archive format is `zip`.

For using the exported package of a task, named "`book`" as an example,
 you should copy (`scp`) the task export archive to the CMS server.
Then, you should connect to that server (e.g. using `ssh`),
 extract the package archive (which creates a directory "`book`"),
 and run:
```
cmsImportTask -L tps_task "book"
```
You can read the help of `cmsImportTask` for more options.


### Exporting for DOMjudge

In order to export for DOMjudge,
 contest management system
 generally used for ICPC contests,
we use the following command:
```
tps export DOMjudge [options]
```

This command can get some options:
* `-h, --help`:
  Shows the help.
* `-v, --verbose`:
  Prints verbose details during the execution.
  It prints the value of important variables,
  the decisions made based on the state,
  and commands being executed.
* `--with-statement-pdf`:
  Adds the statement pdf file to the export archive.
  It does so, only if exactly one pdf file exists in the `statement` directory.
* `-o <export-output-name>, --output-name <export-output-name>`:
  Creates the export output with the given name.



## analyze

This command will open the TPS web interface on the same current commit,
 to verify the directory structure,
 to generate the test data,
 and to use the other functionalities of the web interface from the left menu (e.g. invocations).
It will not change from this commit,
 even if other people push changes.
Make sure to push your commits before executing this command.
This command is not usable
 if TPS web interface is not setup for the task.


# TPS Web interface

To use the TPS web interface,
 clone `tps-web` repository
 from [here](https://github.com/ioi-2017/tps-web).
Using the web interface,
 you can go to any task,
 and see the task statement and all of test materials.
The test cases are only available after they are generated.
For generating the test cases
 you should go to the analysis page
 and click on the generate button.
During the generation
 you can also see the generation state by reloading the page.
You may then analyze the test data
 using the test cases section.
You may also use invocations to evaluate solutions.
