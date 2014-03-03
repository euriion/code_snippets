-- Hive table
DROP TABLE IF EXISTS vcrm_weathers;
CREATE TABLE IF NOT EXISTS vcrm_weather (
seq                             INT     ,
cdate                           STRING  ,
country_code                    STRING  ,
state_code                      STRING  ,
city_name                       STRING  ,
lati                            INT     ,
longi                           INT     ,
fog                             INT     ,
rain                            INT     ,
snow                            INT     ,
snowfallm                       FLOAT   ,
snowfalli                       FLOAT   ,
monthtodatesnowfallm            FLOAT   ,
monthtodatesnowfalli            FLOAT   ,
sinceejulsnowfallm              FLOAT   ,
since1julsnowfalli              FLOAT   ,
snowdepthm                      INT     ,
snowdepthi                      INT     ,
hail                            INT     ,
thunder                         INT     ,
tornado                         INT     ,
meantempm                       INT     ,
meantempi                       INT     ,
meandewptm                      INT     ,
meandewpti                      INT     ,
meanpressurem                   INT     ,
meanpressurei                   FLOAT,
meanwindspdm                    INT     ,
meanwindspdi                    INT     ,
meanwdird                       INT     ,
meanvism                        INT     ,
meanvisi                        INT     ,
maxtempm                        INT     ,
maxtempi                        INT     ,
mintempm                        INT     ,
mintempi                        INT     ,
maxhumidity                     INT     ,
minhumidity                     INT     ,
maxdewptm                       INT     ,
maxdewpti                       INT     ,
mindewptm                       INT     ,
mindewpti                       INT     ,
maxpressurem                    INT     ,
maxpressurei                    FLOAT,
minpressurem                    INT     ,
minpressurei                    FLOAT   ,
maxwspdm                        INT     ,
maxwspdi                        INT     ,
minwspdm                        INT     ,
minwspdi                        INT     ,
maxwism                         INT     ,
maxvisi                         INT     ,
minwism                         INT     ,
minvisi                         INT     ,
gdegreedays                     INT     ,
heatingdegreedays               INT     ,
coolingdegreedays               INT     ,
precipm                         FLOAT   ,
precipi                         FLOAT   ,
heatingdegreedaysnormal         INT     ,
monthtodateheatingdegreedays    INT     ,
monthtodateheatingdegreedaysno  INT     ,
since1sepheatingdegreedays      INT     ,
since1sepheatingdegreedaysnorm  INT     ,
since1julheatingdegreedays      INT     ,
since1julheatingdegreedaysnorm  INT     ,
coolingdegreedaysnormal         INT     ,
monthtodatecoolingdegreedays    INT     ,
monthtodatecoolingdegreedaysno  INT     ,
since1sepcoolingdegreedays      INT     ,
since1sepcoolingdegreedaysnorm  INT     ,
since1julcoolingdegreedays      INT     ,
since1julcoolingdegreedaysnorm  INT
)
COMMENT 'POC2 Weather Information'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_weather';


--------------------------------------------------------------

DROP TABLE IF EXISTS vcrm_tms_northam_dtc;
CREATE TABLE IF NOT EXISTS vcrm_tms_northam_dtc (
 session_ic                 STRING       ,
 vin                        STRING       ,
 session_start_datetime     TIMESTAMP    ,
 dtc_code                   STRING       ,
 dtc_system                 STRING       ,
 dtc_sub_system             STRING       ,
 measure_breakdown_code     INT          ,
 breakdown_dtc_code         INT          ,
 dtc_originated_mileage     INT          ,
 dtc_originated_datetime    TIMESTAMP    ,
 mil_on_ind                 STRING       ,
 odometer_dtc_ind           STRING       ,
 created_date               TIMESTAMP    ,
 latitude                   FLOAT        ,
 longitude                  FLOAT        ,
 service_type_name          STRING
)
COMMENT 'POC03-1_tms_hma_diag_dtclatlong.csv'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/poc/2/vcrm_tms_northam_dtc';


-- hadoop
hadoop fs -ls /poc/2
hadoop fs -mkdir /poc/2/vcrm_tms_northam_dtc
hadoop fs -put /data1/vcrm_dtc/POC03-1_tms_hma_diag_dtclatlong.csv /poc/2/vcrm_tms_northam_dtc/


---------------------------------------------------

-- local
mv /data1/vcrm_dtc/POC03-1_북미\ 고장설명문_dw1_qm_01_dtc_c.csv /data1/vcrm_dtc/northam_fault_desc.csv
cd /home/ndap/VCRM/codes
python csv2tsv.py northam_fault_desc.csv northam_fault_desc.tsv

-- hadoop
hadoop fs -ls /poc/2
hadoop fs -mkdir /poc/2/northam_fault_desc
hadoop fs -put /data1/vcrm_dtc/northam_fault_desc.tsv /poc/2/northam_fault_desc/

-- hive
DROP TABLE IF EXISTS vcrm_northam_fault_desc_dtc;
CREATE TABLE IF NOT EXISTS vcrm_northam_fault_desc_dtc (
 dtc_cd             STRING       ,
 dtc_cd_expl_sbc    STRING       ,
 etl_cre_dtm        TIMESTAMP    ,
 etl_mdfy_dtm       TIMESTAMP
)
COMMENT 'north america fault description'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/poc/2/northam_fault_desc';




-- local
mv /data1/vcrm_dtc/POC03-9_차량마스터_2013년 04월 기준.csv /data1/vcrm_dtc/northam_carmaster_data_201304.csv


-- hadoop
hadoop fs -mkdir /poc/2/northam_carmaster_data_201304
hadoop fs -put /data1/vcrm_dtc/northam_carmaster_data_201304.csv /poc/2/northam_carmaster_data_201304/


-- hive
DROP TABLE IF EXISTS vcrm_northam_carmaster_data_dtc;
CREATE TABLE IF NOT EXISTS vcrm_northam_carmaster_data_dtc (
 vin                   STRING    ,
 vin_srz_cd            STRING    ,
 vin_y                 STRING    ,
 vin_trim_cd           STRING    ,
 vrm_subj_car_yn       STRING    ,
 prdn_dt               STRING    ,
 sale_dt               STRING    ,
 vin_tm_cd             STRING    ,
 qm_vehl_cd            STRING    ,
 trim_l_cd_expl_sbc    STRING    ,
 tm_type_nm            STRING    ,
 dir_reg               STRING    ,
 eng_cd_expl_sbc       STRING
)
COMMENT 'north america car master data 201304'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/poc/2/northam_carmaster_data_201304';