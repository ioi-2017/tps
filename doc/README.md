# Task Preparation System (TPS)

Version 1.0

Host Technical Committee, Host Scientific Committee

IOI 2017, Tehran, Iran

# Prerequisites

It is recommended to install bash completion if it is not already installed (on OS/X for example). There is a manual here:

[http://davidalger.com/development/bash-completion-on-os-x-with-brew/](http://davidalger.com/development/bash-completion-on-os-x-with-brew/)

TPS currently supports c++, pas and java. The `gcc` compiler is mandatory, and `fpc` (free pascal) and java compilers are required if there are solutions of those languages.

Python (2 or 3) is required.

The system should support make command (for Makefiles).

# Task Preparation System (TPS)

The TPS has two interfaces: a git interface that is ideal for those who love terminal, and a web interface with a GUI. Currently the web interface is read-only, hence any changes to the task statement or test material should be done through the git interface. The main functionality of the web interface is to invoke solutions over the whole set of tests to see how they perform on the real contest machines, in parallel.

The following sections describe these interfaces.

# git and terminal interface

You can login to [http://tps.ioi2017.org/git](http://tps.ioi2017.org/git) and goto any task, and see the git (SSH) address to clone the task. It is very helpful to go to Settings (from the top-right corner) and add public ssh keys in `SSH Keys` tab to bypass all password prompts in the future. SSH keys can be generated using `ssh-keygen` command.

To install the TPS terminal interface, first clone the common/scripts repository using the following commands:

```
git clone ssh://git@tps.ioi2017.org:10022/common/scripts.git
cd scripts
./install-tps.sh
```

Windows users can download the zip file directly, extract it and run `install-tps.bat`.

To clone the task *mountains* for instance, open terminal and run:

```
git clone ssh://git@tps.ioi2017.org:10022/practice/mountains.git
```

A new folder `mountains` will be created that contains the statement and all test material of the task. Here is a brief description of files and subfolders in each task folder:


## problem.json

Description of the task. It has several attributes:
name: The short-name of the task. The source code submitted by the contestant should use this name.
code: A unique code assigned to each task in the TPS web-interface. Usually it is the same as the `name`, but is reserved for the cases that the name is changed and we don’t want to change the TPS web-interface.
title: Task title, as appears in the task statement.
type: Task type, that can be `batch`, `interactive`, `communication`, `output-only`, `two-phase`.
time_limit: A real number, the maximum CPU time (in seconds) of the main process (does not include CPU time of the manager process).
memory_limit: the maximum memory that can be used by the main process, in MB.
description: An optional description of the task.
Below is a sample `problem.json`:

```
{
 "name": "mountains",
 "code": "mountains",
 "title": "Mountains",
 "memory_limit": 256,
 "time_limit": 1.0,
 "type": "batch",
 "description": "Find maximum number of Deevs"
}
```

## gen

The code for generating test data. Usually it includes `testlib.h` which simplifies file IO, random number generation, etc. It can contain a folder `manual` that contains manually created test data (all other test data will be automatically generated).

## gen/data

This file contains the information of how to create the test data, and their mapping to the subtasks. The file is separated into several test-sets (a line starting with `@subtask`). Each test-set can include other test-sets by a line starting with `@include`. Hence a test-set might be an actual subtask, or a temporary one that is included in the other subtasks. Below is an example:

```
@subtask samples
manual sample-1.in
manual sample-2.in

@subtask 2^n
gencode random 1
gencode random 2
gencode random 3
gencode slow_up 19 asdgs
gencode slow_up 19 sfgrev
gencode magic 19

@subtask bt
@include 2^n
gencode random 40
gencode random 40 sadfa
gencode sqr 40 nymup
gencode sqr 40 waneegbt
gencode bpc 40 waneegbt
```

## grader

The program that contains the main routine, which will be compiled with the contestant source code and call its functions. It contains one folder for each programming language, which contains a specific grader for that language. The `cpp` folder usually contains a `.h` interface file that is included in the contestant program. Each grader can have secret and public parts. The public grader (which is given to the contestants during the contest) can be automatically created from the grader by removing the secret parts, which are bounded between `// BEGIN SECRET` and `// END SECRET` lines.

## checker

It contains the program that verifies the input, output and answer of a test and checks if the output is correct or wrong. It usually uses `testlib.h`.

## solution

It contains different solutions developed by the scientific committee, for different programming languages (all in the same folder). Each solution has a verdict that are listed in `solutions.json` file.

## solutions.json

The verdict of each solution. It is used by the web interface to check if the behavior of each solution is expected on the test data. The verdicts can be `correct`, `time_limit`, `memory_limit`, `incorrect`, `runtime_error`, `failed`, `time_limit_and_runtime_error`, `partially_correct`.
Below is an example:

```
{
	"mountains-haghani-solution.cpp": {
		"verdict": "model_solution"
	},
	"mountain.cpp": {
		"verdict": "correct"
	},
	"greedy.cpp": {
		"verdict": "incorrect"
	},
}
```

## validator

This folder contains validators for the whole set of test data (global validators), or for each/multiple sub-task(s), plus a Makefile. They usually include `testlib.h`.

## subtasks.json

It contains the list of all subtasks, the score of each subtask, and a mapping between validators and subtasks. The total scores should be 100. Below is an example:

```
{
       "global_validators": ["validator.cpp"],
       "subtasks": {
               "samples": {
                       "index": 0,
                       "score": 0,
                       "validators": []
               },
               "2^n": {
                       "index": 1,
                       "score": 20,
                       "validators": ["sub1_validator.cpp"]
               },
               "bt": {
                       "index": 2,
                       "score": 20,
                       "validators": ["sub2_validator.cpp"]
               },
               "n3": {
                       "index": 3,
                       "score": 30,
                       "validators": ["sub3_validator.cpp"]
               },
               "full": {
                       "index": 4,
                       "score": 30,
                       "validators": []
               }
       }
}
```

## statement

This folder contains the task statement, in markdown format. The main file is `index.md`, from which html file and other formats will be created. The pictures can be placed right in the same folder.

## tests

Initially it is empty, but after running generator it will contain all the test data (both input and output files). It also will contain a file `mapping` that contains, for each test, a line consisting names of a subtask and a test. The same test can be mapped to multiple subtasks. This mapping is used during the validation of test cases, and also for the CMS.

## sanbox

A folder that is used to compile solutions, and run them over the test data. It is not synched with git.

## logs

Contains all compile and run logs.

## scripts

All the scripts used by the TPS.

## public

All the public graders, example test data, sample source codes and compile scripts to be given to the contestant are stored here.

# TPS commands

In addition to the normal git commands (e.g. clone, pull, commit, push, merge), the TPS provides a `tps` command with bash auto-completion functionality.

Here is the usage:
```
tps <command> <arguments>...
```

Below are the list of commands that can be use with `tps`:

## analyze

This will open the TPS web interface on the same commit, to verify the directory structure, to generate the test data, and to use the other functionalities of the web interface from the left menu (e.g. invocations). It will not change from this commit, even if the other people push changes.

## compile

Given a single solution code, TPS will understand its programming language, put it in the `sandbox` folder with a new name that matches the short name of the task, puts necessary grader files in sandbox (use `-p, --public` argument to copy the public grader), compiles it, and creates run.sh (that runs the program based on the programming language) and exec.sh (which handles the required pipe-lining for interactive tasks). It also looks for `scripts/post_compile.sh` and runs if it the compile process is done successfully.

## gen

Compiles generator, model-solution , and validator, and then generates and validates the test data and check model solution on them. The other arguments are:

* `-m, --model-solution=<model-solution-path>`: change the model solution.
* `-s, --sensitive`: Terminate on the first error.
* `-t, --test=<test-name>`: run the whole process for only a single test.
* `-d, --gen-data=<gen-data-file>`: use another file rather than `gen/data`.
* `--no-gen`: do not generate the tests again.
* `--no-sol`: do not run the model-solution.
* `--no-val`: do not run the validator.
* `--no-sol-comp[ile]`: do not compile model solution.
* `-h, --help`: this help info.

## invoke

This command is used to compile one solution and checker, run the solution over the test data and check its output. Here is the usage:

```
tps invoke [options] <solution-path>
```

Below are the arguments:
* `-h, --help`: this help info.
* `-s, --sensitive`: terminate on the first error.
* `-r, --show-reason`: display the reason for not being accepted, e.g. checker output
* `-t, --test=<test-name>`: invoke a single test case.
* `-d, --gen-data=<gen-data-file>`: use alternative `gen/data` file.
* `--no-check[er]`: do not run checker.
* `--no-sol-comp[ile]`: do not compile solution.
* `--no-tle`: no time limit exceeded report.
* `--time-limit=<time-limit>`: use alternative time limit in seconds.
* `--hard-time-limit=<hard-time-limit>`: solution process will be killed after the given time in seconds. Default: `<time-limit>` + 2.

## make-public

Generate the public folder that is given to the contestant. It contains the public graders for each language, example test data, sample solution, the compile scripts, and input tests for the output-only tasks.

## verify

Verifies the directory structure, and reports error or warning messages accordingly.

## run

Runs the compiled solution in the sandbox for a given set of arguments.

# Web Interface

You can login to [https://tps.ioi2017.org](https://tps.ioi2017.org) and go to any task. There you can see the task statement and all of test materials. The test cases are only available after they are generated. For generating the test cases you should go to the analysis page and click on the generate button. During the generation you can also see the generation state by reloading the page. You may then analyze the test data using the test cases section. You may also use invocations to evaluate solutions.
