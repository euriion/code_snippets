-- ---------------------------------------------------------------------
-- Scenario2-type3
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS vcrm_vehicle;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_vehicle (
  vin    STRING COMMENT '' ,
  v_type STRING COMMENT '' ,
  nf1    INT    COMMENT '' ,
  nf2    INT    COMMENT '' ,
  ukf1   STRING COMMENT '' ,
  date1  STRING COMMENT '' ,
  date2  STRING COMMENT '' ,
  nf3    INT    COMMENT '' ,
  sf1    STRING COMMENT '' ,
  sf2    STRING COMMENT '' ,
  sf3    STRING COMMENT '' ,
  sf4    STRING COMMENT '' ,
  sf5    STRING COMMENT ''
)
COMMENT 'Vehicle'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_vehicle';


# POC03-1_tms_hma_diag_dtclatlong.csv
USE POC2;
DROP TABLE IF EXISTS vcrm_dtc;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_dtc (
  id1   STRING COMMENT '' , -- ee1a183a-4294-42fb-9c16-e602625d9f1c
  id2   STRING COMMENT '' , -- 5NPEC4AC1DH578937
  dt1   STRING COMMENT '' , -- 2013-03-09 13:56:00
  f1    STRING COMMENT '' , -- U9000
  f2    STRING COMMENT '' , -- U9000
  f3    STRING COMMENT '' , -- U9000
  n1    INT    COMMENT '' , -- 9000
  n2    INT    COMMENT '' , -- 61440
  n3    INT    COMMENT '' , -- 2730
  dt2   STRING COMMENT '' , -- 2013-03-09 13:56:00
  b1    STRING COMMENT '' , -- N
  b2    STRING COMMENT '' , -- Y
  dt3   STRING COMMENT '' , -- 2013-03-10 06:35:06
  n4    FLOAT  COMMENT '' , -- 0.000000000000
  n5    FLOAT  COMMENT '' , -- 0.000000000000
  text1 STRING COMMENT ''   --  SCHEDULED VEHICLE DIAGNOSTICS
)
COMMENT 'DTC'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_dtc';

-- ---------------------------------------------------------------------
-- Scenario2-type1
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS VCRM_TM_MASTER;
DROP TABLE IF EXISTS VCRM_TM_TEMPERATURE;
DROP TABLE IF EXISTS VCRM_TM_USAGE;
DROP TABLE IF EXISTS VCRM_TM_GPS;
DROP TABLE IF EXISTS VCRM_TM_MPG;
DROP TABLE IF EXISTS VCRM_TM_SPEED;

DROP DATABASE IF EXISTS poc2;
CREATE DATABASE poc2
COMMENT 'PoC2 - VCRM database';
USE poc2;

DROP TABLE IF EXISTS VCRM_TM_MASTER;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_tm_master (
  vin             STRING  COMMENT 'VIN'                , -- vin
  trip_id         STRING  COMMENT 'Trip Id'            , -- tripId
  turnon          STRING  COMMENT 'Turn on time'       , -- turnOn
  turnoff         STRING  COMMENT 'Turn off time'      , -- turnOff
  totalmileage    INT     COMMENT 'Total Mileages'     , -- accuMileages
  drivingtime     INT     COMMENT 'Total Driving Time' , -- drivingTime
  seatbelt        STRING  COMMENT 'Seatbelt'           , -- seltBelt
  tirepressure    FLOAT   COMMENT 'Tire Pressure'      , -- tirePresure
  fuelconsumption FLOAT   COMMENT 'Fuel Consumption'   , -- fuelConsumption
  co2emission     FLOAT   COMMENT 'CO2 Gas Emission'   , -- co2Emission
  eco_yello       INT     COMMENT 'ECO Yellow score'   , -- ecoWhite
  eco_white       INT     COMMENT 'ECO White score'    , -- ecoYellow
  eco_green       INT     COMMENT 'ECO Green score'      -- ecoGreen
)
COMMENT 'POC2 Telematics Master'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_tm/vcrm_tm_master';

DROP TABLE IF EXISTS vcrm_tm_temperature;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_tm_temperature (
  vin                STRING COMMENT 'VIN'                     ,
  trip_id            STRING COMMENT 'Trip Id'                 ,
  sequence           INT    COMMENT 'Sequence number in Trip' ,
  dt                 STRING COMMENT 'Datetime'                ,
  insidetemperature  FLOAT  COMMENT 'Inside temperature'      ,
  outsidetemperature FLOAT  COMMENT 'Outside temperature'
)
COMMENT 'POC2 Telematics Temperature'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_tm/vcrm_tm_temperature';

DROP TABLE IF EXISTS vcrm_tm_usage;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_tm_usage (
  vin       STRING COMMENT 'VIN'        ,
  trip_id   STRING COMMENT 'Trip ID'    ,
  sequence  INT    COMMENT 'Sequence'   ,
  dt        STRING COMMENT 'Datetime'   ,
  usagetype STRING COMMENT 'Usage type' ,
  onoff     STRING COMMENT 'Of/Off'
)
COMMENT 'POC2 Telematics Usage'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_tm/vcrm_tm_usage';

DROP TABLE IF EXISTS vcrm_tm_gps;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_tm_gps (
  vin             STRING COMMENT 'VIN'                    ,
  trip_id         STRING COMMENT 'Trip Id'                ,
  sequence        INT    COMMENT 'Sequence'               ,
  dt              STRING COMMENT 'Datetime String'        ,
  latitude        INT    COMMENT 'Latitude milliarc sec'  ,
  longitude       INT    COMMENT 'Longitude milliarc sec' ,
  latitudedegree  FLOAT  COMMENT 'Latitude degree'        ,
  longitudedegree FLOAT  COMMENT 'Longitude degree'
)
COMMENT 'POC2 Telematics GPS'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_tm/vcrm_tm_gps';

DROP TABLE IF EXISTS vcrm_tm_mpg;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_tm_mpg (
  vin      STRING COMMENT 'VIN'                     ,
  trip_id  STRING COMMENT 'Trip ID'                 ,
  sequence INT    COMMENT 'Sequence number in Trip' ,
  dt       STRING COMMENT 'Datetime'                ,
  kpl      FLOAT  COMMENT 'Kilometer per Liter'
)
COMMENT 'POC2 Telematics Mile per Gallon'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_tm/vcrm_tm_mpg';

# -- TMS speed 테이블
DROP TABLE IF EXISTS vcrm_tm_speed;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_tm_speed (
  vin           STRING COMMENT 'VIN'                       ,
  trip_id       STRING COMMENT 'Trip ID'                   ,
  sequence      INT    COMMENT 'Squence'                   ,
  dt            STRING COMMENT 'Datetime'                  ,
  speed         FLOAT  COMMENT 'Current speed'             ,
  acceleration  FLOAT  COMMENT 'Acceleration'              ,
  travel        FLOAT  COMMENT 'Travel (distance)'         ,
  averagetravel FLOAT  COMMENT 'Moving average of Travel'
)
COMMENT 'POC2 Telematics Mile per Gallon'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_tm/vcrm_tm_speed';

-- ---------------------------------------------------------
# -- gps 테스트
DROP TABLE IF EXISTS vcrm_gps_sample;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_gps_sample (
  vin             STRING COMMENT 'VIN'                    ,
  trip_id         STRING COMMENT 'Trip Id'                ,
  sequence        INT    COMMENT 'Sequence'               ,
  dt              STRING COMMENT 'Datetime String'        ,
  latitude        INT    COMMENT 'Latitude milliarc sec'  ,
  longitude       INT    COMMENT 'Longitude milliarc sec' ,
  latitudedegree  FLOAT  COMMENT 'Latitude degree'        ,
  longitudedegree FLOAT  COMMENT 'Longitude degree'
)
COMMENT 'POC2 Telematics GPS'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_gps_sample';

# -- gps 미국주 맵핑 테스트
DROP TABLE IF EXISTS vcrm_gps_sample_state;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_gps_sample_state (
  vin             STRING COMMENT 'VIN'                    ,
  trip_id         STRING COMMENT 'Trip Id'                ,
  sequence        INT    COMMENT 'Sequence'               ,
  dt              STRING COMMENT 'Datetime String'        ,
  latitude        INT    COMMENT 'Latitude milliarc sec'  ,
  longitude       INT    COMMENT 'Longitude milliarc sec' ,
  latitudedegree  FLOAT  COMMENT 'Latitude degree'        ,
  longitudedegree FLOAT  COMMENT 'Longitude degree',
  state STRING COMMENT 'State FIPS'
)
COMMENT 'POC2 Telematics GPS'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_gps_sample_state';

-- hadoop fs -mkdir /poc/2/vcrm_gps_sample
-- hadoop fs -put /data1/vcrm_feed_output/split_0001/vcrm_tm_gps.0001.tsv /poc/2/vcrm_gps_sample/


# -- gps 미국주 맵핑
DROP TABLE IF EXISTS vcrm_gps_ext;
CREATE EXTERNAL TABLE IF NOT EXISTS vcrm_gps_ext (
  vin             STRING COMMENT 'VIN'                    ,
  trip_id         STRING COMMENT 'Trip Id'                ,
  sequence        INT    COMMENT 'Sequence'               ,
  dt              STRING COMMENT 'Datetime String'        ,
  latitude        INT    COMMENT 'Latitude milliarc sec'  ,
  longitude       INT    COMMENT 'Longitude milliarc sec' ,
  latitudedegree  FLOAT  COMMENT 'Latitude degree'        ,
  longitudedegree FLOAT  COMMENT 'Longitude degree',
  state STRING COMMENT 'State FIPS'
)
COMMENT 'POC2 Telematics GPS extended'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_gps_ext';

