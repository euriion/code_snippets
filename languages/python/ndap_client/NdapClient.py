# -*- coding: utf-8; mode: bash; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=bash:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Description: NdapClient class
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

import sys
sys.path.append('./hivethrift')
import os
import commands
import time
from hive_service import *
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from hive_metastore.ttypes import *
import hive_service
import hive_metastore


class NdapHiveClient(object):
  """
  NDAP Hive Client
  """
  hive_transport = None
  hive_protocol = None
  hive_client = None

  def __init__(self):
    """
    Constructor
    """
    self._hadoop_home = None
    self._hadoop_bin = None

  def connect(self, hive_server_address, hive_server_port):
    """
    Making connection to Hive
    @param hive_server_address:
    @param hive_server_port:
    """
    self.hive_transport = TSocket.TSocket(hive_server_address, hive_server_port)
    self.hive_transport = TTransport.TBufferedTransport(self.hive_transport)
    self.hive_protocol = TBinaryProtocol.TBinaryProtocol(self.hive_transport)
    self.hive_client = ThriftHive.Client(self.hive_protocol)
    return

  def open(self):
    """
    Opening connection
    @return:
    """
    return self.hive_transport.open()

  def close(self):
    """
    Closing connection
    """
    return self.hive_transport.close()

  def database_exists(self, database_name):
    """
    Checking if the database exists
    @param database_name: database name
    @return: Boolean
    """
    database = None

    try:
      database = self.hive_client.get_database(database_name)
    except hive_metastore.ttypes.NoSuchObjectException:
      return False

    if database.name == database_name:
      result = True
    else:
      result = False

    return result

  def use_database(self, database_name):
    """
    Setting database to use
    @param database_name: database name
    @return: Boolean
    """
    if self.database_exists(database_name):
      command = "USE %s" % database_name
      try:
        self.hive_client.execute(command)
      except hive_service.ttypes.HiveServerException:
        return False
    else:
      return False

    return True

  def old_add_partition(self, database_name, table_name, partition, path):
    """
    ** DEPRECATED **
    @param database_name:
    @param table_name:
    @param partition:
    @param path:
    @raise:
    """
    command = "ALTER TABLE %s ADD PARTITION (%s) LOCATION '%s'" % (table_name, partition, path)
    try:
      self.hive_client.execute(command)
#    except Thrift.TException, tx:
#      print '%s' % (tx.message)
    except:
      raise Exception("can not run the command: \n%s" % command)

  def add_partition(self, database_name, table_name, partition_values, partition_location):
    """
    Adding a partition to table
    @param database_name: database name
    @param table_name: table name
    @param partition_values: values to provide to partition
    @param partition_location: location to provide to partition
    @return: None
    """
    table = self.hive_client.get_table(database_name, table_name)

    new_sd = StorageDescriptor(
      outputFormat=table.sd.outputFormat,
      sortCols=[],
      inputFormat=table.sd.inputFormat,
      cols=table.sd.cols,
      compressed=table.sd.compressed,
      bucketCols=table.sd.bucketCols,
      numBuckets=table.sd.numBuckets,
      parameters=table.sd.parameters,
      serdeInfo=table.sd.serdeInfo,
      #      location="hdfs://nlogDEV03:9000/nstep/dev/rawdata/CUST_INFO_INQR_LOG_INFO/%s/%s/%s" % partition_values
      location=partition_location
    )

    new_partition = hive_metastore.ttypes.Partition(
      values=partition_values,
      dbName=database_name,
      tableName=table_name,
      createTime=time.time(),
      lastAccessTime=time.time(),
      sd=new_sd)

    self.hive_client.add_partition(new_partition)
    return

  def drop_table(self, database_name, table_name, delete_data):
    """
    Deleting table
    @param database_name: database name
    @param table_name: table name
    @param delete_data: boolean value to assign if physical data should be deleted or not
    @raise: where hive_client is not set
    """
    if self.hive_client is None:
      raise Exception('Hive client is not initialized')

    self.hive_client.drop_table(database_name, table_name, delete_data)
    return True

  def table_exists(self, database_name, table_name):
    """
    Checking if table exiss
    @param database_name: database name
    @param table_name: table name
    @return: Boolean
    @raise: When hive_client is not set
    """
    if self.hive_client is None:
      raise Exception('Hive client is not initialized')

    table_list = self.hive_client.get_all_tables(database_name)
    table_list = (table_name.upper() for table_name in table_list)
    table_name_list = (x.name for x in table_list)

    return table_name.upper() in table_list

  def get_partitions(self, database_name, table_name):
    """
    Get partitions which are in a table
    @param database_name: database name
    @param table_name: table name
    @return: partition records
    @raise: where hive_client is not set
    """
    if self.hive_client is None:
      raise Exception('Hive client is not initialized')

    max_parts = 9999
    partitions = self.hive_client.get_partitions(database_name, table_name, max_parts)

    return partitions

  def query(self, query):
    """
    Executing query
    @param query: A query string to execute
    @return: None
    @raise: where Hive client is not set
    """
    if self.hive_client is None:
      raise Exception('Hive client has not been initialized')

    self.hive_client.execute(query)
    return


class NdapHadoopClient(object):
  """
  NDAP Hadoop client
  """
  def __init__(self):
    """
    Constructor
    """
    self._hadoop_home = None
    self._hadoop_bin = None
    self.hdfs = NdapHdfsClient()

  @property
  def hadoop_home(self):
    """
    Getting hadoop_home
    @return: a hadoop_home
    """
    return self._hadoop_home

  @hadoop_home.setter
  def hadoop_home(self, path):
    """
    Setting hadoop_home
    @param path: a path to use as hadoop_home
    @raise: where the path does not exist
    """
    if not os.path.exists(path):
      raise Exception("Hadoop home '%s' does not exists" % path)

    self._hadoop_home = path
    self.hdfs.hadoop_home = self._hadoop_home

  @property
  def hadoop_bin(self):
    """
    Getting hadoop_bin
    """
    return self._hadoop_bin

  @hadoop_bin.setter
  def hadoop_bin(self, path):
    """
    Setting hadoop_bin
    @param path: a path to use as hadoop_bin
    @raise: where the path does not exist
    """
    if not os.path.exists(path):
      raise Exception("Hadoop home '%s' does not exists" % path)

    self._hadoop_bin = path
    self.hdfs.hadoop_bin = self._hadoop_bin


class NdapHdfsClient(object):
  """
  NDAP HDFS client
  """

  def __init__(self):
    """
    Constructor
    """
    self._hadoop_home = None
    self._hadoop_bin = None

  @property
  def hadoop_home(self):
    """
    Getting hadoop_home
    @return: hadoop_home
    """
    return self._hadoop_home

  @hadoop_home.setter
  def hadoop_home(self, path):
    """
    Setting hadoop_home
    @param path: The path to use as hadoop home
    @raise: where the path does not exists
    """
    if not os.path.exists(path):
      raise Exception("Hadoop home '%s' does not exists" % path)

    self._hadoop_home = path
    self.hadoop_bin = self._hadoop_home + "/bin/hadoop"

  @property
  def hadoop_bin(self):
    """
    Getting hadoop_bin
    @return: the path of current hadoop_bin
    """
    return self._hadoop_bin

  @hadoop_bin.setter
  def hadoop_bin(self, path):
    """
    Setting directory of hadoop binary file is located
    @param path: the path to use
    @raise: where the path does not exist
    """
    if not os.path.exists(path):
      raise Exception("Hadoop home '%s' does not exists" % path)

    self._hadoop_bin = path

  def mkdir(self, directory):
    """
    Making directory
    @param directory: The directory string to make
    @return: result from hadoop_bin
    """
    command = "%s fs -mkdir %s" % (self._hadoop_bin, directory)
    result, output = commands.getstatusoutput(command)

    return result

  def hdfs_exists(self, directory):
    """
    Checking if the HDFS exist
    @param directory: a HDFS directory
    @return: Boolean
    """
    command = "%s fs -ls %s" % (self._hadoop_bin, directory)
    result, output = commands.getstatusoutput(command)

    if result == 0:
      return True
    else:
      return False

  def hdfs_put(self, filename, hdfs_directory):
    """
    Upload a file into HDFS
    @param filename: filename to upload
    @param hdfs_directory: HDFS directory to upload file
    @return: Boolean
    """
    command = "%s fs -put %s %s" % (self._hadoop_bin, filename, hdfs_directory)
    result, output = commands.getstatusoutput(command)

    if result == 0:
      return True
    else:
      return False

  def hdfs_remove(self, hdfs_filename):
    """
    Removing a file on HDFS
    @param hdfs_filename: a filename on HDFS
    @return: Boolean
    """
    command = "%s fs -rm %s" % (self._hadoop_bin, hdfs_filename)
    result, output = commands.getstatusoutput(command)

    if result == 0:
      return True
    else:
      return False


class NdapClient(object):
  """
  NDAP client class
  """

  def __init__(self):
    """
    Constructor
    """
    self.hadoop = NdapHadoopClient()
    self.hive = NdapHiveClient()
    self._hadoop_bin = None
    self._hadoop_home = None

  @property
  def hadoop_home(self):
    """
    Getting hadoop_home
    @return: return the hadoop_home
    """
    return self._hadoop_home

  @hadoop_home.setter
  def hadoop_home(self, path):
    """
    Setting hadoop_home
    @param path: path to use as hadoop_home
    @return:
    """
    self.hadoop._hadoop_home = path
    return

  @property
  def hadoop_bin(self):
    """
    Getting hadoop_bin
    @return: hadoop_bin
    """
    return self._hadoop_bin

  @hadoop_bin.setter
  def hadoop_bin(self, path):
    """
    Setting hadoop-bin
    @param path: a path to ues to hadoop_bin
    """
    self._hadoop_bin = path


if __name__ == '__main__':
  print "This module can not be run alone!"
