import datetime
import subprocess
import sys
from threading import Timer
import os

try:
    import psutil
except ImportError as e:
    sys.stderr.write('Package \'psutil\' is not installed. You can install it using:\npip install psutil\n')
    exit(1)


def kill_proc_tree(pid, including_parent=True):
    parent = psutil.Process(pid)
    procs = list(reversed(parent.children(recursive=True))) + ([parent] if including_parent else [])
    for proc in procs:
        proc.kill()
    psutil.wait_procs(procs, timeout=1)


def usage():
    sys.stderr.write('Usage: python timer.py <soft-time-limit> <hard-time-limit> <output-file> <command...>\n')
    exit(2)


def terminate(data):
    data["terminated"] = True
    kill_proc_tree(data["process"].pid)


def timer(time_limit, command):
    start_time = datetime.datetime.now()

    p = subprocess.Popen(command)

    data = {"process": p, "terminated": False}
    t = Timer(time_limit, terminate, [data])
    t.start()

    try:
        data["ret"] = p.wait()
    except KeyboardInterrupt as e:
        t.cancel()
        exit(130)
    t.cancel()

    end_time = datetime.datetime.now()
    data["duration"] = (end_time - start_time).total_seconds()

    return data

if __name__ == '__main__':
    if len(sys.argv) < 5:
        usage()

    soft_time_limit = float(sys.argv[1])
    hard_time_limit = float(sys.argv[2])
    output_file = sys.argv[3]

    command = sys.argv[4:]

    data = timer(hard_time_limit, command)

    del data["process"]
    with open(output_file, 'w') as f:
        f.write("duration %.3f\n" % data["duration"])
        f.write("terminated %s\n" % ("true" if data["terminated"] else "false"))
        f.write("ret %d\n" % data["ret"])

    if data["terminated"] or data["duration"] > soft_time_limit:
        exit(124)
    else:
        exit(data["ret"])
