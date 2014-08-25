# -*- coding: utf-8; mode: bash; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=bash:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Description: DictLoader class
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

import unittest

class DictLoader:
  def __init__(self, filename, key_column=0, delimiter='|'):
    """
    Constructor
    @param filename:  filename to load
    @param key_column: key column no to use as a key
    @param delimiter: delimiter fo split
    @return: DictLoader
    """
    self._filename = filename
    self._key_column = key_column
    self._dict = {}
    self._delimiter = delimiter

  def load(self):
    with open(self._filename, 'rb') as csv_file:
      for raw_line in csv_file.readlines():
        row = raw_line.strip().split(self._delimiter)
        self._dict[row[self._key_column]] = row

    return self._dict


class TestDictLoader(unittest.TestCase):
  def setUp(self):
    pass
  def tearDown(self):
    pass
