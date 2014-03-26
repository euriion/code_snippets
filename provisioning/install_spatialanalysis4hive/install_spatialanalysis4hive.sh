#!/bin/bash

# installing prerequsite packages
sudo yum install -y git gdal

curl -L https://github.com/paramiko/paramiko/archive/master.zip -o ./paramiko.zip
unzip ./paramiko.zip
cd paramiko-master
sudo python setup.py install
cd ..

OLDPWD=`pwd`
git clone https://github.com/Esri/spatial-framework-for-hadoop
git clone https://github.com/Esri/geometry-api-java
git clone https://github.com/Esri/gis-tools-for-hadoop.git

if [[ ! -d ~/.m2/ ]]; then
  mkdir ~/.m2
fi

if [[ ! -e ~/.m2/settings.xml ]]; then
echo "
<settings>
  <profiles>
    <profile>
      <id>custom_profile</id>
      <repositories>
        <repository>
          <id>DataNucleus_Repos2</id>
          <name>DataNucleus Repository</name>
          <url>http://www.datanucleus.org/downloads/maven2</url>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <id>DataNucleus_2</id>
          <url>http://www.datanucleus.org/downloads/maven2/</url>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>

  <activeProfiles>
    <activeProfile>custom_profile</activeProfile>
  </activeProfiles>
</settings>
" > ~/.m2/settings.xml
else
  echo "~/.m2/settings.xml file already exists"
  echo "You need to modify the file settings.xml in .m2 drecitor to get jdo2.api using Maven"
fi

# <project ... xmlns:artifact="antlib:org.apache.maven.artifact.ant">
#   ...
#   <path id="maven-ant-tasks.classpath" path="lib/maven-ant-tasks-2.1.4-SNAPSHOT.jar" />
#   <typedef resource="org/apache/maven/artifact/ant/antlib.xml"
#            uri="antlib:org.apache.maven.artifact.ant"
#            classpathref="maven-ant-tasks.classpath" />
#   ...
# </project>

# <project name="antlibtest" default="doEcho">
#     <taskdef resource="svntask.properties"/>

#     <target name="doEcho">
#         <echo message="Hello World!"/>
#         <echo message="ANT_HOME=${ant.home}"/>
#         <echo message="classpath=${java.class.path}"/>
#     </target>
# </project>
# 
# http://apache.tt.co.kr/maven/ant-tasks/2.1.3/binaries/maven-ant-tasks-2.1.3.jar

export JAVA_HOME=/home/ndap/ndap/modules/java
export PATH=/home/ndap/ndap/modules/java/bin:$PATH

export M2_HOME=/home/ndap/provisioning/install_spatialanalysis4hive/apache-maven-3.0.5
export M2=$M2_HOME/bin 
export PATH=$M2:$PATH 

export ANT_HOME=/home/ndap/provisioning/install_spatialanalysis4hive/apache-ant-1.9.0
export PATH=$ANT_HOME/bin:$PATH

curl -o ./apache-maven-3.0.5-bin.tar.gz -L http://mirror.olnevhost.net/pub/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz
tar xvfz apache-maven-3.0.5-bin.tar.gz


if [[ ! -d ~/.ant/lib ]]; then
  echo "Making ~/.ant/lib"
  mkdir -p ~/.ant/lib
fi



http://mirror.apache-kr.org/maven/ant-tasks/2.1.3/source/maven-ant-tasks-2.1.3-src.zip

curl -o ./apache-ant-1.9.0-bin.tar.gz -L http://apache.mirror.cdnetworks.com//ant/binaries/apache-ant-1.9.0-bin.tar.gz
tar xvfz apache-ant-1.9.0-bin.tar.gz

if [[ -e ~/.ant/lib/maven-ant-tasks-2.1.3.jar ]]; then
  echo "Cleaning up ~/.ant/lib/maven-ant-tasks-2.1.3.jar"
  rm ~/.ant/lib/maven-ant-tasks-2.1.3.jar
fi

# wget http://apache.tt.co.kr/maven/ant-tasks/2.1.3/binaries/maven-ant-tasks-2.1.3.jar -P ~/.ant/lib/maven-ant-tasks-2.1.3.jar
curl -o ~/.ant/lib/maven-ant-tasks-2.1.3.jar -L http://apache.tt.co.kr/maven/ant-tasks/2.1.3/binaries/maven-ant-tasks-2.1.3.jar

mvn dependency:resolve

cd geometry-api-java
/home/ndap/provisioning/install_spatialanalysis4hive/apache-ant-1.9.0/bin/ant
cd ..
cd spatial-framework-for-hadoop
/home/ndap/provisioning/install_spatialanalysis4hive/apache-ant-1.9.0/bin/ant
cd hive
/home/ndap/provisioning/install_spatialanalysis4hive/apache-ant-1.9.0/bin/ant
cd ../json
/home/ndap/provisioning/install_spatialanalysis4hive/apache-ant-1.9.0/bin/ant
cd ..

cd $OLDPWD
echo " == Done! == "

#
# /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/hive/spatial-sdk-hive.jar
add jar /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/hive/spatial-sdk-hive.jar;
add jar /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/json/spatial-sdk-json.jar;
add jar /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/spatial-sdk-hadoop.jar;

create temporary function ST_AsBinary as 'com.esri.hadoop.hive.ST_AsBinary';
create temporary function ST_AsGeoJSON as 'com.esri.hadoop.hive.ST_AsGeoJson';
create temporary function ST_AsJSON as 'com.esri.hadoop.hive.ST_AsJson';
create temporary function ST_AsText as 'com.esri.hadoop.hive.ST_AsText';
create temporary function ST_GeomFromJSON as 'com.esri.hadoop.hive.ST_GeomFromJson';
create temporary function ST_GeomFromGeoJSON as 'com.esri.hadoop.hive.ST_GeomFromGeoJson';
create temporary function ST_GeomFromText as 'com.esri.hadoop.hive.ST_GeomFromText';
create temporary function ST_GeomFromWKB as 'com.esri.hadoop.hive.ST_GeomFromWKB';
create temporary function ST_PointFromWKB as 'com.esri.hadoop.hive.ST_PointFromWKB';
create temporary function ST_LineFromWKB as 'com.esri.hadoop.hive.ST_LineFromWKB';
create temporary function ST_PolyFromWKB as 'com.esri.hadoop.hive.ST_PolyFromWKB';
create temporary function ST_MPointFromWKB as 'com.esri.hadoop.hive.ST_MPointFromWKB';
create temporary function ST_MLineFromWKB as 'com.esri.hadoop.hive.ST_MLineFromWKB';
create temporary function ST_MPolyFromWKB as 'com.esri.hadoop.hive.ST_MPolyFromWKB';
create temporary function ST_GeomCollection as 'com.esri.hadoop.hive.ST_GeomCollection';

create temporary function ST_GeometryType as 'com.esri.hadoop.hive.ST_GeometryType';

create temporary function ST_Point as 'com.esri.hadoop.hive.ST_Point';
create temporary function ST_PointZ as 'com.esri.hadoop.hive.ST_PointZ';
create temporary function ST_LineString as 'com.esri.hadoop.hive.ST_LineString';
create temporary function ST_Polygon as 'com.esri.hadoop.hive.ST_Polygon';

create temporary function ST_MultiPoint as 'com.esri.hadoop.hive.ST_MultiPoint';
create temporary function ST_MultiLineString as 'com.esri.hadoop.hive.ST_MultiLineString';
create temporary function ST_MultiPolygon as 'com.esri.hadoop.hive.ST_MultiPolygon';

create temporary function ST_SetSRID as 'com.esri.hadoop.hive.ST_SetSRID';

create temporary function ST_SRID as 'com.esri.hadoop.hive.ST_SRID';
create temporary function ST_IsEmpty as 'com.esri.hadoop.hive.ST_IsEmpty';
create temporary function ST_IsSimple as 'com.esri.hadoop.hive.ST_IsSimple';
create temporary function ST_Dimension as 'com.esri.hadoop.hive.ST_Dimension';
create temporary function ST_X as 'com.esri.hadoop.hive.ST_X';
create temporary function ST_Y as 'com.esri.hadoop.hive.ST_Y';
create temporary function ST_MinX as 'com.esri.hadoop.hive.ST_MinX';
create temporary function ST_MaxX as 'com.esri.hadoop.hive.ST_MaxX';
create temporary function ST_MinY as 'com.esri.hadoop.hive.ST_MinY';
create temporary function ST_MaxY as 'com.esri.hadoop.hive.ST_MaxY';
create temporary function ST_IsClosed as 'com.esri.hadoop.hive.ST_IsClosed';
create temporary function ST_IsRing as 'com.esri.hadoop.hive.ST_IsRing';
create temporary function ST_Length as 'com.esri.hadoop.hive.ST_Length';
create temporary function ST_GeodesicLengthWGS84 as 'com.esri.hadoop.hive.ST_GeodesicLengthWGS84';
create temporary function ST_Area as 'com.esri.hadoop.hive.ST_Area';
create temporary function ST_Is3D as 'com.esri.hadoop.hive.ST_Is3D';
create temporary function ST_Z as 'com.esri.hadoop.hive.ST_Z';
create temporary function ST_MinZ as 'com.esri.hadoop.hive.ST_MinZ';
create temporary function ST_MaxZ as 'com.esri.hadoop.hive.ST_MaxZ';
create temporary function ST_IsMeasured as 'com.esri.hadoop.hive.ST_IsMeasured';
create temporary function ST_M as 'com.esri.hadoop.hive.ST_M';
create temporary function ST_MinM as 'com.esri.hadoop.hive.ST_MinM';
create temporary function ST_MaxM as 'com.esri.hadoop.hive.ST_MaxM';
create temporary function ST_CoordDim as 'com.esri.hadoop.hive.ST_CoordDim';
create temporary function ST_NumPoints as 'com.esri.hadoop.hive.ST_NumPoints';
create temporary function ST_PointN as 'com.esri.hadoop.hive.ST_PointN';
create temporary function ST_StartPoint as 'com.esri.hadoop.hive.ST_StartPoint';
create temporary function ST_EndPoint as 'com.esri.hadoop.hive.ST_EndPoint';
create temporary function ST_ExteriorRing as 'com.esri.hadoop.hive.ST_ExteriorRing';
create temporary function ST_NumInteriorRing as 'com.esri.hadoop.hive.ST_NumInteriorRing';
create temporary function ST_InteriorRingN as 'com.esri.hadoop.hive.ST_InteriorRingN';
create temporary function ST_NumGeometries as 'com.esri.hadoop.hive.ST_NumGeometries';
create temporary function ST_GeometryN as 'com.esri.hadoop.hive.ST_GeometryN';
create temporary function ST_Centroid as 'com.esri.hadoop.hive.ST_Centroid';

create temporary function ST_Contains as 'com.esri.hadoop.hive.ST_Contains';
create temporary function ST_Crosses as 'com.esri.hadoop.hive.ST_Crosses';
create temporary function ST_Disjoint as 'com.esri.hadoop.hive.ST_Disjoint';
create temporary function ST_EnvIntersects as 'com.esri.hadoop.hive.ST_EnvIntersects';
create temporary function ST_Envelope as 'com.esri.hadoop.hive.ST_Envelope';
create temporary function ST_Equals as 'com.esri.hadoop.hive.ST_Equals';
create temporary function ST_Overlaps as 'com.esri.hadoop.hive.ST_Overlaps';
create temporary function ST_Intersects as 'com.esri.hadoop.hive.ST_Intersects';
create temporary function ST_Relate as 'com.esri.hadoop.hive.ST_Relate';
create temporary function ST_Touches as 'com.esri.hadoop.hive.ST_Touches';
create temporary function ST_Within as 'com.esri.hadoop.hive.ST_Within';

create temporary function ST_Distance as 'com.esri.hadoop.hive.ST_Distance';
create temporary function ST_Boundary as 'com.esri.hadoop.hive.ST_Boundary';
create temporary function ST_Buffer as 'com.esri.hadoop.hive.ST_Buffer';
create temporary function ST_ConvexHull as 'com.esri.hadoop.hive.ST_ConvexHull';
create temporary function ST_Intersection as 'com.esri.hadoop.hive.ST_Intersection';
create temporary function ST_Union as 'com.esri.hadoop.hive.ST_Union';
create temporary function ST_Difference as 'com.esri.hadoop.hive.ST_Difference';
create temporary function ST_SymmetricDiff as 'com.esri.hadoop.hive.ST_SymmetricDiff';
create temporary function ST_SymDifference as 'com.esri.hadoop.hive.ST_SymmetricDiff';

create temporary function ST_Aggr_Union as 'com.esri.hadoop.hive.ST_Aggr_Union';

# https://github.com/Esri/gis-tools-for-hadoop/tree/master/samples

# https://github.com/Esri/gis-tools-for-hadoop/tree/master/samples/data/counties-data
wget https://raw.github.com/Esri/gis-tools-for-hadoop/master/samples/data/counties-data/california-counties.json
wget https://raw.github.com/Esri/gis-tools-for-hadoop/raw/master/samples/data/earthquake-data/earthquakes.csv
hadoop fs -mkdir /spatial/counties
hadoop fs -mkdir /spatial/earthquakes

# https://github.com/Esri/gis-tools-for-hadoop/tree/master/samples/point-in-polygon-aggregation-hive

hadoop fs -put ./california-counties.json /spatial/counties
hadoop fs -put ./earthquakes.csv /spatial/earthquakes/

add jar /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/hive/spatial-sdk-hive.jar;
add jar /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/hive/spatial-sdk-hive.jar;


# --- sample.sql ---
add jar /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/lib/esri-geometry-api.jar;
add jar /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/spatial-sdk-hadoop.jar;

create temporary function ST_Point as 'com.esri.hadoop.hive.ST_Point';
create temporary function ST_Contains as 'com.esri.hadoop.hive.ST_Contains';

drop table earthquakes;
CREATE EXTERNAL TABLE IF NOT EXISTS earthquakes (earthquake_date STRING, latitude DOUBLE, longitude DOUBLE, magnitude DOUBLE)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/spatial/earthquakes';

drop table counties;
CREATE EXTERNAL TABLE IF NOT EXISTS counties (
  Area string, 
  Perimeter string, 
  State string, 
  County string, 
  Name string, 
  BoundaryShape binary)                                         
ROW FORMAT SERDE 'com.esri.hadoop.hive.serde.JsonSerde'              
STORED AS INPUTFORMAT 'com.esri.json.hadoop.EnclosedJsonInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION '/spatial/counties'; 

# -------------------------------------------------------------------------------

select * from earthquakes limit 100;
select * from counties limit 100;
SELECT counties.name FROM counties limit 100;

SELECT counties.name, count(*) cnt FROM counties
JOIN earthquakes
WHERE ST_Contains(counties.boundaryshape, ST_Point(earthquakes.longitude, earthquakes.latitude))
GROUP BY counties.name
ORDER BY cnt desc;

# -------------------------------------------------------------------------------

# CREATE EXTERNAL TABLE IF NOT EXISTS counties (Name string, BoundaryShape binary)                                         
# ROW FORMAT SERDE 'com.esri.hadoop.hive.serde.JsonSerde'              
# STORED AS INPUTFORMAT 'com.esri.json.hadoop.EnclosedJsonInputFormat'
# OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
# LOCATION '/spatial/counties/'
# ;

# CREATE EXTERNAL TABLE IF NOT EXISTS earthquakes (
#     generated int,
#     url string,
#     title string,
#     api string,
#     count int, 
#     BoundaryShape binary
# )
# ROW FORMAT SERDE 'com.esri.hadoop.hive.serde.JsonSerde'              
# STORED AS INPUTFORMAT 'com.esri.json.hadoop.EnclosedJsonInputFormat'
# OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
# LOCATION '/spatial/earthquakes/'
# ;

# -------------------------------------------------------------------------------

SELECT counties.name, count(*) cnt FROM counties
JOIN earthquakes
WHERE ST_Contains(counties.boundaryshape, ST_Point(earthquakes.longitude, earthquakes.latitude))
GROUP BY counties.name
ORDER BY cnt desc;

# -------------------------------------------------------------------------------

SELECT counties.name, count(*) cnt FROM counties
GROUP BY counties.name;

# -------------------------------------------------------------------------------
# 
# # https://github.com/Esri/gis-tools-for-hadoop/blob/master/samples/point-in-polygon-aggregation-mr/cmd/run-sample.sh

# map/reduce example
# 
# /home/ndap/provisioning/install_spatialanalysis4hive/gis-tools-for-hadoop/samples/point-in-polygon-aggregation-mr/aggregation-sample.jar
# 
hadoop fs -rmr /spatial_output;
hadoop jar /home/ndap/provisioning/install_spatialanalysis4hive/gis-tools-for-hadoop/samples/point-in-polygon-aggregation-mr/aggregation-sample.jar \
com.esri.hadoop.examples.AggregationSampleDriver \
-libjars /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/lib/esri-geometry-api.jar,/home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/spatial-sdk-hadoop.jar \
/spatial/counties/california-counties.json \
/spatial/earthquakes/earthquakes.csv \
/spatial_output

hadoop fs -rmr /spatial_output;
hadoop jar /home/ndap/provisioning/install_spatialanalysis4hive/gis-tools-for-hadoop/samples/point-in-polygon-aggregation-mr/aggregation-sample.jar \
com.esri.hadoop.examples.AggregationSampleDriver \
-libjars /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/lib/esri-geometry-api.jar,/home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/spatial-sdk-hadoop.jar,/home/ndap/.m2/repository/org/codehaus/jackson/jackson-core-asl/1.9.12/jackson-core-asl-1.9.12.jar,/home/ndap/.m2/repository/org/codehaus/jackson/jackson-mapper-asl/1.9.12/jackson-mapper-asl-1.9.12.jar \
/spatial/counties/california-counties.json \
/spatial/earthquakes/earthquakes.csv \
/spatial_output
# error 
http://search-hadoop.com/c/Hadoop:hadoop-tools/hadoop-rumen/src/main/java/org/apache/hadoop/tools/rumen/JsonObjectMapperWriter.java%7C%7C+%2522JSON+array%2522+%2522doesn

com.esri.hadoop.examples.MapperClass.setup

# not found error
13/05/15 01:49:43 INFO mapred.JobClient: Task Id : attempt_201305021954_0051_m_000000_2, Status : FAILED
Error: java.lang.ClassNotFoundException: org.codehaus.jackson.map.Module
  at java.net.URLClassLoader$1.run(URLClassLoader.java:202)
  at java.security.AccessController.doPrivileged(Native Method)
  at java.net.URLClassLoader.findClass(URLClassLoader.java:190)
  at java.lang.ClassLoader.loadClass(ClassLoader.java:306)
  at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:301)
  at java.lang.ClassLoader.loadClass(ClassLoader.java:247)
  at com.esri.hadoop.examples.MapperClass.setup(Unknown Source)
  at org.apache.hadoop.mapreduce.Mapper.run(Mapper.java:142)
  at org.apache.hadoop.mapred.MapTask.runNewMapper(MapTask.java:647)
  at org.apache.hadoop.mapred.MapTask.run(MapTask.java:323)
  at org.apache.hadoop.mapred.Child$4.run(Child.java:266)
  at java.security.AccessController.doPrivileged(Native Method)
  at javax.security.auth.Subject.doAs(Subject.java:396)
  at org.apache.hadoop.security.UserGroupInformation.doAs(UserGroupInformation.java:1278)
  at org.apache.hadoop.mapred.Child.main(Child.java:260)


hadoop fs -rmr /spatial_output;
hadoop jar /home/ndap/provisioning/install_spatialanalysis4hive/gis-tools-for-hadoop/samples/point-in-polygon-aggregation-mr/aggregation-sample.jar \
com.esri.hadoop.examples.AggregationSampleDriver \
-libjars /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/lib/esri-geometry-api.jar,/home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/spatial-sdk-hadoop.jar,/home/ndap/.m2/repository/org/codehaus/jackson/jackson-core-asl/1.9.12/jackson-core-asl-1.9.12.jar,/home/ndap/.m2/repository/org/codehaus/jackson/jackson-mapper-asl/1.9.12/jackson-mapper-asl-1.9.12.jar \
/spatial/counties/california-counties.json \
/spatial/earthquakes/earthquakes.csv \
/spatial_output


cd /home/ndap/provisioning/install_spatialanalysis4hive/gis-tools-for-hadoop/samples/point-in-polygon-aggregation-mr/cmd
cd /home/ndap/provisioning/install_spatialanalysis4hive/gis-tools-for-hadoop/samples/point-in-polygon-aggregation-mr/src/com/esri/hadoop/examples


Error: org.codehaus.jackson.map.ObjectMapper.registerModule(Lorg/codehaus/jackson/map/Module;)V




hadoop fs -rmr /spatial_output;
hadoop jar 

mkdir ./jars;
mkdir ./jars/tmp;
cp /home/ndap/provisioning/install_spatialanalysis4hive/gis-tools-for-hadoop/samples/point-in-polygon-aggregation-mr/aggregation-sample.jar ./jars;
cp /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/lib/esri-geometry-api.jar ./jars;
cp /home/ndap/provisioning/install_spatialanalysis4hive/spatial-framework-for-hadoop/spatial-sdk-hadoop.jar ./jars;
cp /home/ndap/.m2/repository/org/codehaus/jackson/jackson-core-asl/1.9.12/jackson-core-asl-1.9.12.jar ./jars;
cp /home/ndap/.m2/repository/org/codehaus/jackson/jackson-mapper-asl/1.9.12/jackson-mapper-asl-1.9.12.jar ./jars;
cd ./jars/tmp ;
jar -xvf ../aggregation-sample.jar;
jar -xvf ../esri-geometry-api.jar;
jar -xvf ../spatial-sdk-hadoop.jar;
jar -xvf ../jackson-core-asl-1.9.12.jar;
jar -xvf ../jackson-mapper-asl-1.9.12.jar;
cd ..;
jar -cvf a.jar -C tmp .;
cd ..;