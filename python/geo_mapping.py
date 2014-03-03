#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os
from osgeo import ogr
from shapely.geometry import Point
from shapely.geometry import Polygon
from shapely.wkb import loads
import osgeo.ogr as ogr
from shapely.prepared import prep
from shapely import speedups
speedups.enable()

def prepareShape(shapeHandle, layerName, preparedGeoms):
  layer = shapeHandle.GetLayerByName(layerName)
  for i in range(layer.GetFeatureCount()):
    feature = layer.GetFeature(i)
    geom = loads(feature.GetGeometryRef().ExportToWkb())
    p = prep(geom)
    preparedGeoms.append(p)
  return (layer)

def getStateValueFromShape(preparedGeoms, layer, fieldName, longitude, latitude):
  shpIndex = 0
  value = r'\N'
  geomLength = len(preparedGeoms)
  point = Point(longitude, latitude)
  for i in range(0, geomLength):
    if preparedGeoms[i].contains(point):
      value = layer.GetFeature(i).GetField(fieldName)
      break
  return (value)

def getRoadValueFromShape(preparedGeoms, layer, fieldName, stateId, stateFieldName, longitude, latitude):
  shpIndex = 0
  geomLength = len(preparedGeoms)
  point = Point(longitude, latitude)
  minDistance = None
  minValue = None

  for i in range(layer.GetFeatureCount()):
    feature = layer.GetFeature(i)
    geom = loads(feature.GetGeometryRef().ExportToWkb())
    state = feature.GetField(stateFieldName)
    if state != stateId:
      continue
    #distance = geom.project(point)
    distance = geom.distance(point)
    if minDistance == None:
      minDistance = distance
      minValue = feature.GetField(fieldName)
    elif minDistance > distance:
      minDistance = distance
      minValue = feature.GetField(fieldName)
  return (minValue, minDistance)

if __name__ == '__main__':
  gpsColumnName = (
    "vin",
    "trip_id",
    "sequence",
    "dt",
    "latitude",
    "longitude",
    "latitudedegree",
    "longitudedegree"
  )

  stateShapeFilename = "statep010.shp"
  roadShapeFilename = "roadtrl020.shp"

  if not os.path.exists(stateShapeFilename):
    sys.stderr.write("Shapefile %s not found\n" % stateShapeFilename)
    sys.exit(1)

  if not os.path.exists(roadShapeFilename):
    sys.stderr.write("Shapefile %s not found\n" % stateShaproadShapeFilenameeFilename)
    sys.exit(1)

  stateLayerName = "statep010"
  stateFieldName = "STATE_FIPS"
  roadLayerName = "roadtrl020"
  roadFieldName = "ROADTRL020"
  delimiter = "\t"
  statePrepGeoms = []
  stateShapeHandle = ogr.Open(stateShapeFilename)
  stateLayer = prepareShape(stateShapeHandle, stateLayerName, statePrepGeoms)
  roadPrepGeoms = []
  roadShapeHandle = ogr.Open(roadShapeFilename)
  roadLayer = prepareShape(roadShapeHandle, roadLayerName, roadPrepGeoms)

  print "prepared!"

  for line in sys.stdin:
    line = line.strip()
    if line == "":
      continue
    fields = line.split(delimiter)
    lon = float(fields[gpsColumnName.index('longitudedegree')])
    lat = float(fields[gpsColumnName.index('latitudedegree')])
    stateFips = getStateValueFromShape(statePrepGeoms, stateLayer, stateFieldName, lon, lat)
    # roadId, distance = getRoadValueFromShape(roadPrepGeoms, roadLayer, roadFieldName, stateFips, "STATE_FIPS", lon, lat)
    fields.append(stateFips)
    # fields.append(str(roadId))
    # fields.append(str(distance))
    sys.stdout.write(delimiter.join(fields) + "\n")
  sys.stdout.flush()

