#!/bin/sh 
mutex_file="/tmp/tw_milton_repl.mutex"
dname=`dirname $0`

if test "$1" = "check_mutex"
then
    lockf -s -t 0 $mutex_file true
    if test "$?" != "0"
    then
        date > /dev/stderr
        echo "$mutex_file in lock"  > /dev/stderr
        echo " "
    fi
    exit 0
fi

if test "$tw_milton_repl__list" -a  "$tw_milton_repl__host"
then
    if test `whoami` = "yahoo"
    then
        lockf -t 0 $mutex_file $dname/get_milton.pl
    else
        echo "please use yahoo to exec $0 $@" > /dev/stderr
        exit 1
    fi
else
    yinst env tw_milton_repl $0 $@
fi
