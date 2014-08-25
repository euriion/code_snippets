Sys.setenv(HIVE_HOME="/srv/clog/hive-0.7.1")
Sys.setenv(RHIVE_DATA="/mnt/srv/R/data")

library(RHive)
host <- "10.1.3.1"
port <- 10000
hosts <- c("10.1.3.2", "10.1.3.3", "10.1.3.4", "10.1.3.5", "10.1.3.6", "10.1.3.7")

hive.conn <- rhive.connect(host=host, port=port, hosts=hosts)

tempdf <- rhive.query("show tables")

print(tempdf)
