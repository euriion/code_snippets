# -*- coding: utf-8 -*-
from __future__ import with_statement
import inspect
import subprocess

__version__ = "0.0.1.1001"
__author__ = "aiden.hong@nexr.com"
__doc__ = """A script to operate CloudLog work environment using Fabric
- This script need the Fabric package. first install it before using

Usages for command line:
    fab check_r_version
    fab -R all check_r_version
    fab -R namenode check_r_version
    fab -R jobnode check_r_version

Usage for crontab:
    add following lines to the crontab
    mailto=aiden.hong@nexr.com
    */10 * * * * cd /home/aiden.hong/fabric/cloudlog_rhive;/usr/local/bin/python2.7 fabfile_example.py
"""

readme_file_content = """
Step to setup CloudLog
run the comands as following steps
* fab push_key
* fab add_system_users
* set_ssh_config
* set_ssh_config_runuser
* super_push_key
* super_push_key_runuser
* set_hosts_file
* set_sudoer_runuser
* update_yum
* install_java
* install_r
* set_ulimit
* install_korean_fonts (optional, just for Rstudio plotting)
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

yum_packages = {}
yum_packages["java"] = [
  "java-1.6.0-openjdk.x86_64",
  "java-1.6.0-openjdk-devel.x86_64"
]

#__all__ = ['check_base_path', 'check_hadoop_path']

def write_error_report(status, host, task, description=""):
  report_filename = "./report.txt"
  if os.path.exists(os.getcwd() + "/run_results"):
    print("writing error report")
    open("%s/%s" % (os.getcwd() + "/run_results", report_filename), "a+").write(
      "\t".join((status, host, task, description)) + "\n")


def send_report():
  report_filename = "./report.txt"
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

  message = MIMEMultipart('alternative')
  message['Subject'] = subject
  message['From'] = sender
  message['To'] = receiver
  message.attach(MIMEText(body, 'html')) # message.attach(MIMEText(body, 'text'))

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

env.hosts = [
  '10.7.16.128',
  '10.7.16.129',
  '10.7.16.130',
  '10.7.16.131',
  '10.7.16.132',
  '10.7.16.133',
  '10.7.16.134',
  '10.7.16.135',
  '10.7.16.136',
  '10.7.16.137',
  '10.7.16.138',
  '10.7.16.139',
  '10.7.16.140',
  '10.7.16.141',
  '10.7.16.142',
  '10.7.16.143',
  '10.7.16.144',
  '10.7.16.145',
  '10.7.16.146',
  '10.7.16.147',
  '10.7.16.148',
  '10.7.16.149',
  '10.7.16.150',
  '10.7.16.151',
  '10.7.16.152',
  '10.7.16.153',
  '10.7.16.154',
  '10.7.16.155',
  '10.7.16.156',
  '10.7.16.157',
  '10.7.16.158',
  '10.7.16.159',
  '10.7.16.160',
  '10.7.16.161',
  '10.7.16.162',
  '10.7.16.163',
  '10.7.16.164',
  '10.7.16.165',
  '10.7.16.166',
  '10.7.16.167',
  '10.7.16.168',
  '10.7.16.169',
  '10.7.16.170',
  '10.7.16.171',
  '10.7.16.172',
  '10.7.16.173',
  '10.7.16.174',
  '10.7.16.175',
  '10.7.16.176',
  '10.7.16.177',
  '10.7.16.178',
  '10.7.16.179',
  '10.7.16.180',
  '10.7.16.181',
  '10.7.16.182',
  '10.7.16.183',
  '10.7.16.184',
  '10.7.16.185',
  '10.7.16.186',
  '10.7.16.187',
  '10.7.16.188',
  '10.7.16.189',
  '10.7.16.190',
  '10.7.16.191',
  '10.7.16.192',
  '10.7.16.193'
]

nodes_datanode = [
  "10.7.16.131",
  "10.7.16.132",
  "10.7.16.133",
  "10.7.16.135",
  "10.7.16.136",
  "10.7.16.138",
  "10.7.16.139",
  "10.7.16.140",
  "10.7.16.141",
  "10.7.16.142",
  "10.7.16.143",
  "10.7.16.144",
  "10.7.16.145",
  "10.7.16.146",
  "10.7.16.147",
  "10.7.16.148",
  "10.7.16.149",
  "10.7.16.150",
  "10.7.16.151",
  "10.7.16.152",
  "10.7.16.153",
  "10.7.16.154",
  "10.7.16.155",
  "10.7.16.156",
  "10.7.16.157",
  "10.7.16.158",
  "10.7.16.159",
  "10.7.16.160",
  "10.7.16.161",
  "10.7.16.162",
  "10.7.16.163",
  "10.7.16.164",
  "10.7.16.165",
  "10.7.16.166",
  "10.7.16.167",
  "10.7.16.168",
  "10.7.16.169",
  "10.7.16.170",
  "10.7.16.171",
  "10.7.16.172",
  "10.7.16.173",
  "10.7.16.174",
  "10.7.16.175",
  "10.7.16.176",
  "10.7.16.177",
  "10.7.16.178",
  "10.7.16.179",
  "10.7.16.180",
  "10.7.16.181",
  "10.7.16.182",
  "10.7.16.183",
  "10.7.16.184",
  "10.7.16.185",
  "10.7.16.186",
  "10.7.16.187",
  "10.7.16.188",
  "10.7.16.189",
  "10.7.16.190",
  "10.7.16.191",
  "10.7.16.192",
  "10.7.16.193"
]

nodes_rstudio = [
  "10.7.16.129"
]

nodes_rsync = [
  "10.7.16.140",
  "10.7.16.143"
]

domu_error1 = [
  "10.7.16.158",
  "10.7.16.159",
  "10.7.16.160",
  "10.7.16.188",
  "10.7.16.189",
  "10.7.16.190"
]

domu_error2 = [
  #    "10.7.16.145",
  "10.7.16.155",
  "10.7.16.156",
  "10.7.16.157",
  "10.7.16.161",
  "10.7.16.162",
  "10.7.16.163"
]

domu_error = domu_error1 + domu_error2

private_net_device = "eth2"
private_net_ipmap = {
  "10.7.16.128": "192.168.2.128",
  "10.7.16.129": "192.168.2.129",
  "10.7.16.130": "192.168.2.130",
  "10.7.16.131": "192.168.2.131",
  "10.7.16.132": "192.168.2.132",
  "10.7.16.133": "192.168.2.133",
  "10.7.16.134": "192.168.2.134",
  "10.7.16.135": "192.168.2.135",
  "10.7.16.136": "192.168.2.136",
  "10.7.16.137": "192.168.2.137",
  "10.7.16.138": "192.168.2.138",
  "10.7.16.139": "192.168.2.139",
  "10.7.16.140": "192.168.2.140",
  "10.7.16.141": "192.168.2.141",
  "10.7.16.142": "192.168.2.142",
  "10.7.16.143": "192.168.2.143",
  "10.7.16.144": "192.168.2.144",
  "10.7.16.145": "192.168.2.145",
  "10.7.16.146": "192.168.2.146",
  "10.7.16.147": "192.168.2.147",
  "10.7.16.148": "192.168.2.148",
  "10.7.16.149": "192.168.2.149",
  "10.7.16.150": "192.168.2.150",
  "10.7.16.151": "192.168.2.151",
  "10.7.16.152": "192.168.2.152",
  "10.7.16.153": "192.168.2.153",
  "10.7.16.154": "192.168.2.154",
  "10.7.16.155": "192.168.2.155",
  "10.7.16.156": "192.168.2.156",
  "10.7.16.157": "192.168.2.157",
  "10.7.16.158": "192.168.2.158",
  "10.7.16.159": "192.168.2.159",
  "10.7.16.160": "192.168.2.160",
  "10.7.16.161": "192.168.2.161",
  "10.7.16.162": "192.168.2.162",
  "10.7.16.163": "192.168.2.163",
  "10.7.16.164": "192.168.2.164",
  "10.7.16.165": "192.168.2.165",
  "10.7.16.166": "192.168.2.166",
  "10.7.16.167": "192.168.2.167",
  "10.7.16.168": "192.168.2.168",
  "10.7.16.169": "192.168.2.169",
  "10.7.16.170": "192.168.2.170",
  "10.7.16.171": "192.168.2.171",
  "10.7.16.172": "192.168.2.172",
  "10.7.16.173": "192.168.2.173",
  "10.7.16.174": "192.168.2.174",
  "10.7.16.175": "192.168.2.175",
  "10.7.16.176": "192.168.2.176",
  "10.7.16.177": "192.168.2.177",
  "10.7.16.178": "192.168.2.178",
  "10.7.16.179": "192.168.2.179",
  "10.7.16.180": "192.168.2.180",
  "10.7.16.181": "192.168.2.181",
  "10.7.16.182": "192.168.2.182",
  "10.7.16.183": "192.168.2.183",
  "10.7.16.184": "192.168.2.184",
  "10.7.16.185": "192.168.2.185",
  "10.7.16.186": "192.168.2.186",
  "10.7.16.187": "192.168.2.187",
  "10.7.16.188": "192.168.2.188",
  "10.7.16.189": "192.168.2.189",
  "10.7.16.190": "192.168.2.190",
  "10.7.16.191": "192.168.2.191",
  "10.7.16.192": "192.168.2.192",
  "10.7.16.193": "192.168.2.193"
}

nodes_dom0 = [
  "10.7.16.16",
  "10.7.16.17",
  "10.7.16.18",
  "10.7.16.19",
  "10.7.16.20",
  "10.7.16.21",
  "10.7.16.22",
  "10.7.16.23",
  "10.7.16.24",
  "10.7.16.25",
  "10.7.16.26",
  "10.7.16.27",
  "10.7.16.28",
  "10.7.16.29",
  "10.7.16.30",
  "10.7.16.31",
  "10.7.16.32",
  "10.7.16.33",
  "10.7.16.34",
  "10.7.16.35",
  "10.7.16.36",
  "10.7.16.37"
]

nodes_domu = [
  '10.7.16.128',
  '10.7.16.129',
  '10.7.16.130',
  '10.7.16.131',
  '10.7.16.132',
  '10.7.16.133',
  '10.7.16.134',
  '10.7.16.135',
  '10.7.16.136',
  '10.7.16.137',
  '10.7.16.138',
  '10.7.16.139',
  '10.7.16.140',
  '10.7.16.141',
  '10.7.16.142',
  '10.7.16.143',
  '10.7.16.144',
  '10.7.16.145',
  '10.7.16.146',
  '10.7.16.147',
  '10.7.16.148',
  '10.7.16.149',
  '10.7.16.150',
  '10.7.16.151',
  '10.7.16.152',
  '10.7.16.153',
  '10.7.16.154',
  '10.7.16.155',
  '10.7.16.156',
  '10.7.16.157',
  '10.7.16.158',
  '10.7.16.159',
  '10.7.16.160',
  '10.7.16.161',
  '10.7.16.162',
  '10.7.16.163',
  '10.7.16.164',
  '10.7.16.165',
  '10.7.16.166',
  '10.7.16.167',
  '10.7.16.168',
  '10.7.16.169',
  '10.7.16.170',
  '10.7.16.171',
  '10.7.16.172',
  '10.7.16.173',
  '10.7.16.174',
  '10.7.16.175',
  '10.7.16.176',
  '10.7.16.177',
  '10.7.16.178',
  '10.7.16.179',
  '10.7.16.180',
  '10.7.16.181',
  '10.7.16.182',
  '10.7.16.183',
  '10.7.16.184',
  '10.7.16.185',
  '10.7.16.186',
  '10.7.16.187',
  '10.7.16.188',
  '10.7.16.189',
  '10.7.16.190',
  '10.7.16.191',
  '10.7.16.192',
  '10.7.16.193'
]

nodes_dom0_master = ["10.7.16.16"]

# error nodes to be reinstalled
nodes_error = [
  "10.7.16.155",
  "10.7.16.156",
  "10.7.16.157",
  "10.7.16.158",
  "10.7.16.159",
  "10.7.16.160",
  "10.7.16.161",
  "10.7.16.162",
  "10.7.16.163",
  "10.7.16.188",
  "10.7.16.189",
  "10.7.16.190"]

# making host aliases
host_alias_prefix = "clogv"
host_aliases = []
for index in range(0, len(env.hosts)):
  format_string = "%s%0" + str(len(str(len(env.hosts)))) + "d"
  host_aliases.append(format_string % (host_alias_prefix, index))

env.roledefs = {
  'all': env.hosts,
  'namenode': [env.hosts[0]], # name node, hive server, rstudio-server, mysql-server, ...
  'gateway': [env.hosts[1]], # gateway
  'hiveserver': [env.hosts[0]],
  'rstudio': nodes_rstudio, # gateway
  'rnode': nodes_datanode,
  'datanode': nodes_datanode,
  'collector': [env.hosts[2]], # collector
  'jobnode': env.hosts[2:], # all job nodes
  'lama': [env.hosts[0]],
  'rsyncdnode': nodes_rsync,
  'dom0': nodes_dom0,
  'dom0master': nodes_dom0_master,
  'domu': nodes_domu,
  'domu_error': domu_error,
  'domu_error1': domu_error1,
  'domu_error2': domu_error2,
  'nodes_error': nodes_error
}

# account information
env.user = "root"
env.password = "cloudlog"

R_rpm_names = [
  "R-devel-2.14.1-1.el5",
  "R-core-2.14.1-1.el5",
  "R-2.14.1-1.el5",
  "R-devel-2.14.1-1.el5",
  ]

# ----- begin configuration
runuser = "nexr"
runuser_password = "cloudlog"
package_base_path = "/home/%s/ndap" % runuser

config = {
  'ndap_runuser': runuser,
  'ndap_version': "ndap-1.1.0.1015",
  'RStudio_rpm_name': "rstudio-server-0.95.262-2",
  'hive_version': "hive-0.8.0-nr1004",
  'hadoop_version': "hadoop-0.20.203.0",
  'java_home_path': "/usr/lib/jvm/jre-1.6.0-openjdk.x86_64",
  'ndap_base_path': package_base_path,
  'ndap_hadoop_home_path': "%s/hadoop" % package_base_path,
  'ndap_hadoop_conf_path': "%s/hadoop/conf" % package_base_path,
  'ndap_hive_home_path': "/%s/hive" % package_base_path,
  'ndap_oozie_home_path': "%s/oozie" % package_base_path,
  'ndap_lama_home_path': "%s/ndap_lama" % package_base_path,
  'ndap_rhive_data_path': "/srv/rhive",
  'ndap_hadoop_data_path': "/srv/hdfs",
  # 'ndap_tomcat_home_path': "/home/nexr/ndap/thirdparty/apache-tomcat-7.0.26",
  'ndap_tomcat_home_path': "/home/nexr/ndap/thirdparty/tomcat",
  'ulimit_open_maxfiles': "102400",
  'additional_disk_name': "/dev/xvdb1",
  'report_directory': "./run_reports",
  'report_filename': "report.txt",
  "hadoopconf_hdfs_nodename": "clogh01",
  "hadoopconf_hdfs_port": "54310",
  # "hadoopconf_hdfs_port":"9000",
  "hadoopconf_base_path": "/srv",
  "hadoopconf_hadoop_data_path": "hdfs",
  "hadoopconf_jobtracker_nodename": "clogh01",
  # "hadoopconf_jobtracker_port":"9001",
  "hadoopconf_jobtracker_port": "54311",
  "hadoopconf_dfs.datanode.max.xcievers": "4096"
}

# ----- end configuration

_results = []

@roles('all')
@parallel
def get_private_hwaddr():
  conf_file = "/etc/sysconfig/network-scripts/ifcfg-%s" % private_net_device
  with settings(warn_only=True):
    fd = open("./hwaddr.list", "a+")
    result = run("cat %s | grep HWADDR | awk -F'=' '{print $2}'" % conf_file)
    fd.write("%s=%s\n" % (env.host, result))
    fd.close()


@roles('dom0master')
def acquire_xstools():
  xstools_file = "/opt/xensource/packages/iso/xs-tools-5.6.100.iso"
  local("if [ ! -d ./acquired_xstools ]; then mkdir -p ./acquired_xstools; fi")
  get(xstools_file, "./acquired_xstools/")


@roles('domu')
def check_xstools():
  with settings(warn_only=True):
    run("rpm -qa | grep xen")


@roles('domu')
def install_xstools():
  with settings(warn_only=True):
    xstools_file = "./acquired_xstools/xs-tools-5.6.100.iso"
    run("if [ ! -d /tmp/xstools ]; then mkdir /tmp/xstools; fi")
    # put(xstools_file, "/tmp/xstools/")
    #    local("scp %s root@%s" % (xstools_file, env.host))
    run("if [ ! -d /mnt/xs-tools ]; then mkdir /mnt/xs-tools; fi")
    result = run("df | grep xs-tools")
    if result.strip() != "":
      run("umount /mnt/xs-tools")
    run(
      "if [ ! -f /mnt/xs-tools/Linux/install.sh ]; then mount -o loop /tmp/xstools/xs-tools-5.6.100.iso /mnt/xs-tools; fi")
    run("/mnt/xs-tools/Linux/install.sh -n")


@roles('all')
def set_private_network():
  hwaddr_map = {
    "10.7.16.185": "32:9E:23:12:2D:A5",
    "10.7.16.187": "4A:69:34:BD:5C:99",
    "10.7.16.182": "52:92:B6:D7:C6:F7",
    "10.7.16.176": "7E:DF:12:1E:AB:2D",
    "10.7.16.183": "F2:58:73:64:14:19",
    "10.7.16.173": "6E:97:31:31:0F:9A",
    "10.7.16.181": "82:1C:AA:BD:9B:92",
    "10.7.16.174": "B6:BB:3E:2E:28:1E",
    "10.7.16.180": "16:E0:C0:78:3B:DD",
    "10.7.16.193": "CE:3C:38:E8:9F:A6",
    "10.7.16.177": "B2:80:A0:28:53:D2",
    "10.7.16.186": "32:E6:54:C0:52:7E",
    "10.7.16.154": "E2:3D:47:65:96:29",
    "10.7.16.192": "46:43:A4:4B:F5:91",
    "10.7.16.166": "0E:B9:19:A3:97:97",
    "10.7.16.175": "C6:99:90:FE:B0:05",
    "10.7.16.178": "86:AF:44:09:21:C6",
    "10.7.16.171": "A2:E0:67:03:E4:45",
    "10.7.16.179": "2A:B9:3E:63:51:8B",
    "10.7.16.164": "2A:D2:4A:F5:22:B3",
    "10.7.16.146": "DE:2E:6A:52:DB:F0",
    "10.7.16.168": "BE:71:BA:AF:F4:E1",
    "10.7.16.151": "22:39:D8:9D:AE:EE",
    "10.7.16.167": "66:5C:AA:4A:71:11",
    "10.7.16.169": "BE:E8:F6:DB:20:8C",
    "10.7.16.138": "1A:00:7E:E4:A8:22",
    "10.7.16.142": "16:22:55:72:1B:58",
    "10.7.16.143": "7E:A1:94:2E:32:79",
    "10.7.16.141": "62:8F:40:5A:4E:F4",
    "10.7.16.130": "A6:E7:CA:55:AA:52",
    "10.7.16.145": "F2:46:E5:26:3D:CA",
    "10.7.16.129": "E2:1D:85:62:D3:A3",
    "10.7.16.144": "6A:FB:C7:8F:D1:C6",
    "10.7.16.136": "3E:B7:74:7B:AB:30",
    "10.7.16.170": "76:68:A7:33:9D:BF",
    "10.7.16.150": "96:99:07:21:99:A6",
    "10.7.16.153": "D6:E3:F5:6F:A6:3E",
    "10.7.16.148": "F6:2D:8B:0A:D3:45",
    "10.7.16.128": "E2:DD:58:B0:1A:29",
    "10.7.16.149": "62:2C:70:14:93:EB",
    "10.7.16.172": "F2:E3:CA:F1:34:B2",
    "10.7.16.147": "62:A5:0B:EB:5F:12",
    "10.7.16.152": "5E:8E:5A:3E:0B:7A",
    "10.7.16.165": "06:64:4F:09:D7:5F",
    "10.7.16.140": "4E:5F:2F:F3:94:F8",
    "10.7.16.137": "9A:93:86:D5:E8:11",
    "10.7.16.135": "BA:D2:D2:D1:41:94",
    "10.7.16.134": "B6:86:27:F6:07:1E",
    "10.7.16.139": "EA:FA:CA:66:06:67",
    "10.7.16.184": "9A:0F:5C:DE:6E:54"
  }
  content = """# Xen Virtual Ethernet
DEVICE=%s
HWADDR=%s
HOTPLUG=no
IPADDR=%s
NETMASK=255.255.255.0
ONBOOT=yes
    """ % (private_net_device, hwaddr_map[env.host], private_net_ipmap[env.host])
  conf_file = "/etc/sysconfig/network-scripts/ifcfg-%s" % private_net_device
  with settings(warn_only=True):
  #        fd = open("./hwaddr.list", "a+")
    hwaddr = run("cat %s | grep HWADDR | awk -F'=' '{print $2}'" % conf_file)
    if hwaddr.strip() != "":
      run("echo '%s' > %s" % (content, conf_file))

#        fd.close()

@roles('all')
@parallel
def restart_eth2():
  # seq -f'192.168.2.%g' 128 193 | xargs -n 1 ping -c 1
  run("ifdown eth2")
  run("ifup eth2")


@roles('all')
@parallel
def restart_network():
  # seq -f'192.168.2.%g' 128 193 | xargs -n 1 ping -c 1
  run("/etc/init.d/network restart")


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


@roles('rnode', 'rstudio')
def check_r_version():
  """ Checking version of installed R
  This task checks if the installed R instances are assigned version
  """
  print(env.host)
  result = run("rpm -qa | grep '^R-'")
  if " ".join(sorted(R_rpm_names)) == " ".join(sorted(result.split("\r\n"))):
    print("R packages OK: --> %s" % ", ".join(sorted(result.split("\r\n"))))
  else:
    print("R packages is not matched: %s" % ", ".join(sorted(result.split("\r\n"))))
    write_error_report("error", env.host, inspect.stack()[0][3])


@roles('rnode', 'rstudio')
def check_rserve_version():
  """ Checking version of installed R
  This task checks if the installed R instances are assigned version
  """
  print(env.host)
  result = run(" R -e 'library(Rserve);sessionInfo();'| grep Rserve")


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


@roles('rnode')
@parallel
def install_r():
  """ Installing latest version of GNU-R using yum
  if the installed version of R is not latest version then it will be updated
  """
  with cd("/tmp"):
    sudo("if [ ! -d ./r_installation ]; then mkdir ./r_installation; fi")
    with cd("./r_installation"):
    #            sudo("rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-4.noarch.rpm")
      with settings(warn_only=True):
        sudo("rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm")
      sudo("yum install R R-devel -y")
    sudo("rm -Rf ./r_installation")


@roles('rnode', 'rstudio')
@parallel
def install_rserve():
  run("/usr/bin/R -e 'install.packages(\"Rserve\", repos=\"http://cran.nexr.com\");'")


@roles('rstudio')
def install_rstudio():
  """ Install Rstudio-server to the assigned host using rpm directly
  """
  rstudio_rpm = "rstudio-server-0.95.265-x86_64.rpm"
  with cd("/tmp"):
    with settings(warn_only=True):
      run("if [ ! -d ./rstudio_installation ]; then mkdir ./rstudio_installation; fi")
      with cd("./rstudio_installation"):
        run("rm -Rf *.rpm*")
        run("wget http://download2.rstudio.org/%s" % rstudio_rpm)
        run("rpm -Uvh ./%s" % rstudio_rpm)
      run("rm -Rf ./rstudio_installation")


@roles('rstudio')
def install_apache():
  pkgs = ["apr-1.3.12-1.el5.x86_64.rpm",
          "apr-devel-1.3.12-1.el5.x86_64.rpm",
          "apr-util-mysql-1.3.9-1.el5.x86_64.rpm",
          "apr-util-devel-1.3.9-1.el5.x86_64.rpm",
          "apr-util-1.3.9-1.el5.x86_64.rpm",
          "apr-util-devel-1.3.9-1.el5.x86_64.rpm",
          "apr-util-ldap-1.3.9-1.el5.x86_64.rpm",
          "httpd-devel-2.2.22-1.el5.x86_64.rpm",
          "httpd-tools-2.2.22-1.el5.x86_64.rpm"
          "httpd-2.2.22-1.el5.x86_64.rpm"]

  pkg_repository = "http://centos.alt.ru/repository/centos/5/x86_64"

  download_path = "/tmp/apache_download"
  run("if [ ! -d %s ]; then mkdir %s ;fi" % (download_path, download_path))

  with cd("/tmp/apache_download"):
    with settings(warn_only=True):
    # run("rm -f ./*.rpm")

    #    for pkg in pkgs:
    #      run("if [ -f %s]; then rm -f ./%s; fi" % (pkg, pkg))
    #      run("wget %s/%s" % (pkg_repository, pkg))
      run("rpm -e mod_perl-2.0.4-6.el5.x86_64")
      run("rpm -e php-5.1.6-32.el5.x86_64")
      run("rpm -e mod_python-3.2.8-3.1.x86_64")
      run("rpm -e mod_ssl-2.2.3-63.el5.centos.1.x86_64")
      run("rpm -e webalizer-2.01_10-30.1.x86_64")
      run("rpm -e mod_python-3.2.8-3.1.x86_64")
      run("rpm -e system-config-httpd-1.3.3.3-1.el5.noarch")
      run("rpm -e mod_ssl-2.2.3-63.el5.centos.1.x86_64")
      run("rpm -e httpd-manual-2.2.3-63.el5.centos.1.x86_64")

      run("rpm -e httpd-2.2.3-63.el5.centos.1")
      run("rpm -e apr-1.2.7-11.el5_6.5")
      run("rpm -e apr-1.2.7-11.el5_6.5")
      run("rpm -e apr-util-1.2.7-11.el5_5.2")
      run("rpm -e apr-devel-1.2.7-11.el5_6.5")
      run("rpm -e apr-util-1.2.7-11.el5_5.2")
      run("rpm -e apr-util-devel-1.2.7-11.el5_5.2")

      run("yum install db4-devel -y")
      run("yum install expat-devel -y")
      run("yum install openldap-devel -y")
      #files = map(lambda x: "./" + x, pkgs)
      #run("rpm -ivh %s" % (" ".join(files)))
      run("rpm -ivh ./*.rpm")


@roles('rstudio')
def set_openamapacheagent():
  #password = "cloudlog"
  #run("echo '%s' > /tmp/pwd.txt" % cloudlog)
  #run("/etc/init.d/httpd stop")
  pass


@roles('rstudio')
def set_rstudiosso():
  content = """
<VirtualHost *:80>
RewriteEngine On
RewriteLog "/var/log/httpd.ndap_sso4rstudio.rewrite.log"
ProxyRequests On
ProxyVia On

<Proxy *>
Allow from localhost
</Proxy>

SetEnv RSTUDIO_SSO_OPENSSO_SERVER                   http://clogv02.ktcloudlog.com:8080/opensso
SetEnv RSTUDIO_SSO_PROXY_PATH                       /rstudio
SetEnv RSTUDIO_SSO_SECURE_COOKIE_KEY_PATH           /etc/rstudio/secure-cookie-key
SetEnv RSTUDIO_SSO_CGI_SCRIPT_PATH                  /cgi-bin/ndap_sso4rstudio
SetEnv RSTUDIO_SSO_CGI_SCRIPT_ABSPATH               /var/www/cgi-bin/ndap_sso4rstudio
SetEnv RSTUDIO_SSO_COOKIE_DOMAIN                    .ktcloudlog.com
SetEnv RSTUDIO_SSO_SET_AUTO_ADDUSER                 1
SetEnv RSTUDIO_SSO_SET_DEBUG                        0

ProxyPass        /rstudio/ http://localhost:8787/
ProxyPassReverse /rstudio/ http://localhost:8787/
RedirectMatch permanent ^/rstudio$ /rstudio/

RewriteCond    %{REQUEST_URI} ^/rstudio/auth-sign-in$
RewriteRule     /rstudio/auth-sign-in     /cgi-bin/ndap_sso4rstudio/auth?p=sign-in [L,R]

RewriteCond    %{REQUEST_URI} ^/rstudio/auth-sign-out$
RewriteRule     /rstudio/auth-sign-out     /cgi-bin/ndap_sso4rstudio/auth?p=sign-out [L,R]
</VirtualHost>
  """
  run("echo '%s' > /etc/httpd/conf.d/ndap_sso4rstudio.conf" % content)
  run("chmod +r /etc/rstudio/secure-cookie-key")


@roles('rnode', 'rstudio')
@parallel
def install_rhive():
  """ Install Rstudio-server to the assigned host using rpm directly
  """
  # env.user = runuser
  rhive_package_repository = "https://github.com/downloads/nexr/RHive"
  # rhive_package_filename = "RHive_0.0-5.tar.gz"
  rhive_package_filename = "RHive_0.0-6b_20120518.tar.gz"

  with cd("/tmp"):
    result = run("/home/nexr/ndap/hadoop/bin/hadoop fs -ls /rhive")
    if result.strip() == "":
      run("/home/nexr/ndap/hadoop/bin/hadoop fs -mkdir /rhive")
      run("/home/nexr/ndap/hadoop/bin/hadoop fs -chmod 755 /rhive")

    run("/home/nexr/ndap/hadoop/bin/hadoop fs -chown nexr /rhive")

    run("if [ ! -d ./rhive_installation ]; then mkdir ./rhive_installation; fi")
    with cd("./rhive_installation"):
      run("/usr/bin/R CMD javareconf")
      run("R -e 'remove.packages(\"RHive\")'")
      run("/usr/bin/R -e 'install.packages(\"rJava\", repos=\"http://cran.nexr.com\")'")
      run("wget %s/%s" % (rhive_package_repository, rhive_package_filename))
      run("/usr/bin/R CMD INSTALL ./%s" % rhive_package_filename)
    run("rm -Rf ./rhive_installation")


@roles('rnode', 'rstudio')
def unset_r_env():
  """ Removing environment variables are related to RHive from the file '/usr/lib64/R/etc/Renviron'
  """
  #result = sudo("cat /usr/lib64/R/etc/Renviron | grep -v -E '^HADOOP_HOME=|^HIVE_HOME=|^RHIVE_DATA='")
  #new_content = result
  time_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
  run("mv /usr/lib64/R/etc/Renviron /usr/lib64/R/etc/Renviron.%s" % time_str)
  run(
    "cat /usr/lib64/R/etc/Renviron.%s | grep -v -E '^HADOOP_HOME=|^HIVE_HOME=|^RHIVE_DATA=' > /usr/lib64/R/etc/Renviron" % time_str)


@roles('rnode', 'rstudio')
@parallel
def set_r_env():
  """ Setting environment variables are related to RHive into the file '/usr/lib64/R/etc/Renviron'
  """
  unset_r_env()
  run("echo '##### RHive #####' >> /usr/lib64/R/etc/Renviron")
  run("echo 'HADOOP_HOME=%s' >> /usr/lib64/R/etc/Renviron" % config['ndap_hadoop_home_path'])
  run("echo 'HIVE_HOME=%s' >> /usr/lib64/R/etc/Renviron" % config['ndap_hive_home_path'])
  run("echo 'RHIVE_DATA=%s' >> /usr/lib64/R/etc/Renviron" % config['ndap_rhive_data_path'])


@roles('rnode', 'rstudio')
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


@roles("rnode")
def make_rhive_data_path():
  """ Checking if data path for RHive exists or not
  """
  with settings(warn_only=True):
    #if not path_exists(config['ndap_rhive_data_path']):
    #    write_error_report("error", env.host, inspect.stack()[0][3])
    run("if [ ! -d %(ndap_rhive_data_path)s ]; then mkdir -p %(ndap_rhive_data_path)s ;fi" % config)
    run("chmod -R 777 %(ndap_rhive_data_path)s" % config)
    run("chown -R nexr %(ndap_rhive_data_path)s" % config)


@roles("all")
def clear_known_hosts_runuser():
  with settings(warn_only=True):
    run("rm /home/%s/.ssh/known_hosts" % runuser)


@roles("jobnode")
def clear_rhive_data_path():
  """ Clearing data path for RHive
  """
  with settings(warn_only=True):
    run("rm -Rf %(ndap_rhive_data_path)s/*" % config)


@roles("jobnode")
def remove_rhive_data_path():
  """ Removing data path for RHive
  """
  with settings(warn_only=True):
    run("rm -Rf %(ndap_rhive_data_path)s" % config)

#def path_exists(path):
#    """ Basic function for checking existence of path
#    """
#    with settings(warn_only=True), hide("status", "stderr", "stdout"):
#        output = sudo("ls -ald %s" % path)
#        if output.failed:
#            return False
#        else:
#            return True

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


@roles("rnode")
def check_rserve_daemon():
  """ Checking port of Rserve daemon is listening
  """
  rserve_port = "6311"
  with settings(hide("stdout", "stderr", "status", "running", "warnings"), warn_only=True):
    result = run("netstat -nltp | grep '/Rserve' | awk '{print $4}' | awk -F \":\" '{print $2}'")
    if result.failed or result == "" or result != rserve_port:
      print("%s\tRserve doesn't listen on the port %s" % (red("error!"), rserve_port))
      write_error_report("error", env.host, inspect.stack()[0][3])
    else:
      print("%s\tRserve is listening on port %s" % (green("OK!"), rserve_port))


def get_port_list():
  return sudo("netstat -nltp | awk '{print $4}' | awk -F\":\" '{print $NF}' | tail -n +3")

port_map_table = {
  "50070": "webui-HDFS	Namenode",
  "50075": "webui-Datanodes",
  "50090": "webui-Secondarynamenode",
  "50105": "webui-Backup/Checkpoint node",
  "50030": "webui-MR Jobracker",
  "50060": "webui-Tasktrackers",
  "8020": "Namenode-Filesystem metadata operations.",
  "50010": "Datanode-DFS data transfer",
  "50020": "Datanode-Block metadata operations and recovery",
  "50100": "Backupnode-Same as namenode, HDFS Metadata Operations",
  "3306": "MySQL server",
  "10000": "Hive server",
  "6311": "Rserve",
  "80": "Web server(RStudio)",
  "22": "sshd",
  "9001": "JobTracker"
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


@roles("rnode")
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
def set_perm_to_srv_path_runuser():
  """ Giving permission of /srv direcotry to runuser
  """
  run("chown %s:%s /srv" % (runuser, runuser))


@roles("rsyncdnode")
@parallel
def install_rsyncd():
  """ Installing rsync daemon
  """
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
def set_time_xen():
  """ Time setting for Xen
  """
  with settings(warn_only=True):
    #run("ntpdate time.kriss.re.kr")
    # rdate -s time.bora.net
    # run("rdate -s time.bora.net")
    run("ntpdate -u time.bora.net")


@roles('all')
def set_vm_wallclock():
  """ Set wallclock for VMs
  """
  run("echo 1 > /proc/sys/xen/independent_wallclock")


@roles("all")
def set_time_sync():
  """ Time sync for VMs
  """
  with settings(warn_only=True):
    # run("ntpdate time.kriss.re.kr")
    # rdate -s time.bora.net
    # run("ntpdate -u time.bora.net")
    # run("echo 1 > /proc/sys/xen/independent_wallclock")
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
def check_time_xen():
  """ Checking current time of Xen
  """
  with settings(warn_only=True):
    #sudo("ntpdate time.kriss.re.kr")
    # rdate -s time.bora.net
    # rdate -s ntp.kornet.net
    run("date")


@roles("rnode")
@parallel
def start_rserve():
  """ Starting Rserve as a daemon
  """
  with settings(warn_only=True):
    result = sudo(
      "export LC_ALL=C && export RHIVE_DATA='/srv/rhive' && sudo -u nexr /usr/bin/R CMD Rserve > /var/log/Rserve.log")
    if result.failed:
      write_error_report("error", env.host, inspect.stack()[0][3])


@roles("rnode")
@parallel
def restart_rserve():
  """ Restarting Rserve
  """
  stop_rserve()
  start_rserve()


@roles("namenode")
def stop_hadoop():
  """ Stopping all Hadoop
  """
  with cd(rhive_hadoop_path + "/bin"):
    run("./stop-all.sh")


@roles("namenode")
def start_hadoop():
  """ Starting all Hadoop
  """
  with cd(rhive_hadoop_path + "/bin"):
    run("./start-all.sh")


@roles("namenode")
def restart_hadoop():
  """ Restarting all Hadoop
  """
  stop_hadoop()
  start_hadoop()


@roles("hiveserver")
@parallel
def stop_hiveserver():
  """ Stopping Hive-Server
  """
  with settings(warn_only=True):
    result = sudo("netstat -nltp |  grep ':::10000' | awk '{print $7}' | awk -F \"/\" '{print $1}'")
    if result != "":
      sudo("/bin/kill %s" % result)


@roles("hiveserver")
def start_hiveserver():
  """ Starting Hive-server
  """
  with cd(rhive_hive_path + "/bin"):
    run("nohup ./hive --service hiveserver > /var/log/hiveserver.log &")


@roles("hiveserver")
def restart_hiveserver():
  """ Restaring Hive-server
  """
  stop_hiveserver()
  start_hiveserver()


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
  with cd("/srv/hadoop-0.20.203.0/bin"):
    run("./hadoop namenode -format")


@roles("namenode")
def restart_hadoop_all():
  """ Restarting hadoop all services on all nodes
  """
  with cd("%s/bin" % rhive_hadoop_path):
    run("bash ./stop-all.sh")
    run("bash ./start-all.sh")


@roles('rstudio')
def restart_rstudio():
  """ Restarting RStudio-server
  """
  run("/etc/init.d/rstudio-server restart")


@roles('rstudio')
def stop_rstudio():
  """ Stopping RStudio-server
  """
  run("/etc/init.d/rstudio-server stop")


@roles('rstudio')
def start_rstudio():
  """ Starting RStudio-server
  """
  run("/etc/init.d/rstudio-server start")


@roles('lama')
def restart_lama():
  """ Restarting Lama tomcat
  """
  stop_lama()
  start_lama()


@roles('lama')
def stop_lama():
  """ Stopping Lama tomcat
  """
  with cd("/home/nexr/apache-tomcat-7.0.26/bin"):
    run("sudo -u nexr ./shutdown.sh")


@roles('lama')
def start_lama():
  """ Starting Lama tomcat
  """
  with cd("/home/nexr/apache-tomcat-7.0.26/bin"):
    run("sudo -u nexr ./startup.sh")


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
def add_system_users():
  """ Adding reserved users to hosts
  """
  # userlist = ["nexr", "hadoop", "hdfs", "mapred"]
  userlist = ["nexr"]
  default_password = "cloudlog"
  with settings(warn_only=True):
    for userid in userlist:
      result = sudo("cat /etc/passwd | grep \"^%s:\"" % userid)
      if result.strip() != "":
        print("%s exists" % userid)
      else:
        run("adduser %s" % userid)
        run("chpasswd <<< '%s:%s'" % (userid, default_password))


@roles("all")
def add_me():
  """ Adding reserved users to hosts
  """
  userid = "aiden.hong"
  default_password = "nexr4101"
  with settings(warn_only=True):
    result = sudo("cat /etc/passwd | grep \"^%s:\"" % userid)
    if result.strip() == "":
      run("adduser %s" % userid)
      run("chpasswd <<< '%s:%s'" % (userid, default_password))


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
      open("./log.result.writable", "a+").write(
        env.host + "\t" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S") + "\t" + "file system Failed\n")
      write_error_report("error", env.host, inspect.stack()[0][3])
    else:
      open("./log.result.writable", "a+").write(
        env.host + "\t" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S") + "\t" + "file system OK\n")


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
  start_rserve()
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


@roles('all')
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
  with settings(hide("status", "stdout", "stderr", "running"), warn_only=True):
    result = run("rpm -qa | grep jdk")
    print ", ".join(sorted(result.split("\n")))


@roles('all')
@parallel
def install_java():
  run("yum install %s -y" % " ".join(yum_packages["java"]))


@roles('all')
@parallel
def init_hadoopdata_path():
  # for NDAP
  # run("rm -Rf /srv/hadoopdata")
  run("mkdir /srv/hadoopdata")
  run("chown nexr /srv/hadoopdata")
  # for Hadoop default

#    run("chmod -R 777 /srv/hadoopdata")
#    run("mkdir /srv/hadoopdata/name/")
#    run("mkdir /srv/hadoopdata/data/")
#    run("mkdir /srv/hadoopdata/mapred/")
#    run("chown -R hdfs:hadoop /srv/hadoopdata/name/")
#    run("chown -R hdfs:hadoop /srv/hadoopdata/data/")
#    run("chown -R mapred:hadoop /srv/hadoopdata/mapred/")

@roles('all')
@parallel
def check_ulimit():
  env.user = "nexr"
  with settings(warn_only=True):
    result = run("ulimit -a | grep 'open files'")


@roles('all')
@parallel
def unset_ulimit_profile():
  profile_script_filename = "/etc/profile.d/ulimit.sh"
  run("rm %s" % profile_script_filename)


@roles('all')
@parallel
def set_ulimit_pam():
  profile_script_filename = "/etc/pam.d/login"
  profile_script_content = """
#%PAM-1.0
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
auth       include      system-auth
account    required     pam_nologin.so
account    include      system-auth
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    optional     pam_keyinit.so force revoke
session    required     pam_loginuid.so
session    include      system-auth
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
"""
  #run("echo '%s' > %s" % (profile_script_content, profile_script_filename))
  run("echo 'session required pam_limits.so' >> %s" % profile_script_filename)
  # session required pam_limits.so


@roles('all')
@parallel
def set_ulimit():
  profile_script_filename = "/etc/security/limits.conf"
  profile_script_content = """
# /etc/security/limits.conf
#
#Each line describes a limit for a user in the form:
#
#<domain>        <type>  <item>  <value>
#
#Where:
#<domain> can be:
#        - an user name
#        - a group name, with @group syntax
#        - the wildcard *, for default entry
#        - the wildcard %%, can be also used with %%group syntax,
#                 for maxlogin limit
#
#<type> can have the two values:
#        - "soft" for enforcing the soft limits
#        - "hard" for enforcing hard limits
#
#<item> can be one of the following:
#        - core - limits the core file size (KB)
#        - data - max data size (KB)
#        - fsize - maximum filesize (KB)
#        - memlock - max locked-in-memory address space (KB)
#        - nofile - max number of open files
#        - rss - max resident set size (KB)
#        - stack - max stack size (KB)
#        - cpu - max CPU time (MIN)
#        - nproc - max number of processes
#        - as - address space limit
#        - maxlogins - max number of logins for this user
#        - maxsyslogins - max number of logins on the system
#        - priority - the priority to run user process with
#        - locks - max number of file locks the user can hold
#        - sigpending - max number of pending signals
#        - msgqueue - max memory used by POSIX message queues (bytes)
#        - nice - max nice priority allowed to raise to
#        - rtprio - max realtime priority
#
#<domain>      <type>  <item>         <value>
#

#*               soft    core            0
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#@student        -       maxlogins       4

# End of file

# for ndap-collector
%(ndap_runuser)s    soft    nofile  %(ulimit_open_maxfiles)s
%(ndap_runuser)s    hard    nofile  %(ulimit_open_maxfiles)s
""" % config
  run("echo '%s' > %s" % (profile_script_content, profile_script_filename))

#@roles('all')
#@parallel
#def set_ulimit():
#    # " update-alternatives --display java"
#    max_files = "4096"
#
#    profile_script_filename = "/etc/profile.d/ulimit.sh"
#    profile_script_content = """
#ulimit -n %(max_files)s
#""" % {"max_files":max_files}
#    run("ulimit -n %s" % max_files)
#    run("echo '%s' > %s" % (profile_script_content, profile_script_filename))

@roles('all')
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
""" % {"hadoop_home": config['ndap_hadoop_home_path'], "hive_home": config['ndap_hive_home_path']}
  run("echo '%s' > %s" % (profile_script_content, profile_script_filename))


@roles('namenode')
@parallel
def copy_mysql_jar():
  run("cp /srv/mysql-connector-java-5.1.18-bin.jar %s/lib/" % rhive_hive_path)


@roles('all')
@parallel
def copy_event_jar():
  run("cp /home/nexr/ndap/ndap_collector/lib/collector-event-1.1.0.1003.jar /home/nexr/ndap/hadoop/lib/")
  run("cp /home/nexr/ndap/ndap_collector/lib/collector-event-1.1.0.1003.jar /home/nexr/ndap/hive/lib/")
  run("chown nexr /home/nexr/ndap/hadoop/lib/*")
  run("chown nexr /home/nexr/ndap/hive/lib/*")


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
  self.config['datetime'] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

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
  mapred_site_xml_filename = "%s/mapred-site.xml" % self.config['ndap_hadoop_conf_path']
  hdfs_site_xml_filename = "%s/hdfs-site.xml" % self.config['ndap_hadoop_conf_path']
  slaves_filename = "%s/slaves" % self.config['ndap_hadoop_conf_path']
  master_filename = "%s/master" % self.config['ndap_hadoop_conf_path']

  run(
    "if [ ! -d %(hadoopconf_base_path)s/%(hadoopconf_hadoop_data_path)s ]; then mkdir %(hadoopconf_base_path)s/%(hadoopconf_hadoop_data_path)s; fi" % self.config)

  # generating Hadoop config files
  run("echo '%s' > %s" % (core_site_xml, core_site_xml_filename))
  run("echo '%s' > %s" % (mapred_site_xml, mapred_site_xml_filename))
  run("echo '%s' > %s" % (hdfs_site_xml, hdfs_site_xml_filename))
  run("echo '%s' > %s" % (slaves, slaves_filename))
  run("echo '%s' > %s" % (master, master_filename))


@roles('rstudio', 'jobnode')
@parallel
def push_mysql_jdbc():
  put("./shipments/install/mysql-connector-java-5.1.18-bin.jar", "/home/nexr/ndap/hive/lib/")


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
        <value>file:///home/nexr/ndap/ndap_collector/lib/collector-event-1.1.0.1003.jar/</value>
    </property>

</configuration>
""" % config

  hive_conf_path = "/home/nexr/ndap/hive/conf"
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
    run(
      "cat ./hadoop.origin | sed -e 's/HADOOP_OPTS=\"$HADOOP_OPTS -jvm server $HADOOP_DATANODE_OPTS/#HADOOP_OPTS=\"$HADOOP_OPTS -jvm server $HADOOP_DATANODE_OPTS\\n    HADOOP_OPTS=\"$HADOOP_OPTS -server $HADOOP_DATANODE_OPTS/g' > ./hadoop")
    run("chmod 755 ./hadoop")


@roles('namenode')
def install_mysql():
  run("yum install mysql.x86_64 -y")
  run("yum install mysql-server.x86_64 -y")
  run("yum install mysql-devel -y")


@roles('namenode')
def set_mysql_config():
  mysql_data_dir = "/srv/mysqldata"
  run("if [ ! -d %(dir)s ]; then mkdir %(dir)s ;fi" % {"dir": mysql_data_dir})

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
  script_content = """CREATE DATABASE %(hive_database)s; USE %(hive_database)s; SOURCE %(hive_home)s/scripts/metastore/upgrade/mysql/hive-schema-0.8.0.mysql.sql;""" % {
    "hive_database": hive_database, "hive_home": rhive_hive_path}
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
  """ Pushing ssh key for root
  """
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
  """ Pushing ssh key for runuser(default 'nexr')
  """
  userhome = run("cat /etc/passwd | grep %s | awk -F':' '{print $6}'" % runuser)
  param = {"USERHOME": userhome.strip(), "RUNUSER": runuser, "ENVHOST": env.host}

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
    "10.7.16.128": "clogv01 clogv01.ktcloudlog.com",
    "10.7.16.129": "clogv02 clogv02.ktcloudlog.com",
    "10.7.16.130": "clogv03 clogv03.ktcloudlog.com",
    "10.7.16.131": "clogv04 clogv04.ktcloudlog.com",
    "10.7.16.132": "clogv05 clogv05.ktcloudlog.com",
    "10.7.16.133": "clogv06 clogv06.ktcloudlog.com",
    "10.7.16.134": "clogv07 clogv07.ktcloudlog.com",
    "10.7.16.135": "clogv08 clogv08.ktcloudlog.com",
    "10.7.16.136": "clogv09 clogv09.ktcloudlog.com",
    "10.7.16.137": "clogv10 clogv10.ktcloudlog.com",
    "10.7.16.138": "clogv11 clogv11.ktcloudlog.com",
    "10.7.16.139": "clogv12 clogv12.ktcloudlog.com",
    "10.7.16.140": "clogv13 clogv13.ktcloudlog.com",
    "10.7.16.141": "clogv14 clogv14.ktcloudlog.com",
    "10.7.16.142": "clogv15 clogv15.ktcloudlog.com",
    "10.7.16.143": "clogv16 clogv16.ktcloudlog.com",
    "10.7.16.144": "clogv17 clogv17.ktcloudlog.com",
    "10.7.16.145": "clogv18 clogv18.ktcloudlog.com",
    "10.7.16.146": "clogv19 clogv19.ktcloudlog.com",
    "10.7.16.147": "clogv20 clogv20.ktcloudlog.com",
    "10.7.16.148": "clogv21 clogv21.ktcloudlog.com",
    "10.7.16.149": "clogv22 clogv22.ktcloudlog.com",
    "10.7.16.150": "clogv23 clogv23.ktcloudlog.com",
    "10.7.16.151": "clogv24 clogv24.ktcloudlog.com",
    "10.7.16.152": "clogv25 clogv25.ktcloudlog.com",
    "10.7.16.153": "clogv26 clogv26.ktcloudlog.com",
    "10.7.16.154": "clogv27 clogv27.ktcloudlog.com",
    "10.7.16.155": "clogv28 clogv28.ktcloudlog.com",
    "10.7.16.156": "clogv29 clogv29.ktcloudlog.com",
    "10.7.16.157": "clogv30 clogv30.ktcloudlog.com",
    "10.7.16.158": "clogv31 clogv31.ktcloudlog.com",
    "10.7.16.159": "clogv32 clogv32.ktcloudlog.com",
    "10.7.16.160": "clogv33 clogv33.ktcloudlog.com",
    "10.7.16.161": "clogv34 clogv34.ktcloudlog.com",
    "10.7.16.162": "clogv35 clogv35.ktcloudlog.com",
    "10.7.16.163": "clogv36 clogv36.ktcloudlog.com",
    "10.7.16.164": "clogv37 clogv37.ktcloudlog.com",
    "10.7.16.165": "clogv38 clogv38.ktcloudlog.com",
    "10.7.16.166": "clogv39 clogv39.ktcloudlog.com",
    "10.7.16.167": "clogv40 clogv40.ktcloudlog.com",
    "10.7.16.168": "clogv41 clogv41.ktcloudlog.com",
    "10.7.16.169": "clogv42 clogv42.ktcloudlog.com",
    "10.7.16.170": "clogv43 clogv43.ktcloudlog.com",
    "10.7.16.171": "clogv44 clogv44.ktcloudlog.com",
    "10.7.16.172": "clogv45 clogv45.ktcloudlog.com",
    "10.7.16.173": "clogv46 clogv46.ktcloudlog.com",
    "10.7.16.174": "clogv47 clogv47.ktcloudlog.com",
    "10.7.16.175": "clogv48 clogv48.ktcloudlog.com",
    "10.7.16.176": "clogv49 clogv49.ktcloudlog.com",
    "10.7.16.177": "clogv50 clogv50.ktcloudlog.com",
    "10.7.16.178": "clogv51 clogv51.ktcloudlog.com",
    "10.7.16.179": "clogv52 clogv52.ktcloudlog.com",
    "10.7.16.180": "clogv53 clogv53.ktcloudlog.com",
    "10.7.16.181": "clogv54 clogv54.ktcloudlog.com",
    "10.7.16.182": "clogv55 clogv55.ktcloudlog.com",
    "10.7.16.183": "clogv56 clogv56.ktcloudlog.com",
    "10.7.16.184": "clogv57 clogv57.ktcloudlog.com",
    "10.7.16.185": "clogv58 clogv58.ktcloudlog.com",
    "10.7.16.186": "clogv59 clogv59.ktcloudlog.com",
    "10.7.16.187": "clogv60 clogv60.ktcloudlog.com",
    "10.7.16.188": "clogv61 clogv61.ktcloudlog.com",
    "10.7.16.189": "clogv62 clogv62.ktcloudlog.com",
    "10.7.16.190": "clogv63 clogv63.ktcloudlog.com",
    "10.7.16.191": "clogv64 clogv64.ktcloudlog.com",
    "10.7.16.192": "clogv65 clogv65.ktcloudlog.com",
    "10.7.16.193": "clogv66 clogv66.ktcloudlog.com"
  }

  hosts_items_private = {
    "10.7.16.128": "clogh01",
    "10.7.16.129": "clogh02",
    "10.7.16.130": "clogh03",
    "10.7.16.131": "clogh04",
    "10.7.16.132": "clogh05",
    "10.7.16.133": "clogh06",
    "10.7.16.134": "clogh07",
    "10.7.16.135": "clogh08",
    "10.7.16.136": "clogh09",
    "10.7.16.137": "clogh10",
    "10.7.16.138": "clogh11",
    "10.7.16.139": "clogh12",
    "10.7.16.140": "clogh13",
    "10.7.16.141": "clogh14",
    "10.7.16.142": "clogh15",
    "10.7.16.143": "clogh16",
    "10.7.16.144": "clogh17",
    "10.7.16.145": "clogh18",
    "10.7.16.146": "clogh19",
    "10.7.16.147": "clogh20",
    "10.7.16.148": "clogh21",
    "10.7.16.149": "clogh22",
    "10.7.16.150": "clogh23",
    "10.7.16.151": "clogh24",
    "10.7.16.152": "clogh25",
    "10.7.16.153": "clogh26",
    "10.7.16.154": "clogh27",
    "10.7.16.155": "clogh28",
    "10.7.16.156": "clogh29",
    "10.7.16.157": "clogh30",
    "10.7.16.158": "clogh31",
    "10.7.16.159": "clogh32",
    "10.7.16.160": "clogh33",
    "10.7.16.161": "clogh34",
    "10.7.16.162": "clogh35",
    "10.7.16.163": "clogh36",
    "10.7.16.164": "clogh37",
    "10.7.16.165": "clogh38",
    "10.7.16.166": "clogh39",
    "10.7.16.167": "clogh40",
    "10.7.16.168": "clogh41",
    "10.7.16.169": "clogh42",
    "10.7.16.170": "clogh43",
    "10.7.16.171": "clogh44",
    "10.7.16.172": "clogh45",
    "10.7.16.173": "clogh46",
    "10.7.16.174": "clogh47",
    "10.7.16.175": "clogh48",
    "10.7.16.176": "clogh49",
    "10.7.16.177": "clogh50",
    "10.7.16.178": "clogh51",
    "10.7.16.179": "clogh52",
    "10.7.16.180": "clogh53",
    "10.7.16.181": "clogh54",
    "10.7.16.182": "clogh55",
    "10.7.16.183": "clogh56",
    "10.7.16.184": "clogh57",
    "10.7.16.185": "clogh58",
    "10.7.16.186": "clogh59",
    "10.7.16.187": "clogh60",
    "10.7.16.188": "clogh61",
    "10.7.16.189": "clogh62",
    "10.7.16.190": "clogh63",
    "10.7.16.191": "clogh64",
    "10.7.16.192": "clogh65",
    "10.7.16.193": "clogh66"
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
  for key, item in sorted(hosts_items.items()):
    hosts_items_new.append("%s\t%s" % (key, item))

  hosts += "\n".join(hosts_items_new)
  hosts += "\n# -- private network for Hadoop cluster\n"
  hosts_items_new = []

  for key, item in sorted(hosts_items_private.items()):
    hosts_items_new.append("%s\t%s" % (key, item))

  hosts += "\n".join(hosts_items_new)

  return hosts


def check_bonding():
  """ Checking bonding channel (to be developed)
  """
  # dom0
  # /proc/net/bonding/bond0
  pass


@roles('namenode', 'datanode')
def check_ndap():
  ndap_default_path = "/home/%s/ndap" % runuser
  with settings(hide("status", "stderr", "running"), warn_only=True):
    run("if [ ! -d %s ]; then echo '!!!!! NDAP does not exist !!!!!' ;fi" % ndap_default_path)
    run("if [ ! -d %s ]; then echo '!!!!! NDAP Hadoop does not exist !!!!!' ;fi" % (ndap_default_path + "/hadoop"))


@roles('all')
def stop_firewall():
  # /etc/selinux/config
  # SELINUX=enforcing
  # SELINUX-disable
  # /usr/bin/system-config-securitylevel-tui
  with settings(warn_only=True):
    # run("if [ ps aux | grep iptables | grep -v grep -ne '' ]; then service iptables stop; fi")
    run("service iptables stop")
    run("/usr/sbin/setenforce 0")
    run("/etc/init.d/iptables stop")
    run("chkconfig iptables off")


# DFS health check
# http://node00:50070/dfshealth.jsp
@roles('all')
@parallel
def set_hosts_file():
  """ setting /etc/hosts for custom aliases
  """
  # CloudLog testbed3
  hosts_text = make_hosts(env.host)

  run("echo '%s' > /etc/hosts" % hosts_text)


@roles('all')
@parallel
def set_ssh_config():
  """ setting ssh config for root
  """
  content = """StrictHostKeyChecking=no"""
  run("echo '%s' > ~/.ssh/config" % content)


@roles('all')
@parallel
def set_ssh_config_runuser():
  """ setting ssh config for runuser
  """
  content = """StrictHostKeyChecking=no"""
  run("echo '%s' > /home/%s/.ssh/config" % (content, runuser))


@roles('all')
@parallel
def set_sudoer_runuser():
  """ Giving sudoer to runuser
  """
  content = """
# ---- CloudLog runuser
Defaults:nexr !requiretty
nexr    ALL=(ALL)       NOPASSWD: ALL
"""
  run("echo '%s' >> /etc/sudoers" % content)


@roles('rstudio')
def install_korean_fonts():
  """ Installing Korean fonts (Nanum)
  Korean fonts are necessary to plot out graphic using R
  """
  font_dic = {
    "나눔고딕에코TTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_TTF_GOTHICECO.zip",
    "나눔명조에코TTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_TTF_MYUNGJOECO.zip",
    "나눔고딕TTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip",
    "나눔명조TTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip",
    "나눔고딕라이트TTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_TTF_GOTHICLIGHT.zip",
    "나눔손글씨TTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_TTF_ALL.zip",
    "나눔고딕에코OTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_OTF_GOTHICECO.zip",
    "나눔명조에코OTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_OTF_MYUNGJOECO.zip",
    "나눔고딕OTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_OTF_ALL.zip",
    "나눔명조OTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_OTF_ALL.zip",
    "나눔고딕라이트OTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFontSetup_OTF_GOTHICLIGHT.zip",
    "나눔손글씨OTF": "http://cdn.naver.com/naver/NanumFont/fontfiles/NanumFont_OTF_ALL.zip",
    "나눔고딕코딩TTF": "http://dev.naver.com/projects/nanumfont/download/441?filename=NanumGothicCoding-2.0.zip"
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

          # Install additional fonts can be used
          # put("./shipments/fonts/KTnG_SangSang_Fonts.tar.bz2", "/usr/share/fonts/additional/")
          # sudo("tar xvfz ./KTnG_SangSang_Fonts.tar.bz2")
          # sudo("rm -f ./KTnG_SangSang_Fonts.tar.bz2")
    sudo("fc-cache -fv")


@roles("lama")
def update_lama_war():
  run("if [ ! -f /home/nexr/product/lama/update ]; then mkdir -p /home/nexr/product/lama/update; fi")
  put("./product/lama/update/ndap-lama.war", "/home/nexr/product/lama/update/")
  run("cp /home/nexr/product/lama/update/ndap-lama.war %(ndap_tomcat_home_path)s/webapps/" % config)
  run("chown %(ndap_runuser)s %(ndap_tomcat_home_path)s/webapps/" % config)


@runs_once
def obtain_meerkat():
  latest_package_list = (
    "http://143.248.160.114:8000/meerkat_dist/meerkat_backend_agent.tar.gz",
    "http://143.248.160.114:8000/meerkat_dist/meerkat_backend_server.tar.gz",
    "http://143.248.160.114:8000/meerkat_dist/meerkat_frontend.tar.gz",
    #"http://143.248.160.114:8000/meerkat_dist/meerkat_frontend_meerkat-frontend.tar.gz",
    "http://143.248.160.114:8000/meerkat_dist/meerkat_hadoop.tar.gz",
    #"http://143.248.160.114:8000/meerkat_dist/nexr-provisioning.tar.gz"
    )
  local("if [ ! -d ./product/meerkat ]; then mkdir -p ./product/meerkat; fi")
  local("rm -f ./product/meerkat/*")
  for package_url in latest_package_list:
    local("cd ./product/meerkat && wget %s" % package_url)


@hosts('localhost')
def obtain_lama():
  repository_config = {
    'host': '143.248.160.81',
    'account': 'nexr'
  }
  # repository information
  # password: rplinux1
  # current version: ndap-lama-1.1.0.1006-SNAPSHOT-bin.tar.gz

  #local("scp nexr@143.248.160.81:/home/nexr/distro/lama/*.gz ./product/lama/")
  #local("cd ./product/lama && tar xvfz *.gz")
  #local("cp ./product/lama/ndap-lama-1.1.0.1006-SNAPSHOT/ndap-lama.war ./product/lama/update/")

  #local("scp nexr@143.248.160.81:/home/nexr/nexr_platforms/ndap-lama-1.1.0.1007-SNAPSHOT-bin.tar.gz ./product/")

  local("cd ./product && tar xvfj ./ndap-lama-1.1.0.1007-SNAPSHOT-bin.tar.gz")
  '''
  nexr@tb081:~/nexr_platforms$ cat ndap-lama-1.1.0.1007-SNAPSHOT/scripts/upgrade/mysql/upgrade-1.1.0.1006-to-1.1.0.1007.mysql.sql
  ALTER TABLE lama_user ADD COLUMN sso_id VARCHAR(100) NOT NULL AFTER id;
  ALTER TABLE lama_user DROP COLUMN user_name;
  nexr@tb081:~/nexr_platforms$ mysql -udata -pdata1234 lama < ndap-lama-1.1.0.1007-SNAPSHOT/scripts/upgrade/mysql/upgrade-1.1.0.1006-to-1.1.0.1007.mysql.sql
  nexr@tb081:~/nexr_platforms$ mysql -udata -pdata1234 lama -e 'describe lama_user';
  +--------+--------------+------+-----+---------+-------+
  | Field  | Type         | Null | Key | Default | Extra |
  +--------+--------------+------+-----+---------+-------+
  | id     | int(11)      | NO   | PRI | NULL    |       |
  | sso_id | varchar(100) | NO   |     | NULL    |       |
  +--------+--------------+------+-----+---------+-------+
  nexr@tb081:~/nexr_platforms$
  '''


@roles("lama")
def update_hawk_war():
  run("if [ ! -f /home/nexr/product/hawk/update ]; then mkdir -p /home/nexr/product/hawk/update; fi")
  put("./product/hawk/update/hawk-workbench.war", "/home/nexr/product/hawk/update/")
  run("cp /home/nexr/product/hawk/update/hawk-workbench.war %(ndap_tomcat_home_path)s/webapps/" % config)
  run("chown %(ndap_runuser)s %(ndap_tomcat_home_path)s/webapps/" % config)


@hosts('localhost')
def obtain_hawk():
  # obtain repository: tb081 = nexr/rplinux1
  # current version: ndap-lama-1.1.0.1006-SNAPSHOT-bin.tar.gz
  # local("scp nexr@143.248.160.81:/home/nexr/dgkim84/hawk-workbench.war ./product/hawk/update/")
  pass


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