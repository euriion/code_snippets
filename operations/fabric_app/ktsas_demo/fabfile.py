# -*- coding: utf-8 -*-
from __future__ import with_statement
import inspect
import subprocess

__version__ = "0.0.1.1000"
__author__ = "aiden.hong@nexr.com"
__doc__ = """A Fabric script to operate CloudLog testbed

Usages for command line:
    fab check_r_version
    fab -R all check_r_version
    fab -R namenode check_r_version
    fab -R jobnode check_r_version

Usage for crontab:
    add following lines to the crontab
    mailto=aiden.hong@nexr.com
    */10 * * * * cd /home/aiden.hong/fabric/cloudlog_rhive;/usr/local/bin/python2.7 fabfile_example.py"""

import os
from fabric.api import *
from fabric.utils import *
from fabric.context_managers import show, hide
from fabric.network import join_host_strings, normalize
from fabric.state import connections
from fabric.contrib.console import confirm
from fabric.colors import *
import re
import socket
import datetime

__all__ = [
           'check_base_path',
           'check_hadoop_path',
           'check_hive_path',
           'check_hostname',
           'check_r_version',
           'check_rhive_data_path',
           'check_rserve_daemon',
           'check_rstudio_version',
           'check_ssh_port',
           'check_writable',
           'check_disks',
           'start_rserve_daemon',
           'stop_rserve_daemon',
           'restart_rserve_daemon',
           'start_rstudio',
           'stop_rstudio',
           'restart_rstudio',
           'install_r',
           'install_rstudio',
           'add_users',
           'remount_additional_disk',
           'clear_hadoop_data_path',
           'clear_rhive_data_path',
           'ping',
           'install_korean_fonts',
           'watchdog',
           'set_r_env',
           'unset_r_env',
           'check_r_env',
           'check_namenode_ports',
           'check_jobnode_ports',
           'check_all_ports',
           'format_hadoop_namenode',
           'setup_jobnode',
           'make_rhive_rhive_data_path',
           'install_hadoop',
           'install_hive'
           ]

def write_error_report(status, host, task, description = ""):
    if os.path.exists(os.getcwd() + "/run_results"):
        print("writing error report")
        open("%s/%s" % (os.getcwd() + "/run_results", report_filename), "a+").write("\t".join((status, host, task, description)) + "\n")

def send_report():
    if os.path.exists("%s/%s" % (os.getcwd() + "/run_results", report_filename)):
        print("Sending report to administrator")
        file_content = open("%s/%s" % (report_directory, report_filename)).readlines()
        report_content = "<br />\n".join(file_content)
        subject = "[cloudLog-testbed] error report"
        message = """
<html>
<head>
<title>Error report</title>
</head>
<body>
Watchdog for [CLOUDLOG-TESTBED]<br />
This email is automatically sent to cloudlog-testbed users every hour on the hour.<br />
If you received this email, that means the cloudlog-testbed is <span style='color:red'>unstable</span> now.<br />
%s
</body></html>""" % report_content
        sendmail("datascience-system@nexr.com", "datascience@nexr.com", subject, message)

def sendmail(sender, receiver, subject, body, smtphost='localhost'):
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart

    #    fp = open(textfile, 'rb')
    #    message = MIMEText(fp.read())
    #    fp.close()

    # me == the sender's email address
    # you == the recipient's email address
    message = MIMEMultipart('alternative')
    message['Subject'] = subject
    message['From'] = sender
    message['To'] = receiver
#    message.attach(MIMEText(body, 'text'))
    message.attach(MIMEText(body, 'html'))

    # Send the message via our own SMTP server, but don't include the
    # envelope header.
    s = smtplib.SMTP(smtphost)
    s.sendmail(sender, receiver, message.as_string())
    s.quit()

def check_port(host, port, timeout=1):
    """ Checking if the assigned port of host is listening
    """
    result = False
    try:
        sock = socket.create_connection((host, port), timeout)
    except:
        pass
    
    try:
        sock.close()
        result = True
    except:
        pass
    return result

# 2012-03-05: nexr05 died
# env.hosts = ['nexr00', 'nexr01', 'nexr02', 'nexr03', 'nexr04', 'nexr05', 'nexr06']
# 2012-03-06: added nexr07
env.hosts = ['nexr00', 'nexr01', 'nexr02', 'nexr03', 'nexr04', 'nexr06', 'nexr07']

env.roledefs = {
    'all':env.hosts,
    'namenode':[env.hosts[0]],  # name node, hive server, rstudio-server, mysql-server, ...
    'jobnode':env.hosts[1:]  # all job nodes
}

env.user = "root"

R_rpm_names = [
    "R-devel-2.14.1-1.el5", 
    "R-core-2.14.1-1.el5", 
    "R-2.14.1-1.el5", 
    "R-devel-2.14.1-1.el5", 
]

RStudio_rpm_name = "rstudio-server-0.95.262-1"

hive_version = "hive-0.8.0-nr1004"
hadoop_version = "hadoop-0.20.203.0"

rhive_base_path = "/data"
rhive_hive_path = "%s/%s" % (rhive_base_path, hive_version)
rhive_hadoop_path = "%s/%s" % (rhive_base_path, hadoop_version)
rhive_hadoop_data_path = "%s/hadoopdata" % rhive_base_path
rhive_rhive_data_path = "%s/rhivedata" % rhive_base_path
additional_disk_name = "/dev/xvdb1"
report_directory = "./run_reports"
report_filename = "report.txt"

rhive_directories = [
    rhive_base_path,
    rhive_hadoop_path,
    rhive_hive_path,
    rhive_rhive_data_path
]

@roles('all')
def check_ssh_port():
    """ Checking port of SSH (22)
    """
    if not check_port(env.host, 22):
        print red("%s:%s is unreachable" % (env.host, 22))
        write_error_report("error", env.host, inspect.stack()[0][3])
    else:
        print green("%s:%s reachable" % (env.host, 22))

@roles('all')
def check_hostname():
    """ Checking Host name of all nodes
    """
    result = sudo('hostname')
    print(result)

@roles('all')
def check_r_version():
    """ Checking version of installed R
    This task checks if the installed R instances are assigned version
    """
    result = run("rpm -qa | grep '^R-'")
    if " ".join(sorted(R_rpm_names)) == " ".join(sorted(result.split("\r\n"))):
        print("R packages OK: --> %s" % ", ".join(sorted(result.split("\r\n"))))
    else:
        print("R packages is not matched: %s" % ", ".join(sorted(result.split("\r\n"))))
        write_error_report("error", env.host, inspect.stack()[0][3])

@roles('namenode')
def check_rstudio_version():
    """ Checking version of RStudio-server
    """
    with settings(warn_only=True):
        result = sudo("/bin/rpm -qa | grep '^rstudio'")
        if RStudio_rpm_name == result.strip():
            print("Rstudio version %s: --> %s" % (green("OK"), ", ".join(sorted(result.split("\r\n")))))
        else:
            print("Rstudio version is not matched: %s" % ", ".join(sorted(result.split("\r\n"))))
            write_error_report("error", env.host, inspect.stack()[0][3])

@roles('all')
def install_r():
    """ Installing latest version of GNU-R using yum
    if the installed version of R is not latest then it will be updated by yum
    """
    with cd("/tmp"):
        sudo("if [ ! -d ./r_installation ]; then mkdir ./r_installation; fi")
        with cd("./r_installation"):
#            sudo("rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-4.noarch.rpm")
            with settings(warn_only=True):
                sudo("rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm")
            sudo("yum install R")
        sudo("rm -Rf ./r_installation")

@roles('namenode')
def install_rstudio():
    """ Install Rstudio-server to the assigned host using rpm directly
    """
    with cd("/tmp"):
        sudo("mkdir ./rstudio_installation")
        with cd("./rstudio_installation"):
            sudo("wget http://download2.rstudio.org/rstudio-server-0.95.262-x86_64.rpm")
            sudo("rpm -Uvh rstudio-server-0.95.262-x86_64.rpm")

@roles('all')
def unset_r_env():
    """ Removing environment variables are related to RHive from the file '/usr/lib64/R/etc/Renviron'
    """
    #result = sudo("cat /usr/lib64/R/etc/Renviron | grep -v -E '^HADOOP_HOME=|^HIVE_HOME=|^RHIVE_DATA='")
    #new_content = result
    time_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    sudo("mv /usr/lib64/R/etc/Renviron /usr/lib64/R/etc/Renviron.%s" % time_str)
    sudo("cat /usr/lib64/R/etc/Renviron.%s | grep -v -E '^HADOOP_HOME=|^HIVE_HOME=|^RHIVE_DATA=' > /usr/lib64/R/etc/Renviron" % time_str)

@roles('all')
def set_r_env():
    """ Setting environment variables are related to RHive into the file '/usr/lib64/R/etc/Renviron'
    """
    unset_r_env()
    sudo("echo '##### RHive #####' >> /usr/lib64/R/etc/Renviron")
    sudo("echo 'HADOOP_HOME=%s' >> /usr/lib64/R/etc/Renviron" % rhive_hadoop_path)
    sudo("echo 'HIVE_HOME=%s' >> /usr/lib64/R/etc/Renviron" % rhive_hive_path)
    sudo("echo 'RHIVE_DATA=%s' >> /usr/lib64/R/etc/Renviron" % rhive_rhive_data_path)

@roles('all')
def check_r_env():
    """ Checking environment variables for RHive
    This task only checks the '/usr/lib64/R/etc/Renviron' file
    """
    with settings(warn_only=True):
        result = sudo("cat /usr/lib64/R/etc/Renviron | grep -E '^HADOOP_HOME=|^HIVE_HOME=|^RHIVE_DATA='")
        if len(result.split("\n")) == 3:
            print(blue(result))

@roles('all')
def check_base_path():
    """ Checking if 'base path' exists
    """
    with settings(warn_only=True):
        output = run("ls -ald %s" % rhive_base_path)
        if output.find("No such file or directory") != -1:
            print("(%s) base path '%s' %s" % (env.host, rhive_base_path, red("fail")))
            write_error_report("error", env.host, inspect.stack()[0][3])
        else:
            print("(%s) base path '%s' %s" % (env.host, rhive_base_path, green("OK")))

@roles("all")
def check_hadoop_path():
    """ Checking if Hadoop is installed or not
    """
    with settings(warn_only=True):
        path_exists(rhive_hadoop_path)

@roles("namenode")
def check_hive_path():
    """ Checking if Hive is installed
    """
    with settings(warn_only=True):
        path_exists(rhive_hive_path)

@roles("jobnode")
def check_rhive_data_path():
    """ Checking if data path for RHive exists or not
    """
    with settings(warn_only=True):
        if not path_exists(rhive_rhive_data_path):
            write_error_report("error", env.host, inspect.stack()[0][3])

@roles("jobnode")
def clear_rhive_data_path():
    """ Clearing data path for RHive
    """
    with settings(warn_only=True):
        clear_path(rhive_rhive_data_path)

def path_exists(path):
    """ Basic function for checking existence of path
    """
    with settings(warn_only=True), hide("status", "stderr", "stdout"):
        output = sudo("ls -ald %s" % path)
        if output.failed:
            return False
        else:
            return True

def clear_path(path):
    """ Basic function to clear out assigned path
    """
    result = run("rm -Rf %s/*" % path)
    if result.failed:
        print(red("failed to clean the directory"))

def make_path(path):
    """ Making a directory
    """
    result = run("mkdir -p %s" % path)
    if result.failed:
        print(red("failed to make the directory"))

@roles("jobnode")
def check_rserve_daemon():
    """ Checking port of Rserve daemon is listening
    """
    rserve_port = "6311"
    result = run("netstat -nltp | grep '/Rserve' | awk '{print $4}' | awk -F \":\" '{print $2}'")
    if result.failed or result == "" or result != rserve_port:
        print("%s\tRserve doesn't listen on the port %s" % (red("error!"), rserve_port))
        write_error_report("error", env.host, inspect.stack()[0][3])
    else:
        print("%s\tRserve is listening on port %s" % (green("OK!"), rserve_port))

def get_port_list():
    return sudo("netstat -nltp | awk '{print $4}' | awk -F\":\" '{print $NF}' | tail -n +3")

port_map_table = {
    "50070":"webui-HDFS	Namenode",
    "50075":"webui-Datanodes",
    "50090":"webui-Secondarynamenode",
    "50105":"webui-Backup/Checkpoint node",
    "50030":"webui-MR Jobracker",
    "50060":"webui-Tasktrackers",
    "8020":"Namenode-Filesystem metadata operations.",
    "50010":"Datanode-DFS data transfer",
    "50020":"Datanode-Block metadata operations and recovery",
    "50100":"Backupnode-Same as namenode, HDFS Metadata Operations",
    "3306":"MySQL server",
    "10000":"Hive server",
    "6311":"Rserve",
    "80":"Web server(RStudio)",
    "22":"sshd",
    "9001":"JobTracker"
}

def get_missed_ports(mandatory_port_list):
    found_port_list = []
    notfound_port_namelist = []
    missed_port_list = []
    with hide("stdout", "stderr", "status", "running", "warnings"):
        port_list = get_port_list()

        for port in sorted(port_list.split("\n")):
            if port_map_table.has_key(port.strip()):
                # print "%s (%s) is listening" % (port_map_table[port.strip()], port.strip())
                found_port_list.append(port.strip())

        if set(mandatory_port_list).issubset(set(found_port_list)):
            print "%s all mandatory ports are ready" % green("OK!")
        else:
            missed_port_list = list(set(mandatory_port_list) - set(found_port_list))
            print "%s some ports are not ready. %s" % (red("error!"), yellow(", ".join(missed_port_list)))
            for port in missed_port_list:
                print "missed: %s (%s)" % (yellow(port_map_table[port]), red(port))
    return missed_port_list

@roles("all")
def check_all_ports():
    """ Checking all important ports on all nodes
    """
    if env.host == env.hosts[0]:
        missed_port_list = check_namenode_ports()
    else:
        missed_port_list = check_jobnode_ports()

    if missed_port_list:
        write_error_report("error", env.host, inspect.stack()[0][3])

@roles("namenode")
def check_namenode_ports():
    """ Checking all ports are related to run name node for RHive environment
    """
    mandatory_port_list = ["3306", "80", "9001", "50090", "50030", "8020", "50070", "22"]
    get_missed_ports(mandatory_port_list)

@roles("jobnode")
def check_jobnode_ports():
    """ Checking all ports are related to run job node for RHive environment
    """
    mandatory_port_list = ["6311", "50020", "22", "50010", "50075"]
    get_missed_ports(mandatory_port_list)


@roles("jobnode")
def stop_rserve_daemon():
    """ Checking port of Rserve daemon is listening
    """
    with settings(warn_only=True):
        result = sudo("netstat -nltp | grep '/Rserve' | awk '{print $7}' | awk -F \"/\" '{print $1}'")
        if result != "":
            sudo("/bin/kill %s" % result)

@roles("jobnode")
def start_rserve_daemon():
    """ Starting Rserve as as daemon
    """
    with settings(warn_only=True):
        result = sudo("/usr/bin/R CMD Rserve")
        if result.failed:
            write_error_report("error", env.host, inspect.stack()[0][3])

@roles("jobnode")
def restart_rserve_daemon():
    """ Restaring Rserve daemon
    """
    with settings(warn_only=True):
        result = sudo("/usr/bin/R CMD Rserve")
        if result.failed:
            write_error_report("error", env.host, inspect.stack()[0][3])

@roles("namenode")
def stop_hadoop():
    with cd(rhive_hadoop_path + "/bin"):
        run("./stop-all.sh")

@roles("namenode")
def start_hadoop():
    with cd(rhive_hadoop_path + "/bin"):
        run("./start-all.sh")

@roles("namenode")
def restart_hadoop():
    stop_hadoop()
    start_hadoop()

def list_hadoop_data_path():
    """ Listing files in Hadoop data path
    """
    run("ls -al %s" % rhive_hadoop_data_path)

def clear_hadoop_data_path():
    """ Clearing data path of Hadoop (Dangerous!)
    """
    run("rm -Rf %s/*" % rhive_hadoop_data_path)

@roles("namenode")
def format_hadoop_namenode():
    """ Formatting Hadoop namenode (Dangerous!)
    """
    run("hadoop namenode -format")

@roles("namenode")
def restart_hadoop_all():
    """ Restarting hadoop all services on all nodes
    """
    with cd("%s/bin" % rhive_hadoop_path):
        run("bash ./stop-all.sh")
        run("bash ./start-all.sh")

@roles("namenode")
def restart_rstudio():
    """ Restarting RStudio-server
    """
    run("/etc/init.d/rstudio-server restart")

@roles("namenode")
def stop_rstudio():
    """ Stopping RStudio-server
    """
    run("/etc/init.d/rstudio-server stop")

@roles("namenode")
def start_rstudio():
    """ Starting RStudio-server
    """
    run("/etc/init.d/rstudio-server start")

@roles("namenode")
def add_users():
    """ Adding reserved users to hosts
    """
    userlist = ["aiden.hong", "irene.kwon", "eugene.hwang", "haven.jeon", "antony.ryu", "jun.cho", "eric.kim"]
    default_password = "nexr4101"
    with settings(warn_only=True):
        for userid in userlist:
            result = sudo("cat /etc/passwd | grep \"^%s:\"" % userid)
            if result.strip() == "":
                sudo("adduser %s" % userid)
                sudo("chpasswd <<< '%s:%s'" % (userid, default_password))

@roles("all")
def check_writable():
    """Checking writing permission on several directorie
    """
    filename_for_test = "file_for_writting_test"
    with settings(warn_only=True), hide("running", "status", "stdout", "stderr", "warnings"):
        with cd("/root"):
            result = sudo("touch %s" % filename_for_test)
            if result.failed:
                print(red(env.host + " failed to write on path of root"))
            result = sudo("rm %s" % filename_for_test)
            if result.failed:
                print(red(env.host + " failed to remove on path of root"))
        with cd("/tmp"):
            result = sudo("touch %s" % filename_for_test)
            if result.failed:
                print(red(env.host + " failed to write on '/tmp'"))
            result = sudo("rm %s" % filename_for_test)
            if result.failed:
                print(red(env.host + " failed to remove on '/tmp'"))
        with cd(rhive_base_path):
            result = sudo("touch %s" % filename_for_test)
            if result.failed:
                print(red(env.host + " failed to write on base path of RHive '%s'" % rhive_base_path))
            result = sudo("rm %s" % filename_for_test)
            if result.failed:
                print(red(env.host + " failed to remove on base path of RHive '%s'" % rhive_base_path))
        if result.failed:
            open("./log.result.writable", "a+").write(env.host + "\t" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S") + "\t" + "file system Failed\n")
            write_error_report("error", env.host, inspect.stack()[0][3])
        else:
            open("./log.result.writable", "a+").write(env.host + "\t" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S") + "\t" + "file system OK\n")

@roles("all")
def check_disks():
    """ Checking if additional network disks are available
    sometimes, the additional disks are not shown on hosts
    so, need to check if the disks are ready or not
    """
    result = sudo("fdisk -l | grep '^/'")
    if re.search(r"%s" % additional_disk_name, result) is None:
        print("%s: failed to find disk %s" % (red("error!"), green(additional_disk_name)))
        write_error_report("error", env.host, inspect.stack()[0][3])
    result = sudo("df -ah")
    if result.failed:
        write_error_report("error", env.host, inspect.stack()[0][3])

@roles("all")
def remount_additional_disk():
    """ Mounting the additional disk again
    if the base mounted path is already mounted then it will be unmounted first
    """
    with settings(warn_only=True):
        result = sudo("umount %s" % rhive_base_path)
        if result.failed:
            write_error_report("error", env.host, inspect.stack()[0][3])
        result = sudo("mount %s %s" % (additional_disk_name, rhive_base_path))
        if result.failed:
            write_error_report("error", env.host, inspect.stack()[0][3])

@roles("all")
def make_rhive_rhive_data_path():
    sudo("if [ ! -d %s ]; then mkdir %s ; fi" % (rhive_rhive_data_path, rhive_rhive_data_path))

@roles("all")
def install_hadoop():
    with cd(rhive_base_path):
        sudo("wget http://mirror.apache-kr.org//hadoop/common/hadoop-0.20.203.0/hadoop-0.20.203.0rc1.tar.gz")
        sudo("tar xvfz ./hadoop-0.20.203.0rc1.tar.gz")
        sudo("rm ./hadoop-0.20.203.0rc1.tar.gz*")

@roles("jobnode")
def setup_jobnode():
    remount_additional_disk()
    make_rhive_data_path()
    install_r()
    set_r_env()
    start_rserve_daemon()
    install_hadoop()

@roles("all")
def ping():
    """ pinging(ICMP) to hosts
    """
    with settings(warn_only=True), hide("running", "status", "stdout", "stderr", "warnings"):
        result = local("ping -c 1 %s" % env.host)
        if result.failed:
            print("%s\t%s is not reachable by ICMP" % (red("error!"), env.host))
            write_error_report("error", env.host, inspect.stack()[0][3])
        else:
            print("%s\t%s is reachable by ICMP" % (green("OK!"), env.host))

@roles('namenode')
def install_korean_fonts():
    """ Installing Korean fonts (Nanum)
    Korean fonts are necessary to plot out graphic using R
    """
    font_dic = {
        "나눔고딕에코TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_TTF_GOTHICECO.zip",
        "나눔명조에코TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_TTF_MYUNGJOECO.zip",
        "나눔고딕TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip",
        "나눔명조TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip",
        "나눔고딕라이트TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_TTF_GOTHICLIGHT.zip",
        "나눔손글씨TTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip",
        "나눔고딕에코OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_OTF_GOTHICECO.zip",
        "나눔명조에코OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_OTF_MYUNGJOECO.zip",
        "나눔고딕OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_OTF_ALL.zip",
        "나눔명조OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_OTF_ALL.zip",
        "나눔고딕라이트OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_OTF_GOTHICLIGHT.zip",
        "나눔손글씨OTF":"http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_OTF_ALL.zip",
        "나눔고딕코딩TTF":"http://dev.naver.com/projects/nanumfont/download/441?filename=NanumGothicCoding-2.0.zip"
    }
    with settings(warn_only=True), hide("status"):
        with cd("/usr/share/fonts"):
            sudo("mkdir -p ./additional")
            with cd("/usr/share/fonts/additional"):
                for fontpack, url in font_dic.items():
                    sudo("if [ -z ./%s ]; then mkdir -p ./%s" % (fontpack, fontpack))
                    sudo("/usr/bin/wget %s -O ./%s.zip" % (url, fontpack))
                    sudo("rm -f ./%s/*" % fontpack)
                    sudo("/usr/bin/unzip ./%s.zip -d %s" % (fontpack, fontpack))
                    sudo("rm -Rf *.zip")
                put("./shipments/fonts/KTnG_SangSang_Fonts.tar.bz2", "/usr/share/fonts/additional/")
                sudo("tar xvfz ./KTnG_SangSang_Fonts.tar.bz2")
                sudo("rm -f ./KTnG_SangSang_Fonts.tar.bz2")
        sudo("fc-cache -fv")

def watchdog():
    """ Task collection to monitor all check points on all nodes
    """
    # check_ssh_port()
    check_base_path()
    check_hadoop_path()
    check_hive_path()
    check_r_version()
    check_rhive_data_path()

    if env.host in env.roledefs["namenode"]:
        check_rstudio_version()
        check_namenode_ports()
    else:
        check_rserve_daemon()
        check_jobnode_ports()

    check_writable()
    check_disks()
    check_r_env()

def initialize():
    if not os.path.exists(report_directory):
        os.mkdir(report_directory)

def release():
    os.system("rm -Rf %s" % report_directory)

if __name__ == "__main__":
    report_directory = os.getcwd() + "/run_results"
    print("report directiory: %s" % report_directory)
    initialize()
    default_commands = ['watchdog']
    subprocess.call(['/usr/local/bin/fab', '-f', __file__] + default_commands)
    send_report()
    release()