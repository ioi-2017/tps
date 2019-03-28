Task Preparation System (TPS)
================

The Task Preparation System (TPS) is used to prepare tasks (problems) in programming contests.
It has been developed and first used in the [IOI 2017](http://ioi2017.org/)
in Tehran, Iran.

TPS consists of a command-line interface and a web interface.
The command-line interface provides a set of scripts for preparing the tasks, while
the web interface provides an interface to visualize the tasks,
and prepare them for final release.

The TPS command-line interface is provided in this repository.
You may find the web interface at https://github.com/ioi-2017/tps-web.


Installation
------------
After cloning the project, just run `install-tps.sh` (or `install-tps.bat` in Windows with MSYS/Cygwin).
This will add `tps` command to PATH and also add bash completion for it.


Behavior
--------
The `tps` command is a light weight script that locates `BASE_DIR`, the directory containing `problem.json`, and then, runs the corresponding script in the `scripts` directory.
For example, `tps compile a.cpp` runs `${BASE_DIR}/scritps/compile.sh` with argument `a.cpp`.

The contents of `scripts` directory in `${BASE_DIR}` of a problem are originated from `scripts` directory in TPS repository, but they can be modified/customized for a specific problem.
Anyway, they can be updated using command `upgrade-scripts.sh`.
It helps a lot in detecting changes and conflicts.


Documentation
-------------
A detailed documentation is provided in the [`docs`](docs) directory.


License
-------
This software is distributed under the MIT license (see LICENSE.txt),
and uses some third party codes that are distributed under their own terms
(see LICENSE-3RD-PARTY.txt).


Copyright
---------
Copyright (c) 2017, IOI 2017 Host Technical Committee
