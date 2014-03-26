import sys

from datetime import datetime
import signal
import daemon
import lockfile

from apscheduler.scheduler import Scheduler

def job_function():
  print "Hello World"


def main():
  signal.pause()

if __name__ == '__main__':
  sched = Scheduler()
  sched.daemonic = True
  sched.start()
  sched.add_interval_job(job_function, minutes=1)

  context = daemon.DaemonContext(
    working_directory='/data',
    umask=0o002,
    pidfile=lockfile.FileLock('/tmp/wikipedia_pagecount.pid'),
    )

  context.signal_map = {
    signal.SIGTERM: 'terminate',
    signal.SIGHUP: 'terminate',
    signal.SIGUSR1: 'terminate'
  }

  with daemon.DaemonContext():
    main()