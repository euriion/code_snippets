#!/usr/bin/python
# -*- coding: utf-8; mode: python; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=python:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Subject: Transaction Log Reshaper
# Project: BCcard
# Description: This script is for Hive reducer to reshape nested records
#              1. split detail record to make multi group by time diff threshold
#              2. cast the first record and last record in each group to columns
#              *. totally column count are key column length + other field count * 2
# Author: Aiden Hong (aiden.hong@nexr.com, aiden.hong@kt.com)
# --[ History ] --------------------------------------------------------------
# 2013-04-19: [1.0.0] created (aiden.hong@nexr.com)
# ----------------------------------------------------------------------------
# Copyright: NexR Co., Ltd (KTcloudware)
# ============================================================================

import sys
import operator
import datetime

key_field_indices = (0,1)
input_field_length = 5
timestamp_field_index = len(key_field_indices)
time_diff_threshold = 600
timestamp_type = ('string', '%Y%m%d%H%M%S')
key_stack = [None] * len(key_field_indices)
value_buffer = []
input_field_delimiter = "\t"
output_field_delimiter = "\t"

def dispose_buffer():
  if len(value_buffer) == 1:
    return "".join((output_field_delimiter.join(value_buffer[0]), output_field_delimiter, output_field_delimiter.join([]*(input_field_length-len(key_field_indices)+1))))
  elif len(value_buffer) >= 2:
    return "".join((output_field_delimiter.join(value_buffer[0]), output_field_delimiter, output_field_delimiter.join(value_buffer[-1][len(key_field_indices):])))

for raw_line in sys.stdin:
  line = raw_line.strip()  # we may remove only '\n' in special case in the future
  if not line:
    continue
  record = line.split(input_field_delimiter)
  if len(record) != input_field_length:
    continue
  if key_stack[0] is None:
    key_stack = operator.itemgetter(*key_field_indices)(record)
    value_buffer.append(record)
  else:
    if cmp(key_stack[0:len(key_field_indices)], operator.itemgetter(*key_field_indices)(record)) == 0:
      if (datetime.datetime.strptime(record[timestamp_field_index], timestamp_type[1]) - \
          datetime.datetime.strptime(value_buffer[-1][timestamp_field_index], timestamp_type[1])).seconds > time_diff_threshold:
        print dispose_buffer()
      value_buffer.append(record)
    else:
      print dispose_buffer()
      del value_buffer[:]
      value_buffer.append(record)
      key_stack = operator.itemgetter(*key_field_indices)(record) 

if value_buffer:
  print dispose_buffer()
