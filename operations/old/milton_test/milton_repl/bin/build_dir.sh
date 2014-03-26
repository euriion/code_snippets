#!/bin/sh -e
dname=`dirname $0`
host_cfg=`cat "$dname/build_dir.host"`
dir=`cat "$dname/build_dir.dir"`
for h in $host_cfg
do
    echo process $h
    ssh $h "sudo mkdir -p $dir && sudo chown yahoo $dir && echo ok"
done
