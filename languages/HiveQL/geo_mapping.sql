add file /data1/vcrm_geo/POC01-4/USA/State/statep010.dbf;
add file /data1/vcrm_geo/POC01-4/USA/State/statep010.prj;
add file /data1/vcrm_geo/POC01-4/USA/State/statep010.sbn;
add file /data1/vcrm_geo/POC01-4/USA/State/statep010.sbx;
add file /data1/vcrm_geo/POC01-4/USA/State/statep010.shp;
add file /data1/vcrm_geo/POC01-4/USA/State/statep010.shx;
add file /data1/vcrm_geo/POC01-4/USA/roads/roadtrl020.dbf;
add file /data1/vcrm_geo/POC01-4/USA/roads/roadtrl020.met;
add file /data1/vcrm_geo/POC01-4/USA/roads/roadtrl020.shp;
add file /data1/vcrm_geo/POC01-4/USA/roads/roadtrl020.shx;
add file /home/ndap/VCRM/codes/geomapping/geo_mapping.py;

INSERT OVERWRITE TABLE vcrm_gps_sample_state 
SELECT *
FROM (
  FROM vcrm_gps_sample v
  MAP v.vin, v.trip_id, v.sequence, v.dt, v.latitude, v.longitude, v.latitudedegree, v.longitudedegree
  USING '/usr/bin/python ./geo_mapping.py'
  AS vin, trip_id, sequence, dt, latitude, longitude, latitudedegree, longitudedegree, state
) map_output
;