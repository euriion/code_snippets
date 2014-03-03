import sys
import syslog

message = sys.argv[1]
syslog.syslog(syslog.LOG_LOCAL4, message)
