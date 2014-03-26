# SS MESG - pivot example
library(RHive)
# detach("package:RHive", unload=T)
rhive.connect("192.168.93.11", 10001, "hdfs://192.168.93.11:9000", c(), FALSE, FALSE)
rhive.write.table(iris)
iris2 <- rhive.load.table2("iris")

rhive.query("add jar /home/ndap/ndap/nexr-platform-hive-udf/sec_bda.jar")
rhive.query("create temporary function explode_map AS
'org.apache.hadoop.hive.ql.udf.generic.GenericUDTFMapExplode'")
grep("explode_map", rhive.query("show functions")[,1])

# sample query from Navis
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
