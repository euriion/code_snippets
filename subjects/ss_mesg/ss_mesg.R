# --------------------------------
# SS MESG - connection
# --------------------------------

library(RHive)
rhive.connect("192.168.93.11", 10001, "hdfs://192.168.93.11:9000", c(), FALSE, FALSE)

irisTemp <- rhive.load.table2("iris", remote=F)
rhive.write.table(iris)
rhive.hdfs.ls("/tmp/rhive_load/20130516_180804")
rhive.hdfs.get("/tmp/rhive_load/20130516_180804" , )
# insert overwrite test
rhive.query("insert overwrite local directory '/home/ndap/ttt' select * from iris")

# --------------------------------
# Registering UDF JAR and fuction
# --------------------------------
rhive.query("add jar /home/ndap/ndap/nexr-platform-hive-udf/sec_bda.jar")
# initlize function to use
rhive.query("create temporary function explode_map AS 'org.apache.hadoop.hive.ql.udf.generic.GenericUDTFMapExplode'")
# checking if the function is registered in Hive
grep("explode_map", rhive.query("show functions")[,1])


# --------------------------------
# Pivot sample query (NexR cusstom UDF)
# --------------------------------
rhive.query("
from (
  select explode_map(G) as (item_id, value) from (
    select group_map_on(out_datetime , 'item_id', 'value', params) as
    G from hdd_raw group by lot_name
  ) A
) pcol
SELECT pcol.item_id AS id, count(pcol.value), min(pcol.value),
max(pcol.value), avg(pcol.value), stddev(pcol.value)
GROUP BY pcol.item_id
")

rhive.query("use smqc")
smelec_flat <- rhive.load.table2("smelec_flat")
rhive.query("show tables")

# ===== End
