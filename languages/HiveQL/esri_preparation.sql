add jar file:/home/ndap/VCRM/codes/esrilib/spatial-sdk-hadoop.jar;
add jar file:/home/ndap/VCRM/codes/esrilib/esri-geometry-api.jar;

create temporary function ST_Point as 'com.esri.hadoop.hive.ST_Point';
create temporary function ST_Contains as 'com.esri.hadoop.hive.ST_Contains';


hadoop fs -mkdir /poc/2/map_load
hadoop fs -put /home/ndap/VCRM/codes/roadtrl020.esrijson /poc/2/map_load/

--- MAKE ROAD esri table
drop table if exists road;
CREATE EXTERNAL TABLE IF NOT EXISTS road (
  FNODE_      Double,
  TNODE_      Double,
  LPOLY_      Double,
  RPOLY_      Double,
  LENGTH      Double,
  ROADTRL020   Double,
  FEATURE     String,
  NAME        String,
  STATE_FIPS  String,
  STATE       String, 
  BoundaryShape binary
)
ROW FORMAT SERDE 'com.esri.hadoop.hive.serde.JsonSerde'
STORED AS INPUTFORMAT 'com.esri.json.hadoop.EnclosedJsonInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION '/poc/2/map_load/';


drop table if exists state;
CREATE EXTERNAL TABLE IF NOT EXISTS state (
  AREA       float,
  PERIMETER  float,
  STATESP010 float,
  STATE      string,
  STATE_FIPS string,
  ORDER_ADM  float,
  MONTH_ADM  string,
  DAY_ADM    float,
  YEAR_ADM   float,
  BoundaryShape binary
)
ROW FORMAT SERDE 'com.esri.hadoop.hive.serde.JsonSerde'
STORED AS INPUTFORMAT 'com.esri.json.hadoop.EnclosedJsonInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION '/poc/2/map_state/';

select
  PERIMETER  ,
  STATESP010 ,
  STATE      ,
  STATE_FIPS ,
  ORDER_ADM  ,
  MONTH_ADM  ,
  DAY_ADM    ,
  YEAR_ADM   
  from state limit 4;

hive> desc  road ;
OK
fnode_  string  from deserializer
tnode_  string  from deserializer
lpoly_  string  from deserializer
name    string  from deserializer
rpoly_  string  from deserializer
length  string  from deserializer
roadtrl020      string  from deserializer
feature string  from deserializer
boundaryshape   binary  from deserializer

# -------------------------------
select roadtrl020 from road limit 20;

SELECT counties.name, count(*) cnt FROM counties
JOIN earthquakes
WHERE ST_Contains(counties.boundaryshape, ST_Point(earthquakes.longitude, earthquakes.latitude))
GROUP BY counties.name
ORDER BY cnt desc;

select * from vcrm_tm_gps limit 20;

desc vcrm_tm_gps;
vin     string  VIN
trip_id string  Trip Id
sequence        int     Sequence
dt      string  Datetime String
latitude        int     Latitude milliarc sec
longitude       int     Longitude milliarc sec
latitudedegree  float   Latitude degree
longitudedegree float   Longitude degree


create temporary function ST_Point as 'com.esri.hadoop.hive.ST_Point';
create temporary function ST_Contains as 'com.esri.hadoop.hive.ST_Contains';


set mapred.reduce.tasks=50 ;
set hive.exec.reducers.max=50;

select gps.vin, gps.trip_id, state.roadtrl020 
from vcrm_tm_gps gps join state 
where ST_Contains(state.boundaryshape, ST_Point(gps.longitudedegree, gps.latitudedegree))
limit 20;

-- select * from vcrm_tm_gps_w_roadid
create temporary function ST_AsBinary            as 'com.esri.hadoop.hive.ST_AsBinary';
create temporary function ST_AsGeoJSON           as 'com.esri.hadoop.hive.ST_AsGeoJson';
create temporary function ST_AsJSON              as 'com.esri.hadoop.hive.ST_AsJson';
create temporary function ST_AsText              as 'com.esri.hadoop.hive.ST_AsText';
create temporary function ST_GeomFromJSON        as 'com.esri.hadoop.hive.ST_GeomFromJson';
create temporary function ST_GeomFromGeoJSON     as 'com.esri.hadoop.hive.ST_GeomFromGeoJson';
create temporary function ST_GeomFromText        as 'com.esri.hadoop.hive.ST_GeomFromText';
create temporary function ST_GeomFromWKB         as 'com.esri.hadoop.hive.ST_GeomFromWKB';
create temporary function ST_PointFromWKB        as 'com.esri.hadoop.hive.ST_PointFromWKB';
create temporary function ST_LineFromWKB         as 'com.esri.hadoop.hive.ST_LineFromWKB';
create temporary function ST_PolyFromWKB         as 'com.esri.hadoop.hive.ST_PolyFromWKB';
create temporary function ST_MPointFromWKB       as 'com.esri.hadoop.hive.ST_MPointFromWKB';
create temporary function ST_MLineFromWKB        as 'com.esri.hadoop.hive.ST_MLineFromWKB';
create temporary function ST_MPolyFromWKB        as 'com.esri.hadoop.hive.ST_MPolyFromWKB';
create temporary function ST_GeomCollection      as 'com.esri.hadoop.hive.ST_GeomCollection';
create temporary function ST_GeometryType        as 'com.esri.hadoop.hive.ST_GeometryType';
create temporary function ST_Point               as 'com.esri.hadoop.hive.ST_Point';
create temporary function ST_PointZ              as 'com.esri.hadoop.hive.ST_PointZ';
create temporary function ST_LineString          as 'com.esri.hadoop.hive.ST_LineString';
create temporary function ST_Polygon             as 'com.esri.hadoop.hive.ST_Polygon';
create temporary function ST_MultiPoint          as 'com.esri.hadoop.hive.ST_MultiPoint';
create temporary function ST_MultiLineString     as 'com.esri.hadoop.hive.ST_MultiLineString';
create temporary function ST_MultiPolygon        as 'com.esri.hadoop.hive.ST_MultiPolygon';
create temporary function ST_SetSRID             as 'com.esri.hadoop.hive.ST_SetSRID';
create temporary function ST_SRID                as 'com.esri.hadoop.hive.ST_SRID';
create temporary function ST_IsEmpty             as 'com.esri.hadoop.hive.ST_IsEmpty';
create temporary function ST_IsSimple            as 'com.esri.hadoop.hive.ST_IsSimple';
create temporary function ST_Dimension           as 'com.esri.hadoop.hive.ST_Dimension';
create temporary function ST_X                   as 'com.esri.hadoop.hive.ST_X';
create temporary function ST_Y                   as 'com.esri.hadoop.hive.ST_Y';
create temporary function ST_MinX                as 'com.esri.hadoop.hive.ST_MinX';
create temporary function ST_MaxX                as 'com.esri.hadoop.hive.ST_MaxX';
create temporary function ST_MinY                as 'com.esri.hadoop.hive.ST_MinY';
create temporary function ST_MaxY                as 'com.esri.hadoop.hive.ST_MaxY';
create temporary function ST_IsClosed            as 'com.esri.hadoop.hive.ST_IsClosed';
create temporary function ST_IsRing              as 'com.esri.hadoop.hive.ST_IsRing';
create temporary function ST_Length              as 'com.esri.hadoop.hive.ST_Length';
create temporary function ST_GeodesicLengthWGS84 as 'com.esri.hadoop.hive.ST_GeodesicLengthWGS84';
create temporary function ST_Area                as 'com.esri.hadoop.hive.ST_Area';
create temporary function ST_Is3D                as 'com.esri.hadoop.hive.ST_Is3D';
create temporary function ST_Z                   as 'com.esri.hadoop.hive.ST_Z';
create temporary function ST_MinZ                as 'com.esri.hadoop.hive.ST_MinZ';
create temporary function ST_MaxZ                as 'com.esri.hadoop.hive.ST_MaxZ';
create temporary function ST_IsMeasured          as 'com.esri.hadoop.hive.ST_IsMeasured';
create temporary function ST_M                   as 'com.esri.hadoop.hive.ST_M';
create temporary function ST_MinM                as 'com.esri.hadoop.hive.ST_MinM';
create temporary function ST_MaxM                as 'com.esri.hadoop.hive.ST_MaxM';
create temporary function ST_CoordDim            as 'com.esri.hadoop.hive.ST_CoordDim';
create temporary function ST_NumPoints           as 'com.esri.hadoop.hive.ST_NumPoints';
create temporary function ST_PointN              as 'com.esri.hadoop.hive.ST_PointN';
create temporary function ST_StartPoint          as 'com.esri.hadoop.hive.ST_StartPoint';
create temporary function ST_EndPoint            as 'com.esri.hadoop.hive.ST_EndPoint';
create temporary function ST_ExteriorRing        as 'com.esri.hadoop.hive.ST_ExteriorRing';
create temporary function ST_NumInteriorRing     as 'com.esri.hadoop.hive.ST_NumInteriorRing';
create temporary function ST_InteriorRingN       as 'com.esri.hadoop.hive.ST_InteriorRingN';
create temporary function ST_NumGeometries       as 'com.esri.hadoop.hive.ST_NumGeometries';
create temporary function ST_GeometryN           as 'com.esri.hadoop.hive.ST_GeometryN';
create temporary function ST_Centroid            as 'com.esri.hadoop.hive.ST_Centroid';
create temporary function ST_Contains            as 'com.esri.hadoop.hive.ST_Contains';
create temporary function ST_Crosses             as 'com.esri.hadoop.hive.ST_Crosses';
create temporary function ST_Disjoint            as 'com.esri.hadoop.hive.ST_Disjoint';
create temporary function ST_EnvIntersects       as 'com.esri.hadoop.hive.ST_EnvIntersects';
create temporary function ST_Envelope            as 'com.esri.hadoop.hive.ST_Envelope';
create temporary function ST_Equals              as 'com.esri.hadoop.hive.ST_Equals';
create temporary function ST_Overlaps            as 'com.esri.hadoop.hive.ST_Overlaps';
create temporary function ST_Intersects          as 'com.esri.hadoop.hive.ST_Intersects';
create temporary function ST_Relate              as 'com.esri.hadoop.hive.ST_Relate';
create temporary function ST_Touches             as 'com.esri.hadoop.hive.ST_Touches';
create temporary function ST_Within              as 'com.esri.hadoop.hive.ST_Within';
create temporary function ST_Distance            as 'com.esri.hadoop.hive.ST_Distance';
create temporary function ST_Boundary            as 'com.esri.hadoop.hive.ST_Boundary';
create temporary function ST_Buffer              as 'com.esri.hadoop.hive.ST_Buffer';
create temporary function ST_ConvexHull          as 'com.esri.hadoop.hive.ST_ConvexHull';
create temporary function ST_Intersection        as 'com.esri.hadoop.hive.ST_Intersection';
create temporary function ST_Union               as 'com.esri.hadoop.hive.ST_Union';
create temporary function ST_Difference          as 'com.esri.hadoop.hive.ST_Difference';
create temporary function ST_SymmetricDiff       as 'com.esri.hadoop.hive.ST_SymmetricDiff';
create temporary function ST_SymDifference       as 'com.esri.hadoop.hive.ST_SymmetricDiff';

-- create temporary function ST_Aggr_Union as 'com.esri.hadoop.hive.ST_Aggr_Union';

hive> select * from vcrm_gps_sample limit 10;
OK
5NPEB4AC5DH727482       20130501150900-20130501162444   1       20130501150900  125898543       -291563029      34.971817       -80.98973
5NPEB4AC5DH727482       20130501150900-20130501162444   2       20130501150930  125898366       -291562863      34.971767       -80.989685
5NPEB4AC5DH727482       20130501150900-20130501162444   3       20130501151000  125898366       -291562863      34.971767       -80.989685
5NPEB4AC5DH727482       20130501150900-20130501162444   4       20130501151030  125899481       -291559378      34.972076       -80.988716
5NPEB4AC5DH727482       20130501150900-20130501162444   5       20130501151100  125902371       -291554922      34.97288        -80.98748
5NPEB4AC5DH727482       20130501150900-20130501162444   6       20130501151130  125887292       -291545594      34.968693       -80.984886
5NPEB4AC5DH727482       20130501150900-20130501162444   7       20130501151200  125864802       -291535321      34.962444       -80.98203
5NPEB4AC5DH727482       20130501150900-20130501162444   8       20130501151230  125836841       -291523287      34.954678       -80.97869
5NPEB4AC5DH727482       20130501150900-20130501162444   9       20130501151300  125808579       -291511094      34.946827       -80.9753
5NPEB4AC5DH727482       20130501150900-20130501162444   10      20130501151330  125781104       -291499280      34.939194       -80.97202
-- Time taken: 0.816 seconds, Fetched: 10 row(s)

-- 34.971817       -80.98973

select roadtrl020 from poc2.road r where ST_Contains(r.boundaryshape, ST_Point(34.971767, -80.989685));
select roadtrl020 from poc2.road r where ST_Contains(r.boundaryshape, ST_Point(-119.31129, 34.28605));

34.28605, -119.31129

SELECT ST_Buffer(
 ST_GeomFromText('POINT(100 90)'),
 50, 'quad_segs=8');

SELECT ST_Buffer(ST_GeomFromText('POINT(4.28605 -119.31129)', 50, 'quad_segs=8')) from poc2.road;

-- -------------------------------------------------------------------------------------------------------------
SELECT 
  v.vin, v.trip_id, v.sequence, min(ST_Distance(r.boundaryshape, ST_point(v.longitudedegree, v.latitudedegree)))
FROM poc2.road r join default.vcrm_gps_sample v
GROUP BY v.vin, v.trip_id, v.sequence;


-- -------------------------------------------------------------------------------------------------------
SELECT 
  v.vin, v.trip_id, v.sequence, min(ST_Distance(r.boundaryshape, ST_point(v.longitudedegree, v.latitudedegree)))
FROM poc2.road r join default.vcrm_gps_sample v
GROUP BY v.vin, v.trip_id, v.sequence;



-- SELECT counties.name, count(*) cnt FROM counties
-- JOIN earthquakes
-- WHERE ST_Contains(counties.boundaryshape, ST_Point(earthquakes.longitude, earthquakes.latitude))
-- GROUP BY counties.name
-- ORDER BY cnt desc;

-- state
5NPEB4AC5DH727482       20130501150900-20130501162444   1       20130501150900  125898543       -291563029      34.971817       -80.98973
5NPEB4AC5DH727482       20130501150900-20130501162444   2       20130501150930  125898366       -291562863      34.971767       -80.989685
5NPEB4AC5DH727482       20130501150900-20130501162444   3       20130501151000  125898366       -291562863      34.971767       -80.989685
5NPEB4AC5DH727482       20130501150900-20130501162444   4       20130501151030  125899481       -291559378      34.972076       -80.988716
5NPEB4AC5DH727482       20130501150900-20130501162444   5       20130501151100  125902371       -291554922      34.97288        -80.98748
5NPEB4AC5DH727482       20130501150900-20130501162444   6       20130501151130  125887292       -291545594      34.968693       -80.984886
5NPEB4AC5DH727482       20130501150900-20130501162444   7       20130501151200  125864802       -291535321      34.962444       -80.98203
5NPEB4AC5DH727482       20130501150900-20130501162444   8       20130501151230  125836841       -291523287      34.954678       -80.97869
5NPEB4AC5DH727482       20130501150900-20130501162444   9       20130501151300  125808579       -291511094      34.946827       -80.9753
5NPEB4AC5DH727482       20130501150900-20130501162444   10      20130501151330  125781104       -291499280      34.939194       -80.97202
5NPEB4AC5DH727482       20130501150900-20130501162444   11      20130501151400  125753806       -291503279      34.931614       -80.97313
5NPEB4AC5DH727482       20130501150900-20130501162444   12      20130501151430  125726145       -291517378      34.923927       -80.97705
5NPEB4AC5DH727482       20130501150900-20130501162444   13      20130501151500  125698559       -291531692      34.916267       -80.981026
5NPEB4AC5DH727482       20130501150900-20130501162444   14      20130501151530  125670999       -291546085      34.90861        -80.98502
5NPEB4AC5DH727482       20130501150900-20130501162444   15      20130501151600  125643438       -291560555      34.900955       -80.989044
5NPEB4AC5DH727482       20130501150900-20130501162444   16      20130501151630  125614592       -291577893      34.89294        -80.99386
5NPEB4AC5DH727482       20130501150900-20130501162444   17      20130501151700  125585607       -291596493      34.88489        -80.99902
5NPEB4AC5DH727482       20130501150900-20130501162444   18      20130501151730  125554523       -291606163      34.876255       -81.00171
5NPEB4AC5DH727482       20130501150900-20130501162444   19      20130501151800  125524534       -291613622      34.867928       -81.003784
5NPEB4AC5DH727482       20130501150900-20130501162444   20      20130501151830  125494117       -291624320      34.859478       -81.00675


select v.vin, v.trip_id, s.state_fips
from state s join default.vcrm_gps_sample v
where ST_Contains(s.boundaryshape, ST_Point(v.longitudedegree, v.latitudedegree))
GROUP BY v.vin, v.trip_id, s.state_fips
limit 20;

select s.state, count(*) cnt 
from state s join default.vcrm_gps_sample v
where ST_Contains(s.boundaryshape, ST_Point(v.longitudedegree, v.latitudedegree))
GROUP BY s.state
limit 30;



select s.state_fips, s.state
from state s
where ST_Contains(s.boundaryshape, ST_Point(-81.00675, 34.859478));

