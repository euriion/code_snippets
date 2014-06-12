# -*- coding: utf-8 -*-
# /home/aiden.hong/kostat_census_2012/BND_UA_PG.shp
# /home/aiden.hong/kostat_census_2012/BAS_CNTR_LS.shp
# /home/aiden.hong/kostat_census_2012/BAS_ROAD_PG.shp
# /home/aiden.hong/kostat_census_2012/BND_MA_RS_PG.shp
# /home/aiden.hong/kostat_census_2012/BND_SIGUNGU_PG.shp
# /home/aiden.hong/kostat_census_2012/bas_sub_gate_pt.shp
# /home/aiden.hong/kostat_census_2012/srv_bas_rail_ctrl_ls.shp
# /home/aiden.hong/kostat_census_2012/BND_TOTAL_OA_PG.shp
# /home/aiden.hong/kostat_census_2012/bas_road_etc_ls.shp
# /home/aiden.hong/kostat_census_2012/BND_SIDO_PG.shp
# /home/aiden.hong/kostat_census_2012/BAS_STATION_PG.shp
# /home/aiden.hong/kostat_census_2012/BAS_RIVER_PG.shp
# /home/aiden.hong/kostat_census_2012/BND_ADM_DONG_PG.shp
# /home/aiden.hong/kostat_census_2012/BND_MA_RD_PG.shp
# /home/aiden.hong/kostat_census_2012/BAS_CNTR_PG.shp

from osgeo import ogr
from shapely.geometry import Point
from shapely.geometry import Polygon
from shapely.wkb import loads
# import shapefile
# shapeFilename = "/home/aiden.hong/kostat_census_2012/BND_SIGUNGU_PG.shp"
shapeFilename = "./states.shp"
# records = sf.records("./states.dbf")

import osgeo.ogr as ogr
shapeHandle = ogr.Open(shapeFilename)
numLayers = shapeHandle.GetLayerCount()
for layerNum in range(numLayers):
    layer = shapeHandle.GetLayer(layerNum)
    if layer.GetFeatureCount() > 0:
        print 'layer: %s, features: %s' % (layer.GetName(), layer.GetFeatureCount())

for i in range(layer.GetFeatureCount()):
   feature = layer.GetFeature(i)
   # feature.GetName()
   print(feature)

layer = shapeHandle.GetLayerByName("states")
shpIndex = 0
for element in layer:
  geom = loads(element.GetGeometryRef().ExportToWkb())
  point = Point(33.43, 112.02)
  # if geom.contains(point):
  if point.within(geom) == True:
    print geom
  else:
    # print records[shpIndex]
    break
  # records[]
  # else:
  #   print "not found"
  shpIndex += 1


# ============================================================
# import json
# from shapely import shape, Point

# # load GeoJSON file containing sectors
# with ('sectors.json', 'r') as f:
#     js = json.load(f)
# # construct point based on lat/long returned by geocoder
# point = Point(45.4519896, -122.7924463)

# geojson example
# # check each polygon to see if it contains the point
# for feature in js['features']:
#     polygon = shape(feature['geometry'])
#     if polygon.contains(point):
#         print 'Found containing polygon:', feature


