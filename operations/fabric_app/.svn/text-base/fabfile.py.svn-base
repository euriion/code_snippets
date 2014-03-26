from __future__ import with_statement
from fabric.api import *
from fabric.contrib.console import confirm
from fabric.colors import *

env.hosts = ['node0', 'node1', 'node2', 'node3']
env.key_filename = "/Users/aidenhong/_ssh/aidenhong.pem"
env.user = "root"

def count_java_ps():
    print(yellow("checking java processes"))
    run("ps aux | grep java | grep -v 'grep' | wc -l")

def host_type():
    run('uname -a')

def clean_dir():
    print(red("Will delete all files in the target path"))
    run("rm -Rf /mnt/srv/hadoopdata/*")

