# -*- coding: utf-8 -*-
__author__ = 'aiden.hong'
import sys
#from __future__ import with_statement
import inspect
import subprocess

__version__ = "0.0.1.1000"
__author__ = "aiden.hong@nexr.com"
__doc__ = """Provisioning for Rstudio and RHive
Usages for command line:
    fab check_r_version
"""

import os
from fabric.api import *
from fabric.utils import *
from fabric.context_managers import *
from fabric.network import *
from fabric.state import *
from fabric.contrib.console import *
from fabric.colors import *
import re
import socket
import datetime

env.hosts = []

# host informations for NDAP demo system
# 172.27.240.171 dst1 (not included)
# 172.27.57.240  dst2 (not included)
# 172.27.218.55 dst3 (not included)
# 172.27.203.78 dst4 (not included)

# 172.27.60.224 dst5
# 172.27.246.239 dst6
# 172.27.65.200  dst7
# 172.27.126.254 dst8
# 172.27.161.71 dst9
# 172.27.22.154 dst10 (not included)

env.roledefs = {
  'rstudio': ['172.27.60.224'],
  'rserve': ['172.27.60.224', '172.27.246.239', '172.27.65.200', '172.27.126.254', '172.27.161.71'],
  'rhive_node': ['172.27.246.239', '172.27.65.200', '172.27.126.254', '172.27.161.71'],
  'R': ['172.27.60.224', '172.27.246.239', '172.27.65.200', '172.27.126.254', '172.27.161.71']
}

env.user = "root"
env.password = "cloudware0~!"

R_rpm_names = [
  "R-2.14.1-1.el5",
  "R-core-2.15.1-1.el5",
  "R-devel-2.15.1-1.el5"]

@task
@roles('rstudio')
def check_rstudio_version():
  """ Checking the version of the RStudio-server
  """
  with settings(warn_only=True):
    result = sudo("/bin/rpm -qa | grep '^rstudio'")
    if result.strip().startswith("rstudio-server-"):
      print("Rstudio version %s: --> %s" % (green("OK"), ", ".join(sorted(result.split("\r\n")))))
    else:
      print(red("Rstudio doesn't exist: %s" % ", ".join(sorted(result.split("\r\n")))))


@task
@roles('R')
def check_r_version():
  """ Checking version of installed R
  This task checks if the installed R instances are assigned version
  """

  result = run("rpm -qa | grep '^R-'")
  if " ".join(sorted(R_rpm_names)) == " ".join(sorted(result.split("\r\n"))):
    print("R packages OK: --> %s" % ", ".join(sorted(result.split("\r\n"))))
  else:
    print("R packages is not matched: %s" % ", ".join(sorted(result.split("\r\n"))))


@task
@roles('R')
@parallel
def install_R_source():
  """ Installing latest version of GNU-R using yum
  if the installed version of R is not latest then it will be updated by yum
  """
  epel_package_url = 'http://dl.fedoraproject.org/pub/epel/6/x86_64/R-devel-2.15.2-1.el6.x86_64.rpm'
  with settings(warn_only=True):
    run("rpm -Uvh %s" % epel_package_url)

  

  run("yum install gcc-* cairo-devel libtiff-devel libjpeg-devel texinfo-tex avahi-compat-libdns_sd bzip2-devel cups dialog ghostscript ghostscript-fonts libRmath libRmath-devel libXmu libXt netpbm netpbm-progs paps pcre-devel poppler poppler-utils psutils tcl-devel tk tk-devel urw-fonts xdg-utils readline-devel libXt-devel")

  R_source_url = 'http://cran.nexr.com/src/base/R-2/R-2.15.2.tar.gz'

  with cd("/tmp"):
    run("if [ ! -d ./r_installation_source ]; then mkdir ./r_installation_source; fi")
    with cd("r_installation_source"):
      run("yum install readline-devel -y")
      run("wget %s" % R_source_url)
      run("tar xvfz ./R-2.15.2.tar.gz")
      with cd("R-2.15.2"):
        run("./configure --enable-R-shlib --with-libpng=yes --with-x=no --with-cairo=yes --enable-memory-profiling=yes")
        rum("make install")

      # installing texlive
      # http://www.tug.org/texlive/acquire-netinstall.html
      # how to install : http://www.tug.org/texlive/quickinstall.html
      run("wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz")
      run("tar xvzf install-tl-unx.tar.gz")
      with cd("install-tl-unx"):
        run("./install-tl")
        run("make pdf")
        run("make info")
        run("make install")
        run("make install-info")
        run("make install-pdf")
        run("echo '/usr/local/lib64/R/lib' > /etc/ld.so.conf.d/R.x86_64.conf")
        run("/sbin/ldconfig")
      run("echo 'PATH=/usr/local/texlive/2011/bin/x86_64-linux:$PATH' >> /etc/profile")
    run("rm -Rf ./r_installation_source")

@task
@roles('R')
@parallel
def install_R():
  """ Installing latest version of GNU-R using yum
  if the installed version of R is not latest then it will be updated by yum
  """
 # sudo yum erase tcl tcl-devel tk tk-devel libicu libicu-devel

#   rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-7.noarch.rpm
# sudo yum install tcl
# sudo yum clean all
# sudo yum install R
  epel_package_url = 'http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm'
  with settings(warn_only=True):
    run("rpm -Uvh %s" % epel_package_url)

  with cd("/tmp"):
    # run("yum install tcl -y")
    run("if [ ! -d ./r_installation ]; then mkdir ./r_installation; fi")
    with cd("./r_installation"):
      # run("yum install gcc* makse -y")
      run("yum install gcc make -y")
      run("yum install R R-devel R-core -y")
    run("rm -Rf ./r_installation")

@task
@roles('rserve', 'rstudio')
@parallel
def remove_R():
  """ Removing installed R from the assigned servers
  """

  sudo("yum remove R R-devel R-core -y")

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


R_rpm_names = [
  "R-devel-2.14.1-1.el5",
  "R-core-2.14.1-1.el5",
  "R-2.14.1-1.el5",
  "R-devel-2.14.1-1.el5",
  ]

@roles('all')
def check_hostname():
  """ Checking Host name of all nodes
  """
  result = sudo('hostname')
  print(result)

@roles('rserve', 'rstudio')
def check_rserve_version():
  """ Checking version of installed R
  This task checks if the installed R instances are assigned version
  """
  print(env.host)
  result = run(" R -e 'library(Rserve);sessionInfo();'| grep Rserve")


@task
@roles('R')
@parallel
def install_rserve():
  # repository_url = 'http://cran.r-project.org'
  repository_url = 'http://www.rforge.net'
  package_source_url = 'http://www.rforge.net/src/contrib/Rserve_1.7-0.tar.gz'
  with cd('/tmp'):
    sudo("if [ ! -d ./rserve_install ]; then mkdir ./rserve_install; fi")
    with cd('./rserve_install'):
      sudo("yum install make -y")
      sudo("/usr/bin/R -e 'install.packages(\"Rserve\", repos=\"%s\");'" % repository_url)
      # run("wget %s" % package_source_url)
      # run("/usr/bin/R CMD install ./Rserve_1.7-0.tar.gz")
      # rum("rm -Rf ./rserve_install")


@task
@roles('rstudio')
def install_rstudio():
  """ Installing Rstudio-server to the assigned host using RPM utility
  """
  rstudio_rpm = "rstudio-server-0.96.331-x86_64.rpm"

  with cd("/tmp"):
    with settings(warn_only=True):
      run("if [ ! -d ./rstudio_installation ]; then mkdir ./rstudio_installation; fi")
      with cd("./rstudio_installation"):
        run("rm -Rf *.rpm*")
        run("wget http://download2.rstudio.org/%s" % rstudio_rpm)
        run("rpm -Uvh ./%s" % rstudio_rpm)
      run("rm -Rf ./rstudio_installation")

@task
@roles('rhive_node')
@parallel
def install_rjava():
  """ Install Rstudio-server to the assigned host using rpm directly
  """
  with settings(warn_only=True):
    with cd("/tmp"):
      result = sudo("hadoop fs -ls /rhive")
      if result.strip() != "":
        sudo("hadoop fs -mkdir /rhive")
        sudo("hadoop fs -chmod 755 /rhive")

      sudo("hadoop fs -chown ndap /rhive")

      sudo("if [ ! -d ./rhive_installation ]; then mkdir ./rhive_installation; fi")
      with cd("./rhive_installation"):
        sudo("/usr/bin/R CMD javareconf")
        sudo("/usr/bin/R -e 'install.packages(\"rJava\", repos=\"http://cran.nexr.com\")'")
        sudo("/usr/bin/R -e 'install.packages(\"RJavaTools\", repos=\"http://cran.nexr.com\")'")

@task
@roles('rhive')
@parallel
def install_rhive():
  """ Install Rstudio-server to the assigned host using rpm directly
  """
  with settings(warn_only=True):
    with cd("/tmp"):
      result = sudo("hadoop fs -ls /rhive")
      if result.strip() != "":
        sudo("hadoop fs -mkdir /rhive")
        sudo("hadoop fs -chmod 755 /rhive")

      sudo("hadoop fs -chown nexr /rhive")

      sudo("if [ ! -d ./rhive_installation ]; then mkdir ./rhive_installation; fi")
      with cd("./rhive_installation"):
        sudo("/usr/bin/R CMD javareconf")
        sudo("/usr/bin/R -e 'install.packages(\"rJava\", repos=\"http://cran.nexr.com\")'")
        sudo("/usr/bin/R -e 'install.packages(\"RHive\", repos=\"http://cran.nexr.com\")'")

@task
@roles('rhive')
@parallel
def install_rhive_dev():
  """ Install Rstudio-server to the assigned host using rpm directly
  """
  # https://github.com/nexr/RHive/downloads
  # https://github.com/downloads/nexr/RHive/RHive_0.0-7.tar.gz
  with settings(warn_only=True):
    with cd("/tmp"):

      sudo("if [ ! -d ./rhive_installation ]; then mkdir ./rhive_installation; fi")
      with cd("./rhive_installation"):
        result = sudo("hadoop fs -ls /rhive")
        if result.strip() != "":
          sudo("hadoop fs -mkdir /rhive")
          sudo("hadoop fs -chmod 755 /rhive")

        sudo("hadoop fs -chown nexr /rhive")

        sudo("/usr/bin/R CMD javareconf")
        sudo("/usr/bin/R -e 'install.packages(\"rJava\", repos=\"http://cran.nexr.com\")'")
        sudo("wget https://github.com/downloads/nexr/RHive/RHive_0.0-7.tar.gz")
        sudo("/usr/bin/R CMD INSTALL ./RHive_0.0-7.tar.gz")
        # sudo("/usr/bin/R -e 'install.packages(\"RHive\", repos=\"http://cran.nexr.com\")'")
      sudo("rm -Rf ./rhive_installation")

@task
@roles('R')
@parallel
def set_r_env():
  """ Setting environment variables are related to RHive into the file '/usr/lib64/R/etc/Renviron'
  """
  unset_r_env()
  sudo("echo '##### RHive #####' >> /usr/lib64/R/etc/Renviron")
  sudo("echo 'HADOOP_HOME=%s' >> /usr/lib64/R/etc/Renviron" % "/home/ndap/ndap/modules/hadoop")
  sudo("echo 'HADOOP_CONF_DIR=%s' >> /usr/lib64/R/etc/Renviron" % "/home/ndap/ndap/modules/hadoop/conf")
  sudo("echo 'HIVE_HOME=%s' >> /usr/lib64/R/etc/Renviron" % "/home/ndap/ndap/modules/hive")
  sudo("echo 'HIVE_CONF_DIR=%s' >> /usr/lib64/R/etc/Renviron" % "/home/ndap/ndap/modules/hive/conf")
  sudo("echo 'RHIVE_DATA=%s' >> /usr/lib64/R/etc/Renviron" % "/srv/rhive_data")


@task
@roles('rhive_node', 'rstudio')
def unset_r_env():
  """ Removing environment variables are related to RHive from the file '/usr/lib64/R/etc/Renviron'
  """
  #result = sudo("cat /usr/lib64/R/etc/Renviron | grep -v -E '^HADOOP_HOME=|^HIVE_HOME=|^RHIVE_DATA='")
  #new_content = result
  time_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
  sudo("mv /usr/lib64/R/etc/Renviron /usr/lib64/R/etc/Renviron.%s" % time_str)
  sudo("cat /usr/lib64/R/etc/Renviron.%s | grep -v -E '^##### RHive #####|^HADOOP_HOME=|^HIVE_HOME=|^HADOOP_CONF_DIR=|^HIVE_CONF_DIR=|^RHIVE_DATA=' > /usr/lib64/R/etc/Renviron" % time_str)

@roles('rhive_node', 'rstudio')
def check_r_env():
  """ Checking environment variables for RHive
  This task only checks the '/usr/lib64/R/etc/Renviron' file
  """
  with settings(warn_only=True):
    result = run("cat /usr/lib64/R/etc/Renviron | grep -E '^HADOOP_HOME=|^HIVE_HOME=|^RHIVE_DATA='")
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

@roles("rhive_node")
def make_rhive_data_path():
  """ Checking if data path for RHive exists or not
  """
  with settings(warn_only=True):
    #if not path_exists(config['ndap_rhive_data_path']):
    #    write_error_report("error", env.host, inspect.stack()[0][3])
    run("if [ ! -d %(ndap_rhive_data_path)s ]; then mkdir -p %(ndap_rhive_data_path)s ;fi" % config)
    run("chmod -R 777 %(ndap_rhive_data_path)s" % config)
    run("chown -R nexr %(ndap_rhive_data_path)s" % config)

@roles("rhive_node")
def clear_rhive_data_path():
  """ Clearing data path for RHive
  """
  with settings(warn_only=True):
    run("rm -Rf %(ndap_rhive_data_path)s/*" % config)

@roles("rhive_node")
def remove_rhive_data_path():
  """ Removing data path for RHive
  """
  with settings(warn_only=True):
    run("rm -Rf %(ndap_rhive_data_path)s" % config)

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

@roles("rhive_node")
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


@roles("rhive_node")
def check_jobnode_ports():
  """ Checking all ports are related to run job node for RHive environment
  """
  mandatory_port_list = ["6311", "50020", "22", "50010", "50075"]
  get_missed_ports(mandatory_port_list)

@task
@roles("rhive_node")
@parallel
def stop_rserve():
  """ Checking port of Rserve daemon is listening
  """
  with settings(warn_only=True):
    result = sudo("netstat -nltp | grep '/Rserve' | awk '{print $7}' | awk -F \"/\" '{print $1}'")
    if result != "":
      sudo("/bin/kill %s" % result)

@roles("all")
@parallel
def set_perm_path():
  run("chown nexr:nexr /srv")

@roles("rsyncdnode")
@parallel
def install_rsyncd():
  with settings(warn_only=True):
    result = run("yum install rsync -y")

@roles("rsyncdnode")
@parallel
def set_rsyncd_cloudlog():
  rsyncd_conf_content = """
secrets file=/etc/rsyncd.secrets
uid=nexr
gid=nexr
use chroot=yes
read only=no
list=yes

[cloudstack]
comment=cloudstack
path=/srv/rawdata/cloudstack
hosts allow=*
auth users=cloudlog

[netflow]
comment=netflow
path=/srv/rawdata/netflow
hosts allow=*
auth users=cloudlog

[syslog]
comment=syslog
path=/srv/rawdata/syslog
hosts allow=*
auth users=cloudlog
"""
  run("echo '%s' > /etc/rsyncd.conf" % rsyncd_conf_content)

  rsyncd_secrets_content = """cloudlog:synclog
"""
  run("echo '%s' > /etc/rsyncd.secrets" % rsyncd_secrets_content)

  #vi /etc/xinetd.d/rsync
  xinetd_d_rsync_content = """
# default: off
# description: The rsync server is a good addition to an ftp server, as it \
#       allows crc checksumming etc.
service rsync
{
    # disable = yew
    disable = no
    socket_type     = stream
    wait            = no
    user            = root
    server          = /usr/bin/rsync
    server_args     = --daemon
    log_on_failure  += USERID
}
"""
  run("echo '%s' > /etc/xinetd.d/rsync" % xinetd_d_rsync_content)
  run("chown root.root /etc/rsyncd.*")
  run("chmod 600 /etc/rsyncd.*")

  dirs = ("/srv/rawdata/cloudstack", "/srv/rawdata/syslog", "/srv/rawdata/netflow")
  for dir in dirs:
    run("if [ ! -d %s ]; then mkdir -p %s; fi" % (dir, dir))

  run("chown -R nexr:nexr /srv/rawdata")

@roles("rsyncdnode")
@parallel
def restart_rsyncd():
  with settings(warn_only=True):
    result = run("service xinetd restart")

@roles("all")
@parallel
def install_ntp():
  with settings(warn_only=True):
    result = run("yum install ntp -y")

@roles("all")
@parallel
def start_ntpd():
  with settings(warn_only=True):
    result = run("/etc/init.d/ntpd start")

@roles("xen")
def set_xen_time():
  """ Starting Rserve as as daemon
  """
  with settings(warn_only=True):
    #run("ntpdate time.kriss.re.kr")
    # rdate -s time.bora.net
    # run("rdate -s time.bora.net")
    run("ntpdate -u time.bora.net")

@roles('all')
def set_vm_wallclock():
  run("echo 1 > /proc/sys/xen/independent_wallclock")

@roles("all")
def set_time_sync():
  with settings(warn_only=True):
    # run("ntpdate time.kriss.re.kr")
    # rdate -s time.bora.net
    # run("ntpdate -u time.bora.net")
    ## run("echo 1 > /proc/sys/xen/independent_wallclock")
    run("date;ntpdate -u time.bora.net;date")

@roles("all")
def check_time():
  """ Starting Rserve as as daemon
  """
  with settings(warn_only=True):
    #sudo("ntpdate time.kriss.re.kr")
    # rdate -s time.bora.net
    # rdate -s ntp.kornet.net
    run("date")

@roles("xen")
def check_xen_time():
  """ Starting Rserve as as daemon
  """
  with settings(warn_only=True):
    #sudo("ntpdate time.kriss.re.kr")
    # rdate -s time.bora.net
    # rdate -s ntp.kornet.net
    run("date")


@task
@roles("rhive_node")
@parallel
def start_rserve():
  """ Starting Rserve as as daemon
  """
  with settings(warn_only=True):
    result = sudo("export LC_ALL=C && sudo -u ndap /usr/bin/R CMD Rserve > /var/log/Rserve.log")

@task
@roles("rhive_node")
@parallel
def restart_rserve():
  stop_rserve()
  start_rserve()


@task
@roles('rstudio')
def restart_rstudio():
  """ Restarting RStudio-server
  """
  sudo("/etc/init.d/rstudio-server restart")


@roles('rstudio')
def stop_rstudio():
  """ Stopping RStudio-server
  """
  run("/etc/init.d/rstudio-server stop")

@task
@roles('rstudio')
def start_rstudio():
  """ Starting RStudio-server
  """
  run("/etc/init.d/rstudio-server start")


@roles('rstudio')
def add_users():
  """ Adding reserved users to hosts
  """
  userlist = ["aiden.hong", "irene.kwon", "eugene.hwang", "haven.jeon", "antony.ryu", "jun.cho", "eric.kim"]
  default_password = "nexr4101"
  with settings(warn_only=True):
    for userid in userlist:
      result = sudo("cat /etc/passwd | grep \"^%s:\"" % userid)
      if result.strip() == "":
        run("adduser %s" % userid)
        run("chpasswd <<< '%s:%s'" % (userid, default_password))

@roles("all")
def check_writable():
  """Checking writing permission on several directorie
  """
  filename_for_test = "file_for_writting_test"
  with settings(warn_only=True):
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

@roles('R')
@parallel
def update_yum():
  run("yum update -y")


@roles('all')
@parallel
def install_utils():
  run("yum install dstat -y")
  run("yum install sysstat -y")
  run("yum install htop -y")
  run("yum install screen -y")
  run("yum install tmux -y")
  run("yum install zsh -y")
  run("yum install mc -y")

@roles('all')
def check_java():
  run("rpm -qa | grep jdk")

@roles('all')
@parallel
def install_java():
  run("yum install java-1.6.0-openjdk.x86_64 java-1.6.0-openjdk-devel.x86_64 -y")

@task
@roles('R')
@parallel
def set_rserve_conf():
  profile_script_filename = "/etc/Rserv.conf"
  profile_script_content = """remote enable
port 6311
encoding utf8
"""
  run("echo '%s' > %s" % (profile_script_content, profile_script_filename))


@roles('all')
@parallel
def set_java_home():
  # " update-alternatives --display java"
  profile_script_filename = "/etc/profile.d/java.sh"
  profile_script_content = """
export JAVA_HOME=%(java_home_path)s
export PATH=$PATH:%(java_home_path)s/bin
""" % config
  run("echo '%s' > %s" % (profile_script_content, profile_script_filename))


@roles('all')
@parallel
def set_profile_ndap_all():
  profile_script_filename = "/etc/profile.d/ndap_all.sh"
  profile_script_content = """# NDAP enviroments
export JAVA_HOME=%(java_home_path)s
export HADOOP_HOME=%(ndap_hadoop_home_path)s
export HIVE_HOME=%(ndap_hive_home_path)s
export LAMA_HOME=%(ndap_lama_home_path)s
export OOZIE_HOME=%(ndap_oozie_home_path)s
export TOMCAT_HOME=%(ndap_tomcat_home_path)s

export PATH=$PATH:%(ndap_hadoop_home_path)s/bin:%(ndap_hive_home_path)s/bin

# ulimit for ndap-collector
ulimit -n %(ulimit_open_maxfiles)s
# path
export PATH=$PATH:%(java_home_path)s/bin:%(ndap_hadoop_home_path)s/bin:%(ndap_hive_home_path)s/bin
""" % config
  run("ulimit -n %s" % config['ulimit_open_maxfiles'])
  run("echo '%s' > %s" % (profile_script_content, profile_script_filename))

@roles('all')
def set_hadoop_home():
  """ Setting environment variables are related to RHive into the file '/usr/lib64/R/etc/Renviron'
  """
  profile_script_filename = "/etc/profile.d/hadoop.sh"
  profile_script_content = """
export HADOOP_HOME=%(hadoop_home)s
export HIVE_HOME=%(hive_home)s
export PATH=$PATH:%(hadoop_home)s/bin:%(hive_home)s/bin

export HADOOP_NAMENODE_USER=nexr
export HADOOP_DATANODE_USER=nexr
export HADOOP_SECONDARYNAMENODE_USER=nexr
export HADOOP_JOBTRACKER_USER=nexr
export HADOOP_TASKTRACKER_USER=nexr
""" % {"hadoop_home":config['ndap_hadoop_home_path'], "hive_home":config['ndap_hive_home_path']}
  run("echo '%s' > %s" % (profile_script_content, profile_script_filename))


@roles('namenode')
@parallel
def copy_mysql_jar():
  run("cp /srv/mysql-connector-java-5.1.18-bin.jar %s/lib/" % rhive_hive_path)

@roles('all')
@parallel
def copy_event_jar():
  run("cp /home/ndap/ndap/ndap_collector/lib/collector-event-1.1.0.1003.jar /home/ndap/ndap/hadoop/lib/")
  run("cp /home/ndap/ndap/ndap_collector/lib/collector-event-1.1.0.1003.jar /home/ndap/ndap/hive/lib/")
  run("chown nexr /home/ndap/ndap/hadoop/lib/*")
  run("chown nexr /home/ndap/ndap/hive/lib/*")


@roles('all')
@parallel
def push_hadoop():
  sudo("if [ ! -d '/srv' ]; then mkdir /srv; fi")
  put("./shipments/hadoop-0.20.203.0rc1.tar.gz", "/srv")
  put("./shipments/hive-0.8.0-nr1004.inst.tar.gz", "/srv")
  put("./shipments/mysql-connector-java-5.1.18-bin.jar", "/srv")

@roles('all')
@parallel
def extract_hadoop():
  with cd('/srv'):
    run("tar xvfz ./hadoop-0.20.203.0rc1.tar.gz")
    run("tar xvfz ./hive-0.8.0-nr1004.inst.tar.gz")

@roles('all')
@parallel
def set_hadoop_config():
  self.config['datetime'] =  datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

  core_site_xml = """<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!-- Generatated for KT-cloudlog: %(datetime)s -->

<configuration>
<property>
        <name>fs.default.name</name>
        <value>hdfs://%(hadoopconf_hdfs_nodename)s:%(hadoopconf_hdfs_port)s</value>
</property>
<!-- property>
  <name>hadoop.tmp.dir</name>
  <value>%(hadoopconf_base_path)s/%(hadoopconf_hadoop_data_path)s/hadoop-${user.name}</value>
  <description>A base for other temporary directories.</description>
</property -->
<property>
  <name>hadoop.tmp.dir</name>
  <value>%(hadoopconf_base_path)s/%(hadoopconf_hadoop_data_path)s</value>
  <description>A base for other temporary directories.</description>
</property>
</configuration>
""" % self.config

  mapred_site_xml = """<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!-- Generatated for KT-cloudlog: %(datetime)s -->

<configuration>
  <property>
    <name>mapred.job.tracker</name>
    <value>%(hadoopconf_jobtracker_nodename)s:%(hadoopconf_jobtracker_port)s</value>
  </property>

  <property>
    <name>mapred.tasktracker.map.tasks.maximum</name>
    <value>4</value>
  </property>

  <property>
    <name>mapred.tasktracker.reduce.tasks.maximum</name>
    <value>4</value>
  </property>

  <property>
    <name>mapred.tasktracker.expiry.interval</name>
    <value>60000000</value>
  </property>

  <property>
    <name>mapred.tasktracker.expiry.interval</name>
    <value>60000000</value>
  </property>

  <property>
    <name>tasktracker.http.threads</name>
    <value>80</value>
  </property>
<!--
  <property>
    <name>mapred.jobtracker.taskScheduler</name>
    <value>org.apache.hadoop.mapred.FairScheduler</value>
  </property>
-->
</configuration>
""" % self.config

  # need to set limits in the system
  hdfs_site_xml = """<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>3</value>
    </property>
    <property>
        <name>dfs.datanode.max.xcievers</name>
        <value>%(hadoopconf_dfs.datanode.max.xcievers)s</value>
    </property>
</configuration>
""" % self.config

  slaves = "\n".join(host_aliases[2:])
  master = host_aliases[0]

  core_site_xml_filename = "%s/core-site.xml" % self.config['ndap_hadoop_conf_path']
  mapred_site_xml_filename = "%s/mapred-site.xml"  % self.config['ndap_hadoop_conf_path']
  hdfs_site_xml_filename = "%s/hdfs-site.xml" % self.config['ndap_hadoop_conf_path']
  slaves_filename = "%s/slaves"  % self.config['ndap_hadoop_conf_path']
  master_filename = "%s/master"  % self.config['ndap_hadoop_conf_path']

  run("if [ ! -d %(hadoopconf_base_path)s/%(hadoopconf_hadoop_data_path)s ]; then mkdir %(hadoopconf_base_path)s/%(hadoopconf_hadoop_data_path)s; fi" % self.config)

  # generating Hadoop config files
  run("echo '%s' > %s" % (core_site_xml, core_site_xml_filename))
  run("echo '%s' > %s" % (mapred_site_xml, mapred_site_xml_filename))
  run("echo '%s' > %s" % (hdfs_site_xml, hdfs_site_xml_filename))
  run("echo '%s' > %s" % (slaves, slaves_filename))
  run("echo '%s' > %s" % (master, master_filename))

@roles('rstudio', 'jobnode')
@parallel
def push_mysql_jdbc():
  put("./shipments/install/mysql-connector-java-5.1.18-bin.jar", "/home/ndap/ndap/hive/lib/")

@roles('all')
@parallel
def set_hive_config():
  hive_site_xml = """<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
      <name>javax.jdo.option.ConnectionURL</name>
      <value>jdbc:mysql://10.7.5.230/hive?createDatabaseIfNotExist=true</value>
      <description>JDBC connect string for Mysql</description>
    </property>
    <property>
      <name>javax.jdo.option.ConnectionDriverName</name>
      <value>com.mysql.jdbc.Driver</value>
      <description>Driver class name for Mysql</description>
    </property>
    <property>
      <name>javax.jdo.option.ConnectionUserName</name>
      <value>hive</value>
      <description>username to use against Mysql</description>
    </property>
    <property>
      <name>javax.jdo.option.ConnectionPassword</name>
      <value>nexr4101</value>
      <description>password to use against Mysql</description>
    </property>

    <property>
      <name>hive.metastore.warehouse.dir</name>
      <!-- value>/user/nexr/hive/warehouse</value -->
      <value>/user/hive/warehouse</value>
      <description>location of default database for the warehouse</description>
    </property>
    <property>
      <name>hive.input.format</name>
      <value>org.apache.hadoop.hive.ql.io.CombineHiveInputFormat</value>
    </property>

    <property>
      <name>mapred.max.split.size</name>
      <value>256000000</value>
      <description>The maximum size chunk that map input should be split into.</description>
    </property>

    <!-- adding libary files for NexR Data (NexR Data 처리를 위한 라이브러리 참조 추가) -->
    <property>
        <name>hive.aux.jars.path</name>
        <value>file:///home/ndap/ndap/ndap_collector/lib/collector-event-1.1.0.1003.jar/</value>
    </property>

</configuration>
""" % config

  hive_conf_path = "/home/ndap/ndap/hive/conf"
  hive_site_xml_filename = "%s/hive-site.xml" % hive_conf_path

  run("echo '%s' > %s" % (hive_site_xml, hive_site_xml_filename))
  run("touch ~nexr/.hiverc")


@roles('all')
def modify_hadoop():
  timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
  with cd("%s/bin" % rhive_hadoop_path):
    run("if [ ! -f ./hadoop.origin ]; then cp ./hadoop ./hadoop.origin; fi")
    run("if [ ! -f ./hadoop ]; then cp ./hadoop.origin ./hadoop; fi")
    run("mv ./hadoop ./hadoop.%s" % timestamp)
    run("cat ./hadoop.origin | sed -e 's/HADOOP_OPTS=\"$HADOOP_OPTS -jvm server $HADOOP_DATANODE_OPTS/#HADOOP_OPTS=\"$HADOOP_OPTS -jvm server $HADOOP_DATANODE_OPTS\\n    HADOOP_OPTS=\"$HADOOP_OPTS -server $HADOOP_DATANODE_OPTS/g' > ./hadoop")
    run("chmod 755 ./hadoop")

@roles('namenode')
def install_mysql():
  run("yum install mysql.x86_64 -y")
  run("yum install mysql-server.x86_64 -y")
  run("yum install mysql-devel -y")

@roles('namenode')
def set_mysql_config():
  mysql_data_dir = "/srv/mysqldata"
  run("if [ ! -d %(dir)s ]; then mkdir %(dir)s ;fi" % {"dir":mysql_data_dir})

  my_cnf = """[mysqld]
datadir=%s
socket=/var/lib/mysql/mysql.sock
user=mysql
# Default to using old password format for compatibility with mysql 3.x
# clients (those using the mysqlclient10 compatibility package).
old_passwords=1

# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
# symbolic-links=0

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
""" % mysql_data_dir
  run("mv /etc/my.cnf /etc/my.cnf.origin")
  run("echo '%s' > /etc/my.cnf" % my_cnf)

@roles('namenode')
@parallel
def start_mysql():
  run("/etc/init.d/mysqld start")

@roles('namenode')
@parallel
def stop_mysql():
  run("/etc/init.d/mysqld stop")

@roles('namenode')
@parallel
def restart_mysql():
  run("/etc/init.d/mysqld restart")

@roles('namenode')
@parallel
def init_mysql():
  hive_database = "metastore"
  script_content = """CREATE DATABASE %(hive_database)s; USE %(hive_database)s; SOURCE %(hive_home)s/scripts/metastore/upgrade/mysql/hive-schema-0.8.0.mysql.sql;""" % {"hive_database": hive_database, "hive_home":rhive_hive_path}
  run("mysql -u root <<< \"%s\"" % script_content)

  script_content = "CREATE USER 'hiveuser'@'%' IDENTIFIED BY 'nexr4101';GRANT SELECT,INSERT,UPDATE,DELETE ON metastore.* TO 'hiveuser'@'%'; REVOKE ALTER,CREATE ON metastore.* FROM 'hiveuser'@'%';"
  run("mysql -u root <<< \"%s\"" % script_content)

"""
UPDATE mysql.user SET User = 'hiveuser', Host = '%', Password=OLD_PASSWORD('nexr4101'), max_questions = '0', max_updates = '0', max_connections = '0', ssl_type = '', ssl_cipher = '', x509_issuer = '', x509_subject = '', max_user_connections = '0' where User = 'hiveuser' and Host = '%';

FLUSH PRIVILEGES;

GRANT Create Temporary Tables, Update, References, Insert, Create Routine, Alter, Create View, Lock Tables, Drop, Execute, Grant Option, Alter Routine, Create, Index, Delete, Select, Show View ON `metastore`.* TO `hiveuser`@`%`;
"""

@roles('all')
def push_key():
  run("if [ ! -d ~/.ssh ]; then mkdir ~/.ssh; fi")
  run("if [ -f ~/.ssh/authorized_keys ]; then rm -f ~/.ssh/*; fi")
  put("./key/id_rsa", "/root/.ssh/")
  put("./key/id_rsa.pub", "/root/.ssh/")
  local("cat ./key/id_rsa.pub | ssh root@%s 'cat >> ~/.ssh/authorized_keys'" % env.host)
  run("cat ~/.ssh/authorized_keys | sort | uniq > ~/.ssh/authorized_keys.new")
  run("rm ~/.ssh/authorized_keys")
  run("mv ~/.ssh/authorized_keys.new ~/.ssh/authorized_keys")
  run("chmod 700 ~/.ssh")
  run("chmod 600 ~/.ssh/*")

@roles('all')
def push_key_runuser():
  userhome = run("cat /etc/passwd | grep %s | awk -F':' '{print $6}'" % runuser)
  param = {"USERHOME":userhome.strip(), "RUNUSER":runuser, "ENVHOST":env.host}

  run("if [ ! -d %(USERHOME)s/.ssh ]; then mkdir %(USERHOME)s/.ssh; fi" % param)
  run("if [ -f %(USERHOME)s/.ssh/authorized_keys ]; then rm -f %(USERHOME)s/.ssh/*; fi" % param)
  put("./key/id_rsa", "%(USERHOME)s/.ssh/" % param)
  put("./key/id_rsa.pub", "%(USERHOME)s/.ssh/" % param)
  local("cat ./key/id_rsa.pub | ssh root@%(ENVHOST)s 'cat >> %(USERHOME)s/.ssh/authorized_keys'" % param)
  run("cat %(USERHOME)s/.ssh/authorized_keys | sort | uniq > %(USERHOME)s/.ssh/authorized_keys.new" % param)
  run("rm %(USERHOME)s/.ssh/authorized_keys" % param)
  run("mv %(USERHOME)s/.ssh/authorized_keys.new %(USERHOME)s/.ssh/authorized_keys" % param)
  run("chmod 700 %(USERHOME)s/.ssh" % param)
  run("chmod 600 %(USERHOME)s/.ssh/*" % param)
  run("chown -R %(RUNUSER)s:%(RUNUSER)s %(USERHOME)s/.ssh" % param)

@roles('all')
def super_push_key():
  local("cat ~/.ssh/id_rsa.pub | ssh root@%s 'cat >> ~/.ssh/authorized_keys'" % env.host)
  run("cat ~/.ssh/authorized_keys | sort | uniq > ~/.ssh/authorized_keys.new")
  run("rm ~/.ssh/authorized_keys")
  run("mv ~/.ssh/authorized_keys.new ~/.ssh/authorized_keys")

@roles('all')
def super_push_key_runuser():
  local("cat ~/.ssh/id_rsa.pub | ssh root@%s 'cat >> /home/%s/.ssh/authorized_keys'" % (env.host, runuser))
  run("cat /home/%s/.ssh/authorized_keys | sort | uniq > /home/%s/.ssh/authorized_keys.new" % (runuser, runuser))
  run("rm /home/%s/.ssh/authorized_keys" % runuser)
  run("mv /home/%s/.ssh/authorized_keys.new /home/%s/.ssh/authorized_keys" % (runuser, runuser))
  run("chmod 700 /home/%s/.ssh" % runuser)
  run("chmod 600 /home/%s/.ssh/*" % runuser)
  run("chown -R %s:%s /home/%s/.ssh" % (runuser, runuser, runuser))

def make_hosts(ip_address):
  hosts_items = {
    "10.7.16.128":"clogv01 clogv01.ktcloudlog.com",
    "10.7.16.129":"clogv02 clogv02.ktcloudlog.com",
    "10.7.16.130":"clogv03 clogv03.ktcloudlog.com",
    "10.7.16.131":"clogv04 clogv04.ktcloudlog.com",
    "10.7.16.132":"clogv05 clogv05.ktcloudlog.com",
    "10.7.16.133":"clogv06 clogv06.ktcloudlog.com",
    "10.7.16.134":"clogv07 clogv07.ktcloudlog.com",
    "10.7.16.135":"clogv08 clogv08.ktcloudlog.com",
    "10.7.16.136":"clogv09 clogv09.ktcloudlog.com",
    "10.7.16.137":"clogv10 clogv10.ktcloudlog.com",
    "10.7.16.138":"clogv11 clogv11.ktcloudlog.com",
    "10.7.16.139":"clogv12 clogv12.ktcloudlog.com",
    "10.7.16.140":"clogv13 clogv13.ktcloudlog.com",
    "10.7.16.141":"clogv14 clogv14.ktcloudlog.com",
    "10.7.16.142":"clogv15 clogv15.ktcloudlog.com",
    "10.7.16.143":"clogv16 clogv16.ktcloudlog.com",
    "10.7.16.144":"clogv17 clogv17.ktcloudlog.com",
    "10.7.16.145":"clogv18 clogv18.ktcloudlog.com",
    "10.7.16.146":"clogv19 clogv19.ktcloudlog.com",
    "10.7.16.147":"clogv20 clogv20.ktcloudlog.com",
    "10.7.16.148":"clogv21 clogv21.ktcloudlog.com",
    "10.7.16.149":"clogv22 clogv22.ktcloudlog.com",
    "10.7.16.150":"clogv23 clogv23.ktcloudlog.com",
    "10.7.16.151":"clogv24 clogv24.ktcloudlog.com",
    "10.7.16.152":"clogv25 clogv25.ktcloudlog.com",
    "10.7.16.153":"clogv26 clogv26.ktcloudlog.com",
    "10.7.16.154":"clogv27 clogv27.ktcloudlog.com",
    "10.7.16.155":"clogv28 clogv28.ktcloudlog.com",
    "10.7.16.156":"clogv29 clogv29.ktcloudlog.com",
    "10.7.16.157":"clogv30 clogv30.ktcloudlog.com",
    "10.7.16.158":"clogv31 clogv31.ktcloudlog.com",
    "10.7.16.159":"clogv32 clogv32.ktcloudlog.com",
    "10.7.16.160":"clogv33 clogv33.ktcloudlog.com",
    "10.7.16.161":"clogv34 clogv34.ktcloudlog.com",
    "10.7.16.162":"clogv35 clogv35.ktcloudlog.com",
    "10.7.16.163":"clogv36 clogv36.ktcloudlog.com",
    "10.7.16.164":"clogv37 clogv37.ktcloudlog.com",
    "10.7.16.165":"clogv38 clogv38.ktcloudlog.com",
    "10.7.16.166":"clogv39 clogv39.ktcloudlog.com",
    "10.7.16.167":"clogv40 clogv40.ktcloudlog.com",
    "10.7.16.168":"clogv41 clogv41.ktcloudlog.com",
    "10.7.16.169":"clogv42 clogv42.ktcloudlog.com",
    "10.7.16.170":"clogv43 clogv43.ktcloudlog.com",
    "10.7.16.171":"clogv44 clogv44.ktcloudlog.com",
    "10.7.16.172":"clogv45 clogv45.ktcloudlog.com",
    "10.7.16.173":"clogv46 clogv46.ktcloudlog.com",
    "10.7.16.174":"clogv47 clogv47.ktcloudlog.com",
    "10.7.16.175":"clogv48 clogv48.ktcloudlog.com",
    "10.7.16.176":"clogv49 clogv49.ktcloudlog.com",
    "10.7.16.177":"clogv50 clogv50.ktcloudlog.com",
    "10.7.16.178":"clogv51 clogv51.ktcloudlog.com",
    "10.7.16.179":"clogv52 clogv52.ktcloudlog.com",
    "10.7.16.180":"clogv53 clogv53.ktcloudlog.com",
    "10.7.16.181":"clogv54 clogv54.ktcloudlog.com",
    "10.7.16.182":"clogv55 clogv55.ktcloudlog.com",
    "10.7.16.183":"clogv56 clogv56.ktcloudlog.com",
    "10.7.16.184":"clogv57 clogv57.ktcloudlog.com",
    "10.7.16.185":"clogv58 clogv58.ktcloudlog.com",
    "10.7.16.186":"clogv59 clogv59.ktcloudlog.com",
    "10.7.16.187":"clogv60 clogv60.ktcloudlog.com",
    "10.7.16.188":"clogv61 clogv61.ktcloudlog.com",
    "10.7.16.189":"clogv62 clogv62.ktcloudlog.com",
    "10.7.16.190":"clogv63 clogv63.ktcloudlog.com",
    "10.7.16.191":"clogv64 clogv64.ktcloudlog.com",
    "10.7.16.192":"clogv65 clogv65.ktcloudlog.com",
    "10.7.16.193":"clogv66 clogv66.ktcloudlog.com"
  }

  hosts_items_private = {
    "10.7.16.128":"clogh01",
    "10.7.16.129":"clogh02",
    "10.7.16.130":"clogh03",
    "10.7.16.131":"clogh04",
    "10.7.16.132":"clogh05",
    "10.7.16.133":"clogh06",
    "10.7.16.134":"clogh07",
    "10.7.16.135":"clogh08",
    "10.7.16.136":"clogh09",
    "10.7.16.137":"clogh10",
    "10.7.16.138":"clogh11",
    "10.7.16.139":"clogh12",
    "10.7.16.140":"clogh13",
    "10.7.16.141":"clogh14",
    "10.7.16.142":"clogh15",
    "10.7.16.143":"clogh16",
    "10.7.16.144":"clogh17",
    "10.7.16.145":"clogh18",
    "10.7.16.146":"clogh19",
    "10.7.16.147":"clogh20",
    "10.7.16.148":"clogh21",
    "10.7.16.149":"clogh22",
    "10.7.16.150":"clogh23",
    "10.7.16.151":"clogh24",
    "10.7.16.152":"clogh25",
    "10.7.16.153":"clogh26",
    "10.7.16.154":"clogh27",
    "10.7.16.155":"clogh28",
    "10.7.16.156":"clogh29",
    "10.7.16.157":"clogh30",
    "10.7.16.158":"clogh31",
    "10.7.16.159":"clogh32",
    "10.7.16.160":"clogh33",
    "10.7.16.161":"clogh34",
    "10.7.16.162":"clogh35",
    "10.7.16.163":"clogh36",
    "10.7.16.164":"clogh37",
    "10.7.16.165":"clogh38",
    "10.7.16.166":"clogh39",
    "10.7.16.167":"clogh40",
    "10.7.16.168":"clogh41",
    "10.7.16.169":"clogh42",
    "10.7.16.170":"clogh43",
    "10.7.16.171":"clogh44",
    "10.7.16.172":"clogh45",
    "10.7.16.173":"clogh46",
    "10.7.16.174":"clogh47",
    "10.7.16.175":"clogh48",
    "10.7.16.176":"clogh49",
    "10.7.16.177":"clogh50",
    "10.7.16.178":"clogh51",
    "10.7.16.179":"clogh52",
    "10.7.16.180":"clogh53",
    "10.7.16.181":"clogh54",
    "10.7.16.182":"clogh55",
    "10.7.16.183":"clogh56",
    "10.7.16.184":"clogh57",
    "10.7.16.185":"clogh58",
    "10.7.16.186":"clogh59",
    "10.7.16.187":"clogh60",
    "10.7.16.188":"clogh61",
    "10.7.16.189":"clogh62",
    "10.7.16.190":"clogh63",
    "10.7.16.191":"clogh64",
    "10.7.16.192":"clogh65",
    "10.7.16.193":"clogh66"
  }

  host_name = hosts_items[ip_address]
  hosts = """
# Do not remove the following line, or various programs
# that require network functionality will fail.
#127.0.0.1               %s localhost.localdomain localhost
127.0.0.1               localhost.localdomain localhost
::1             localhost6.localdomain6 localhost6
""" % host_name

  hosts_items_new = []
  for key, item in  sorted(hosts_items.items()):
    hosts_items_new.append("%s\t%s" % (key, item))

  hosts += "\n".join(hosts_items_new)
  hosts += "\n# -- private network for Hadoop cluster\n"
  hosts_items_new = []

  for key, item in sorted(hosts_items_private.items()):
    hosts_items_new.append("%s\t%s" % (key, item))

  hosts += "\n".join(hosts_items_new)

  return hosts

def check_bonding():
  # dom0
  # /proc/net/bonding/bond0
  pass

@roles('all')
#@parallel
def stop_firewall():
  # /etc/selinux/config
  # SELINUX=enforcing
  # SELINUX-disable
  with settings(warn_only=True):
    #run("if [ ps aux | grep iptables | grep -v grep -ne '' ]; then service iptables stop; fi")
    run("service iptables stop")
    run("/usr/sbin/setenforce 0")
    run("chkconfig iptables off")
    run("/etc/init.d/iptables stop")

# DFS health check
# http://node00:50070/dfshealth.jsp
@roles('all')
@parallel
def set_hosts_file():
# CloudLog testbed3
  hosts_text = make_hosts(env.host)

  run("echo '%s' > /etc/hosts" % hosts_text)

@roles('all')
@parallel
def set_ssh_config():
  content = """StrictHostKeyChecking=no"""
  run("echo '%s' > ~/.ssh/config" % content)

@roles('all')
@parallel
def set_ssh_config_runuser():
  content = """StrictHostKeyChecking=no"""
  run("echo '%s' > /home/%s/.ssh/config" % (content, runuser))

@roles('all')
@parallel
def set_sudoers():
  content = """
# ---- CloudLog runuser
Defaults:nexr !requiretty
nexr    ALL=(ALL)       NOPASSWD: ALL
"""
  run("echo '%s' >> /etc/sudoers" % content)

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
  with settings(warn_only=True):
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

if __name__ == "__main__":
  pass