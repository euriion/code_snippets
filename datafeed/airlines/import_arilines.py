#!/usr/local/bin/python
# -*- coding: utf-8; mode: python; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=bash:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Subject: Getting Airlines Data
# Author: Seonghak Hong (euriion@gmail.com)
# 
# --[ History ] --------------------------------------------------------------
# 2013-045-19: [1.0.0] created (euriion@gmail.com)
# 
# ----------------------------------------------------------------------------
# Copyright: Seonghak Hong (euriion@gmail.com)
# ============================================================================
import sys
import os
import getpass
from optparse import OptionParser
import re
import time


class BigdataEnvironment(object):
  _hive_home = None
  _hive_exec = None
  _hadoop_home = None
  _hadoop_exec = None
  def __init__(self):
    if os.environ.has_key("HADOOP_HOME"):
      self._hive_home = os.environ["HIVE_HOME"]
      if os.path.exists(self._hive_home + "/bin") and os.path.exists(self._hive_home + "/bin/hive"):
        self._hive_exec = os.path.exists(self._hive_home + "/bin/hive")
    if os.environ.has_key("HIVE_HOME"):
      self._hadoop_home = os.environ["HADOOP_HOME"]
      if os.path.exists(self._hadoop_home + "/bin") and os.path.exists(self._hadoop_home + "/bin/hadoop"):
        self._hadoop_exec = os.path.exists(self._hadoop_home + "/bin/hadoop")
  def isAvailable(self):
    if self._hive_home and self._hive_exec and self._hadoop_home and self._hadoop_exec:
      return(True)
    else:
      return(False)

class ImportingAirlines(object):
  def checkDatabase(self, database_name):
    

if __name__ == '__main__':
  usage = "usage: \n%prog --d database-name -t table-name \n\nExam: \n%prog -d airlines -t airlines"
  parser = OptionParser(usage=usage)
  parser.add_option("-d", "--database",
    dest="database_name",
    help="A database name to store data")
  parser.add_option("-t", "--table",
    dest="table_name",
    help="A table name to map with the data")

  (options, args) = parser.parse_args()

  bigdataEnv = BigdataEnvironment()
  if not bigdataEnv.isAvailable():
    parser.error("\n".join((
      "The environment variables HADOOP_HOME and HIVE_HOME should be assigned", 
      "hadoop and hive executable files also should be loacated in $HADOOP_HOME/bin and $HIVE_HOME/bin",
      "Please check you environment")))


  # if not options.baseurl:
  #   parser.error("Base URL of Confluence must be provided")
  #   sys.exit(1)

  # if not options.userid:
  #   parser.error("Confluence User ID must be provided")
  #   sys.exit(1)


  # password = getpass.getpass(prompt="password of %s to connect %s: " % (options.userid, options.baseurl))
  # if password.strip() == "":
  #   parser.print_usage()

  # confluence_prober = ConfluenceProber()
  # confluence_prober.setBaseUrl(options.baseurl)
  # confluence_prober.login(options.userid, password)

  # userid_list = confluence_prober.get_all_users()
  # for userid in userid_list:
  #   print ("Following '%s'..." % userid)
  #   confluence_prober.follow_user(userid)
  # print "Total users: %d" % len(userid_list)

