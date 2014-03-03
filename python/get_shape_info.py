#!/usr/bin/python
#!/usr/bin/python
# -*- coding: utf-8; mode: bash; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
# vim:fenc=utf-8:ft=bash:et:sw=2:ts=2:sts=2:fdm=marker
# ============================================================================
# Description: HKMC Telematics geo mapping mapper
# Maintainer: Aiden Hong (aiden.hong@nexr.com)
# Copyright: KTNexR, KTcloudware
# --[ Version ] --------------------------------------------------------------
# 2013-06-07: [1.0.0] create
# 2013-06-13: [1.0.1] revise code to get field name
# -----------------------------------------------------------------------------
# Copyright by KTNexR. all rights reserved.
# DO NOU USE! without the right of using
# ============================================================================
# -*- coding: utf-8 -*-
import sys
import os
from osgeo import ogr
from shapely.geometry import Point
from shapely.geometry import Polygon
from shapely.wkb import loads
import osgeo.ogr as ogr


from shapely import speedups
speedups.enable()

shapeFilename = sys.argv[1]
print "input filename: %s" % shapeFilename
shapeHandle = ogr.Open(shapeFilename)
numLayers = shapeHandle.GetLayerCount()
for layerNum in range(numLayers):
  layer = shapeHandle.GetLayer(layerNum)
  if layer.GetFeatureCount() > 0:
    print "layer: %s, features: %s" % (layer.GetName(), layer.GetFeatureCount())
# for i in range(layer.GetFeatureCount()):
#   feature = layer.GetFeature(i)
#   print feature.keys()

feature = layer.GetFeature(0)
print feature.keys()
