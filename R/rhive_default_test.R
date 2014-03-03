# ==============================================================
# RHive test and example code for NDAP
# Last update: 2013.03.06
# Copyright by NexR. all rights reserved
# ==============================================================

# Setting environment variable
Sys.setenv(JAVA_HOME="/home/ndap/ndap/jdk")
Sys.setenv(HIVE_HOME="/home/ndap/ndap/hive")
Sys.setenv(HADOOP_HOME="/home/ndap/ndap/hadoop")
Sys.setenv(HADOOP_CONF="/home/ndap/ndap/hadoop/conf")

# Checking if necessary packages are installed
pkgs <- rownames(installed.packages())

if (length(pkgs[grep("^rJava$", pkgs)]) == 0) {
  cat("rhive_test_result=ERROR_RJAVA_NOT_INSTALLED", sep="\n")
  q(status=-1)
}

if (length(pkgs[grep("^RHive$", pkgs)]) == 0) {
  cat("rhive_test_result=ERROR_RHIVE_NOT_INSTALLED", sep="\n")
  q(status=-1)
}

if (length(pkgs[grep("^digest$", pkgs)]) == 0) {
  cat("rhive_test_result=ERROR_DIGEST_NOT_INSTALLED", sep="\n")
  q(status=-1)
}

# Loading libraries
library(rJava)
library(digest)
library(RHive)

# Checking wheather rJava is loaded
if (length(search()[grep("package:rJava", search())]) != 1) {
  cat("rhive_test_result=ERROR_RJAVA_LOADING", sep="\n")
  q(status=-1)
}

# Checking wheather RHive is loaded
if (length(search()[grep("package:RHive", search())]) != 1) {
  cat("rhive_test_result=ERROR_RHIVE_LOADING", sep="\n")
  q(status=-1)
}

# Hive-Thrift server information (default)
hive.host <- "localhost"
hive.port <- "10000"

# Getting command line arguments
args <- commandArgs(T)
if (length(args) == 0) {
  cat("There is no argument", sep="\n")
} else {
  cat(paste(args, sep="", collapse=", "), sep="\n")
}

# Connecting to Hive thrift
rhive.connect(host=hive.host, port=hive.port)

# Writing a data.frame to a Hive table
iris_for_test <- iris
rhive.write.table(iris_for_test)
rm(iris_for_test)

# Checking wheather table is made or not
hive.table.list <- rhive.list.tables()
if (length(hive.table.list[grep("^iris_for_test$", hive.table.list),]) == 0)) {
  cat("rhive_test_resutl=CAN_NOT_WRITE_TABLE", sep="\n")
}
rm(hive.table.list)


# Testing basic query works or not
query <- "SELECT * FROM iris_for_test ORDER BY species"
cat(sprintf("Executing query: %s", query), sep="\n")
result <- rhive.query(query)

# Checking result is valid or not
result.md5digest <- digest(result, algo="md5")


# Testing statistical query works or not
query <- "SELECT * FROM iris_for_test ORDER BY species"
cat(sprintf("Executing query: %s", query), sep="\n")
result <- rhive.query(query)

# Checking result is valid or not
result.md5digest <- digest(result, algo="md5")

# Testing wheather a tables can be removed
rhive.query("DROP TABLE iris_for_test")
hive.table.list <- rhive.list.tables()
if (length(hive.table.list[grep("^iris_for_test$", hive.table.list),]) != 0)) {
  cat("rhive_test_resutl=CAN_NOT_REMOVE_TABLE", sep="\n")
}
rm(hive.table.list)

# All done
cat("rhive_test_result=OK", sep="\n")
q(status=0)

# ==============================================================
# end of script
# ==============================================================