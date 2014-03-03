# ==============================================================
# RHive test and example code for NDAP
# --------------------------------------------------------------
# Last update: 2013.03.06
# Copyright by NexR. all rights reserved
# ==============================================================

# --------------------------------------------------------------
# Setting environment variable
# RHive 작동에 필요한 환경변수를 세팅
# --------------------------------------------------------------
Sys.setenv(JAVA_HOME="/home/ndap/ndap/jdk")
Sys.setenv(HIVE_HOME="/home/ndap/ndap/hive")
Sys.setenv(HADOOP_HOME="/home/ndap/ndap/hadoop")
Sys.setenv(HADOOP_CONF="/home/ndap/ndap/hadoop/conf")

# --------------------------------------------------------------
# Checking if necessary packages are installed
# 필수패키지들이 설치되어 있는지 확인
# --------------------------------------------------------------
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

# --------------------------------------------------------------
# Loading libraries
# 필수 라이브러리를 로딩
# --------------------------------------------------------------
library(rJava)
library(digest)
library(RHive)

# --------------------------------------------------------------
# Checking if rJava is loaded
# rJava가 정상 로딩되었는지 확인
# --------------------------------------------------------------
if (length(search()[grep("package:rJava", search())]) != 1) {
  cat("rhive_test_result=ERROR_RJAVA_LOADING", sep="\n")
  q(status=-1)
}

# --------------------------------------------------------------
# Checking wheather RHive is loaded
# RHive가 정상 로딩되었는지 확인
# --------------------------------------------------------------
if (length(search()[grep("package:RHive", search())]) != 1) {
  cat("rhive_test_result=ERROR_RHIVE_LOADING", sep="\n")
  q(status=-1)
}

# --------------------------------------------------------------
# Hive-Thrift server information (default)
# Hive server의 정보를 설정
# --------------------------------------------------------------
hive.host <- "qa1"
hive.port <- "10001"

# --------------------------------------------------------------
# Getting command line arguments
# 인수입력에 대한 테스트
# --------------------------------------------------------------
args <- commandArgs(T)
if (length(args) == 0) {
  cat("There is no argument", sep="\n")
} else {
  cat(paste(args, sep="", collapse=", "), sep="\n")
}

# Connecting to Hive thrift
rhive.connect(host=hive.host, port=hive.port)


# --------------------------------------------------------------
# Writing a data.frame to a Hive table
# data.frame을 Hive table로 저장할 수 있는지 확인
# --------------------------------------------------------------

hive.table.list <- rhive.list.tables()[,1]
if (length(hive.table.list[grep("^iris_for_test$", hive.table.list)]) == 1) {
  rhive.query("DROP TABLE iris_for_test")
}

iris_for_test <- iris
rhive.write.table(iris_for_test)
rm(iris_for_test)

# Checking wheather table is made or not
hive.table.list <- rhive.list.tables()[,1]
if (length(hive.table.list[grep("^iris_for_test$", hive.table.list)]) == 0) {
  cat("rhive_test_resutl=CAN_NOT_WRITE_TABLE", sep="\n")
}
rm(hive.table.list)

# --------------------------------------------------------------
# Getting description of the Hive table
# Hive table의 description을 가져온다
# --------------------------------------------------------------
result <- rhive.desc.table("iris_for_test")
cat(paste(result, sep="", collapse=""))

# --------------------------------------------------------------
# Testing basic query works or not
# 기초 query가 작동하는지 확인
# --------------------------------------------------------------
query <- "SELECT * FROM iris_for_test ORDER BY species"
cat(sprintf("Executing query: %s", query), sep="\n")
result <- rhive.query(query)
# cat(paste(result), sep="", collapse="")
# result.md5digest <- digest(result, algo="md5")

# --------------------------------------------------------------
# Testing a query works or not
# UDF를 사용한 query가 작동하는지 확인
# --------------------------------------------------------------
query <- "SELECT sum(sepallength) AS c1, avg(sepalwidth) AS c2, min(petallength) AS c3, max(petalwidth) AS c4 FROM iris_for_test ORDER BY c1"
cat(sprintf("Executing query: %s", query), sep="\n")
result <- rhive.query(query)
# cat(paste(result), sep="", collapse="")
# result.md5digest <- digest(result, algo="md5")

# --------------------------------------------------------------
# Test for RHive UDF implementation
# RHive UDAF, UDTF등이 작동하는지 확인
# --------------------------------------------------------------
# Map iteration
sumAllColumns <- function(prev, values) {
  if (is.null(prev)) {
    prev <- rep(0.0, length(values))
  } 
  prev + values
}

# Map combine
sumAllColumns.partial <- function(values) {
  values
}

# Reduce iteration
sumAllColumns.merge <- function(prev, values) {
  if (is.null(prev)) {
    prev <- rep(0.0, length(values))
  }
  prev + values 
}

# Reduce combine
sumAllColumns.terminate <- function(values) {
  values
}

rhive.assign("sumAllColumns", sumAllColumns)
rhive.assign("sumAllColumns.partial", sumAllColumns.partial)
rhive.assign("sumAllColumns.merge", sumAllColumns.merge)
rhive.assign("sumAllColumns.terminate", sumAllColumns.terminate)
rhive.exportAll("sumAllColumns")

rhive.query("set hive.fetch.task.conversion=minimal")  # disable sampling conversion
result <- rhive.query("SELECT species, RA('sumAllColumns', sepallength, sepalwidth, petallength, petalwidth) FROM iris_for_test GROUP BY species")

# --------------------------------------------------------------
# Testing if a table can be removed
# 테이블이 삭제되는지 확인
# --------------------------------------------------------------
rhive.query("DROP TABLE iris_for_test")
hive.table.list <- rhive.list.tables()[,1]
if (length(hive.table.list[grep("^iris_for_test$", hive.table.list)]) != 0) {
  cat("rhive_test_result=CAN_NOT_REMOVE_TABLE", sep="\n")
  q(status=-1)
}
rm(hive.table.list)

# --------------------------------------------------------------
# Testing RHive map-reduce
# RHive map/reduce구현 작동 확인
# --------------------------------------------------------------

# map <- function(key, value) {
#   if(is.null(value)) {
#     put(NA, 1)
#   } else {
#     put(value, 1)
#   }
# }

# reduce <- function(key, cnt) {
#   put(key, sum(as.numeric(cnt)))
# }

# rhive.mrapply("iris_for_test", map, reduce, c("rhive_row", "species"), c("species","one"), by="species", c("species","one"), c("species","cnt"))

# -- [ END ] ---------------------------------------------------

cat("rhive_test_result=OK", sep="\n")
q(status=0)

# ==============================================================
# end of script
# ==============================================================
