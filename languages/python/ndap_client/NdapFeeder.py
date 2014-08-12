# -*- coding: utf-8; mode: bash; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=bash:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Description: NdapFeeder class
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

from NdapClient import *
import yaml
from operator import itemgetter
import re

class NdapFeeder(object):
  """
  Ndap Feeder
  """

  def __init__(self):
    """
    Constructor
    """
    self.config = None
    self._config_filename = None

  @property
  def config_filename(self):
    """
    Getting filename oof config
    @return:
    """
    return self._config_filename

  @config_filename.setter
  def config_filename(self, config_filename):
    """
    Setting filename of config
    @param config_filename: filename of a config
    """
    if not os.path.exists(config_filename):
      raise Exception("the config file '%s' does not exist" % config_filename)

    try:
      self._config_filename = config_filename
      self.config = yaml.load(open(self._config_filename).read())
    except:
      raise

    return

  def make_hive_table_scheme(self, database_name, table_name):
    """
    Making scheme to make hive table
    @param database_name:
    @param table_name:
    @return: DDL scheme string
    @raise:
    """
    import pprint

    if not self.config.has_key('databases'):
      raise Exception("config does not have 'databases' property")

    if not self.config['databases'].has_key(database_name):
      raise Exception("the databases '%s' does not exist in config" % database_name)

    if not self.config['databases'][database_name].has_key('tables'):
      raise Exception("config does not have 'tables' property")

    if not self.config['databases'][database_name]['tables'].has_key(table_name):
      raise Exception("the table '%s' does not exist in config" % table_name)

    important_properties = ('file_type', 'location', 'external', 'fields', 'partition_keys')

    for property in important_properties:
      if not self.config['databases'][database_name]['tables'][table_name].has_key(property):
        raise Exception("configuration does not have the property '%s'" % property)

    table_config = self.config['databases'][database_name]['tables'][table_name]
    ddl_config = {}
    ddl_config['database_name'] = database_name
    ddl_config['table_name'] = table_name
    ddl_config['file_type'] = table_config['file_type'].upper()
    ddl_config['external'] = table_config['external']
    ddl_config['externality'] = 'EXTERNAL ' if table_config['external'] else ''
    ddl_config['field_delimiter'] = table_config['field_delimiter']
    ddl_config['line_delimiter'] = table_config['line_delimiter']
    ddl_config['location'] = table_config['location']

    field_scheme = ", \n".join((field_line for field_line in (' '.join((item.upper() for item in field)) for field in table_config['fields'])))
    partition_scheme = ", ".join((field_line for field_line in (' '.join((field[0], field[1].upper())) for field in table_config['partition_keys'])))
    ddl_config['field_scheme'] = field_scheme
    ddl_config['partition_scheme'] = partition_scheme

    pprint.pprint(table_config)

    ddl_scheme = """CREATE %(externality)sTABLE %(database_name)s.%(table_name)s (
%(field_scheme)s
) PARTITIONED BY (%(partition_scheme)s)
ROW FORMAT
DELIMITED FIELDS TERMINATED BY '%(field_delimiter)s'
LINES TERMINATED BY '%(line_delimiter)s'
STORED AS %(file_type)s
LOCATION '%(location)s'""" % ddl_config
    return ddl_scheme

  def feed(self, database_name):
    """
    Feeding
    @param database_name: Database name to feed
    """
    ndap_client = NdapClient()
    ndap_client.hadoop.hadoop_home = self.config['hadoop']['home_path']
    ndap_client.hive.connect(self.config['hive']['server']['ipaddress'], self.config['hive']['server']['port'])
    ndap_client.hive.open()

    for table_name in self.config['databases'][database_name]['tables'].keys():
      if not self.config['databases'][database_name]['tables'][table_name]['feed']['enable']:
        print "%s is skipped" % table_name
        continue

      if not ndap_client.hive.table_exists(database_name, table_name):
        ddl_sql = self.make_hive_table_scheme(database_name, table_name)
        print "-- Creating table '%s' --" % table_name
        print ddl_sql
        print "-" * 50
        ndap_client.hadoop.hdfs.mkdir(self.config['databases'][database_name]['tables'][table_name]['location'])
        ndap_client.hive.query(ddl_sql)
      else:
        if self.config['databases'][database_name]['tables'][table_name]['feed']['overwrite']:
          ndap_client.hive.drop_table(database_name, table_name, False)
          ddl_sql = self.make_hive_table_scheme(database_name, table_name)
          print "-- Creating table '%s' --" % table_name
          print ddl_sql
          print "-" * 50
          ndap_client.hadoop.hdfs.mkdir(self.config['databases'][database_name]['tables'][table_name]['location'])
          ndap_client.hive.query(ddl_sql)
        else:
          print "table '%s' already exists in database '%s'" % (table_name, database_name)

      table_config = self.config['databases'][database_name]['tables'][table_name]
      filename_list = []
      local_dir = table_config['local_dir']
      re_filename = re.compile(table_config['pattern_feed_filename'])

      for filename in os.listdir(local_dir):
        if re_filename.match(filename):
          groups = re_filename.findall(filename)
          filename_list.append(groups[0])
        else:
          print "unknown filename format: %s" % filename

      filename_list = sorted(filename_list, key=itemgetter(0,1,2))
      template_feed_filename = table_config['template_feed_filename']
      remote_base_dir = table_config['location']

      for filename_group in filename_list:
        year = filename_group[0]
        month = filename_group[1]
        day = filename_group[2]

        param = {'year':year, 'month':month, 'day': day}

        upload_dir = "%s/%s/%s/%s" % (remote_base_dir, year, month, day)
        local_file = "%s/%s" % (local_dir, template_feed_filename % param)

        if not os.path.exists(local_file):
          raise Exception("the local file '%s' does not exists" % local_file)

        remote_filename = "%s/%s" % (upload_dir, template_feed_filename % param)

        # making new partition value set
        new_partition_values = []
        for partition_key, partition_key_type, partition_key_param in table_config['partition_keys']:
          new_partition_values.append(partition_key_param % param)

        partitions = ndap_client.hive.get_partitions(database_name, table_name)
        partition_values = tuple(tuple(partition.values) for partition in partitions)

        if new_partition_values in partition_values:
          print "Partition values '(%s)' already exist in the table ''" % (', '.join(new_partition_values), table_name)
        else:
          print "Putting the file '%s' into '%s'" % (local_file, upload_dir)

          if ndap_client.hadoop.hdfs.hdfs_exists(remote_filename):
            ndap_client.hadoop.hdfs.hdfs_remove(remote_filename)

          if not ndap_client.hadoop.hdfs.hdfs_exists(upload_dir):
            ndap_client.hadoop.hdfs.mkdir(upload_dir)
            print "making HDFS directory '%s'" % upload_dir

          put_result = ndap_client.hadoop.hdfs.hdfs_put(local_file, upload_dir)

          ndap_client.hive.add_partition(database_name, table_name, new_partition_values, upload_dir)

          if not put_result:
            raise Exception("Upload failure: %s -> %s" % (local_file, upload_dir))

    ndap_client.hive.close()
    return


if __name__ == '__main__':
  print "This module can not be run alone!"
