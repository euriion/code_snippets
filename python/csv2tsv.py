#!/usr/bin/python
# -*- coding: utf-8; mode: bash; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=bash:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Description: HKMC CSV to TSV
# Maintainer: Aiden Hong (aiden.hong@nexr.com)
# Copyright: NexR Co., Ltd (KTcloudware)
# --[ Version ] --------------------------------------------------------------
# 2013-06-06: [1.0.0] initialize (aiden.hong@nexr.com)
# -----------------------------------------------------------------------------
# Copyright by KTNexR. all rights reserved.
# DO NOU USE! this is just for HKMC PoC
# ============================================================================
import sys
import csv
if len(sys.argv) != 3:
  print "Error! Insufficient arguments"
  print "csv2tsv.py: Converting CSV file to TSV(flat) file"
  print "Usage %s input-filename.csv output-filename.tsv" % sys.argv[0]
  sys.exit(1)
fd = open(sys.argv[2], 'w')
with open(sys.argv[1], 'rb') as csvfile:
  csvReader = csv.reader(csvfile, delimiter=',', quotechar='"')
  for row in csvReader:
    fd.write('\t'.join(row) + "\n")
fd.close()
