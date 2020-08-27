import sys
import os
import datetime
import platform
import signal
import subprocess
from threading import Timer
from util import simple_usage_message, bool2bash


_is_windows = (platform.system() == "Windows")

if not _is_windows:
    try:
        import psutil
    except ImportError as e:
        sys.stderr.write('''\
Package \'psutil\' (required for non-windows platforms) is not installed.
You can install it using:
    pip install psutil
or
    python -m pip install psutil
''')
        sys.exit(1)


def kill_proc_tree(pid, including_parent=True):
    parent = psutil.Process(pid)
    procs = list(reversed(parent.children(recursive=True))) + ([parent] if including_parent else [])
    for proc in procs:
        proc.kill()
    psutil.wait_procs(procs, timeout=1)


class ProcessExecutionData:
    def __init__(self, process, start_time):
        self.process = process
        self.start_time = start_time
        self.end_time = None
        self.terminated = False
        self.ret = None

    @property
    def duration(self):
        return (self.end_time - self.start_time).total_seconds() if self.end_time is not None else None

    @property
    def terminated_str(self):
        return bool2bash(self.terminated)


def terminate(data):
    data.terminated = True
    if _is_windows:
        os.kill(data.process.pid, signal.CTRL_BREAK_EVENT)
    else:
        kill_proc_tree(data.process.pid)


def timer(time_limit, command):
    start_time = datetime.datetime.now()

    if _is_windows:
        p = subprocess.Popen(command, creationflags=subprocess.CREATE_NEW_PROCESS_GROUP)
    else:
        p = subprocess.Popen(command)

    data = ProcessExecutionData(p, start_time)
    t = Timer(time_limit, terminate, [data])
    t.start()

    try:
        data.ret = p.wait()
    except KeyboardInterrupt:
        t.cancel()
        sys.exit(130)
    t.cancel()

    data.end_time = datetime.datetime.now()
    return data


def _main():
    if len(sys.argv) < 5:
        simple_usage_message("<soft-time-limit> <hard-time-limit> <output-file> <command...>")

    soft_time_limit = float(sys.argv[1])
    hard_time_limit = float(sys.argv[2])
    output_file = sys.argv[3]

    command = sys.argv[4:]

    data = timer(hard_time_limit, command)

    del data.process
    with open(output_file, 'w') as f:
        f.write("duration %.3f\n" % data.duration)
        f.write("terminated %s\n" % data.terminated_str)
        f.write("ret %d\n" % data.ret)

    if data.terminated or data.duration > soft_time_limit:
        sys.exit(124)
    else:
        sys.exit(data.ret)


if __name__ == '__main__':
    _main()
