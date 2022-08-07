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

Python (2 or 3) is an essential dependency for executing the TPS scripts.
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

`tps_web_url`: Optional URL as a base for TPS web URL of the same task.

Below is a sample `problem.json`:

```
{
    "name": "mountains",
    "code": "mountains",
    "title": "Mountains",
    "memory_limit": 256,
    "time_limit": 1.0,
    "type": "Batch",
    "description": "Find maximum number of Deevs",
    "tps_web_url": "https://tps.ioi2017.org/tps"
}
```

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
Below is an example:

```
@subtask samples
manual sample-01.in
manual sample-02.in
#uses a manually generated test from manual directory

# a comment is here
@testset ABC
gencode random 2
#another comment
gencode slow_up 19 asdgs

@subtask 2^n
gencode slow_up 19 sfgrev
@include ABC
gencode wall-envlope 19
gencode semi-manual 19
gencode magic 19
manual man-01.in

@testset apple
gencode random 40 qwetf
gencode sqr 40 cefut
gencode random 40 sadfa

@subtask bt
@include 2^n apple
#inclusion is transitive, so it also includes ABC
gencode magic 40

@subtask full
@include bt
gencode random 1000 ovuef
gencode random 2000 ocewu
gencode magic 2000
```

## grader/

This directory contains the program that have the main routine,
 which will be compiled with a solution or contestant's source code
 and call its functions.
It contains one directory for each programming language (cpp/pas/java),
 which contains a specific grader for that language.
The `cpp` directory usually contains a `.h` interface file
 that is included in grader
 (and possibly in contestant's program).
It contains the graders that are used by the judging system.
The public grader,
 which is given to the contestants during the contest,
 can be the same as this graders,
 or can be automatically created from the grader by removing the secret parts,
 which are bounded between `// BEGIN SECRET` and `// END SECRET` lines,
 or can be prepared separately.

## checker/

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

Note that the keyword `PROBLEM_NAME_PLACE_HOLDER` in file names
 is representing the task name (specified in `problem.json`)
 and is automatically replaced during the execution.
So, it is not needed
 to replace it with the task name in the file.



Example:

```
public cpp/compile_cpp.sh
public cpp/PROBLEM_NAME_PLACE_HOLDER.cpp
grader cpp/PROBLEM_NAME_PLACE_HOLDER.h
grader cpp/grader.cpp

public pas/compile_pas.sh
public pas/PROBLEM_NAME_PLACE_HOLDER.pas
grader pas/grader.pas

public java/compile_java.sh
public java/run_java.sh
public java/PROBLEM_NAME_PLACE_HOLDER.java
grader java/grader.java

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
  in `Communication` tasks,
  a manager file should also be compiled
  and put beside the grader.
  This is achieved using `post_compile.sh` in the current implementation,
  without the need for modifying the compile script itself.

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
* The `logs` directory is completely cleared
  in the beginning of this script.
  All the steps are logged in separate files in this directory.
* In addition to the verdict,
  the running time and the score of the solution is printed for each test case.
  The score is usually zero or one,
  unless the verdict is `Partially Correct`.


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
Currently, exporting packages for CMS are also available
 only in the web interface.
