# -*- coding: utf-8; mode: bash; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=bash:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Description: TimeTaking logging class
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

import time


class TimeTaken:
  def __init__(self):
    self._durations = []
    self.start()
    self.records = {}

  def start(self, **kwargs):
    if kwargs.has_key('name'):
      self.records[kwargs['name']] = {'start':time.time()}
    else:
      self._start_time = time.time()

  def end(self, **kwargs):
    if kwargs.has_key('name'):
      self.records[kwargs['name']]['end'] = time.time()
      self.records[kwargs['name']]['duration'] = self.records[kwargs['name']]['end'] - self.records[kwargs['name']]['start']
    else:
      self._end_time = time.time()
      self._duration = self._end_time - self._start_times
      self.print_duration()

  def print_duration(self, **kwargs):
    if kwargs.has_key('name'):
      print "time taken (%s): %s" % (kwargs.has_key('name'), self.records[kwargs['name']]['duration'])
    else:
      print "time taken: %s" % self._duration

  def restart(self):
    self.end()
    self.start()


if __name__ == '__main__':
  print "This module can not be run alone!"
