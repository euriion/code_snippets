# -*- coding: utf-8; mode: bash; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=bash:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Description: Jira client
# Maintainer: Aiden Hong (aiden.hong@nexr.com)
# Copyright: NexR Co., Ltd (KTcloudware)
# --[ Version ] --------------------------------------------------------------
# 2012-11-17: [1.0.0] initialize (aiden.hong@nexr.com)
# ============================================================================
__author__ = "Aiden Hong"
__copyright__ = "Copyright 2013, NexR co., Ltd"
__credits__ = ["Aiden Hong"]
__license__ = "internal"
__maintainer__ = "Aiden Hong"
__email__ = "aiden.hong@nexr.com"
__status__ = "devel"
__version__ = 1,0,0
__date__ = "Apr 24 2013"

# import sqlalchemy
# from sqlalchemy import *
# from sqlalchemy.schema import *
# from sqlalchemy.orm import *
import sys
from optparse import OptionParser
import pprint
import SOAPpy
import json

from optparse import OptionParser
import getpass

class JiraAPI:
  """Jira API class
  """
  token = None
  server = None
  wsdl = None
  wsdl_url = None

  def connect(self, wsdl_url):
    """
    Connecting to wiki
    @param wsdl_url: WSDL
    """
    self.wsdl_url = wsdl_url
    self.server = SOAPpy.SOAPProxy(self.wsdl_url)
    self.wsdl = SOAPpy.WSDL.Proxy(self.wsdl_url)

  def login(self, username, password):
    """
    Log on to wiki
    @param username:
    @param password:
    @return:
    """
    self.token = self.server.login(username,password)
    return self.token

  def getGroup(self, group_name):
    """
    Getting page content
    @param page_id:
    @return:
    """
    return self.server.getGroup(self.token, SOAPpy.Types.stringType(group_name))


class JiraClient:
  """
  Wiki manager
  """

  _jira_api = None
  token = None

  def __init__(self):
    """
    Constructor
    """
    self._jira_api = JiraAPI()

  def connect(self, wsdl_url):
    """
    Connecting to wiki
    @param wsdl_url:
    """
    self._jira_api.connect(wsdl_url)

  def login(self, username, password):
    """
    Logging on a wiki
    @param username: user name
    @param password: password
    @return: boolean
    """
    self.token = self._jira_api.login(username, password)
    return self.token

  def getGroup(self, group_name):
    """
    Getting page
    @param page_id:
    @return:
    """
    return self._jira_api.getGroup(group_name)


if __name__ == "__main__":
  usage = "usage: \n%prog -u jira_username\n\nExam: \n%prog -u aiden.hong"
  parser = OptionParser(usage=usage)
  parser.add_option("-u", "--user",
    dest="userid",
    help="UserID to connect to Jira")

  parser.add_option("-c", "--command",
    dest="command",
    help="Command")

  parser.add_option("-p", "--param",
    dest="param",
    help="Parameter for command")

  (options, args) = parser.parse_args()

  if not options.userid:
    parser.error("Jira User ID must be supplied")
    sys.exit(1)

  password = "qa-jira$#@!"
  if password is None:
    password = getpass.getpass(prompt="Jira Password for %s" % options.userid)
    if password.strip() == "":
      parser.print_usage()

  jira_client = JiraClient()
  wsdl_url = "https://jira.ktcloudware.com/rpc/soap/jirasoapservice-v2?wsdl"
  jira_client.connect(wsdl_url)
  jira_client.login(options.userid, password)

  if options.command == "group":
    group_name = 'jira-users'
    if options.param is not None:
      group_name = options.param.decode("utf-8")
    remote_group = jira_client.getGroup(group_name)
    print "group name: %s" % remote_group.name
    user_list = []
    for user in remote_group.users:
      user_list.append((user.name, user.fullname, user.email))
    open("./users.json",'w').write(json.dumps(user_list, indent=2))


