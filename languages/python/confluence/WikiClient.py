# -*- coding: utf-8; mode: bash; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=bash:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Description: Wiki client
# Maintainer: Aiden Hong (aiden.hong@nexr.com)
# Copyright: NexR Co., Ltd (KTcloudware)
# --[ Version ] --------------------------------------------------------------
# 2012-11-17: [1.0.0] initialize (aiden.hong@nexr.com)
# ============================================================================
__author__ = "Aiden Hong"
__copyright__ = "Copyright 2012, NexR co., Ltd"
__credits__ = ["Aiden Hong"]
__license__ = "internal"
__maintainer__ = "Aiden Hong"
__email__ = "aiden.hong@nexr.com"
__status__ = "devel"
__version__ = 1,0,0
__date__ = "Dec 12 2012"

import sqlalchemy
from sqlalchemy import *
from sqlalchemy.schema import *
from sqlalchemy.orm import *
import sys
from optparse import OptionParser
import pprint
import SOAPpy


from optparse import OptionParser
import getpass

class ConfluenceAPI:
  """Confluence API class
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

  def get_page(self, page_id):
    """
    Getting page content
    @param page_id:
    @return:
    """
    return self.server.getPage(self.token, SOAPpy.Types.longType(long(page_id)))

  def get_pages(self, space_id):
    """
    Getting all pages in a space
    @param space_id:
    @return:
    """
    return self.server.getPages(self.token, space_id)

  def store_page(self, page):
    """
    Storing a page
    @param page:
    @return:
    """
    return self.server.storePage(self.token, page)


class WikiManager:
  """
  Wiki manager
  """

  _confluence_api = None
  token = None

  def __init__(self):
    """
    Constructor
    """
    self._confluence_api = ConfluenceAPI()

  def connect(self, wsdl_url):
    """
    Connecting to wiki
    @param wsdl_url:
    """
    self._confluence_api.connect(wsdl_url)

  def login(self, username, password):
    """
    Logging on a wiki
    @param username: user name
    @param password: password
    @return: boolean
    """
    self.token = self._confluence_api.login(username, password)
    return self.token

  def get_page(self, page_id):
    """
    Getting page
    @param page_id:
    @return:
    """
    return self._confluence_api.get_page(page_id)

  def store_page(self, page):
    """
    Storing page
    @param page:
    @return:
    """
    return self._confluence_api.store_page(page)


def update_confluence(userid, password, content):
  wiki_manager = WikiManager()
  wsdl_url = "https://wiki.ktcloudware.com/rpc/soap-axis/confluenceservice-v1?wsdl"
  wiki_manager.connect(wsdl_url)
  wiki_manager.login(userid, password)
  page_id = 21734118L
  page = wiki_manager.get_page(page_id)

  content = "{info}draft version 0.1{info}\n\n" +\
            content +\
            "\n{color:#ff0000}*This page was automatically updated. DO NOT CHANGE manually*{color}"
  content = content.decode("UTF-8")
  new_page = {}
  new_page["id"] = SOAPpy.Types.longType(page.id)
  new_page["space"] = SOAPpy.Types.stringType(page.space)
  new_page["title"] = SOAPpy.Types.stringType(page.title)
  new_page["version"] = SOAPpy.Types.intType(int(page.version))
  new_page["parentId"] = SOAPpy.Types.intType(page.parentId)
  new_page["content"] = SOAPpy.Types.stringType(content)

  wiki_manager.store_page(new_page)


def make_markdown_report():
  connection_info = """
## MySQL environment information
* **IP address**: 192.168.5.226
* **port**: 3306
* **User**: hkmc
* **password**: hmc1234
* **database**: hkmc
"""
  connection_info_conflu = """
h3. MySQL environment information
* *IP address*: 192.168.5.226
* *port*: 3306
* *User*: hkmc
* *password*: hmc1234
* *database*: hkmc
"""

  table_list = """
## Table list
| Table name | DDL link | Description |
| ---------- | -------- | ----------- |
"""

  table_list_conflu = """
h4. Table list
|| Table name || DDL link || Description ||
"""

  table_desc = ""
  table_desc_conflu = ""

  for temp_table in table_object_list:
    table_list += "| %s | https://github.com/nexr/HMC-SensorLog/blob/master/prototype/db/ddl.%s.sql | %s |\n" % (temp_table.name, temp_table.name, temp_table.__doc__)
    table_list_conflu += "| %s | https://github.com/nexr/HMC-SensorLog/blob/master/prototype/db/ddl.%s.sql | %s |\n" % (temp_table.name, temp_table.name, temp_table.__doc__)

    table_desc += """
## Table: %s (%s)
| Field name | Type | Description |
| ---------- | ---- | ----------- |
""" % (temp_table.name, temp_table.__doc__)
    table_desc_conflu += """
h4. Table: {color:blue}%s{color} (%s)
|| Field name || Type || Description ||
""" % (temp_table.name, temp_table.__doc__)
    for temp_column in temp_table.columns:
      table_desc += "| %s | %s | %s |\n" % (temp_column.name, temp_column.type, temp_column.doc)
      table_desc_conflu += "| %s | %s | %s |\n" % (temp_column.name, temp_column.type, temp_column.doc)

    table_desc += "\n\n"
    table_desc_conflu += "\n\n"

  content = "%s\n%s\n%s" % (connection_info, table_list, table_desc)
  open("./README.md", 'w').write(content + "\n")

  wiki_content = "%s\n%s\n%s" % (connection_info_conflu, table_list_conflu, table_desc_conflu)
  open("./confluence.txt", 'w').write(wiki_content + "\n")

  print "README.md file is generated"
  return(wiki_content)


if __name__ == "__main__":
  usage = "usage: \n%prog -u confluence_username\n\nExam: \n%prog -u aiden.hong"
  parser = OptionParser(usage=usage)
  parser.add_option("-u", "--user",
    dest="userid",
    help="UserID for Confluence")

  (options, args) = parser.parse_args()

  if not options.userid:
    parser.error("Confluence User ID must be supplied")
    sys.exit(1)

  password = getpass.getpass(prompt="Confluence Password for %s" % options.userid)
  if password.strip() == "":
    parser.print_usage()

  wiki_content = make_markdown_report()
  update_confluence(options.userid, password, wiki_content)