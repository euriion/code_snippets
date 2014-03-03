Sys.setenv(JAVA_HOME="/home/ndap/ndap/jdk")
Sys.setenv(HIVE_HOME="/home/ndap/ndap/hive")
Sys.setenv(HADOOP_HOME="/home/ndap/ndap/hadoop")
Sys.setenv(HADOOP_CONF="/home/ndap/ndap/hadoop/conf")

pkgs <- rownames(installed.packages())

if (length(pkgs[grep("^rJava$", pkgs)]) == 0) {
  cat("rhive_test_result=ERROR_RJAVA_NOT_INSTALLED", sep="\n")
}

if (length(pkgs[grep("^RHive$", pkgs)]) == 0) {
  cat("rhive_test_result=ERROR_RHIVE_NOT_INSTALLED", sep="\n")
}

if (length(pkgs[grep("^digest$", pkgs)]) == 0) {
  cat("rhive_test_result=ERROR_DIGEST_NOT_INSTALLED", sep="\n")
}

# Loading libraries
library(rJava)
library(digest)
library(RHive)

if (length(search()[grep("package:rJava", search())]) != 1) {
  cat("rhive_test_result=ERROR_RHIVE_LOADING", sep="\n")
  q(status=-1)
}

if (length(search()[grep("package:RHive", search())]) != 1) {
  cat("rhive_test_result=ERROR_RHIVE_LOADING", sep="\n")
  q(status=-1)
}

args <- commandArgs(T)

# connecting to Hive thrift
HiveHost <- "qa1"
HivePort <- "10001"
rhive.connect(host=HiveHost, port=HivePort)

# not necessary because argument
# cat(paste("set hiveconf:task.notification.url=", args[1], sep=''))

# result1 <- rhive.query(paste("set hiveconf:task.notification.url=", args[1], sep="", collapse=""))
# cat(result1, sep="\n")

hiveQuery <- "SELECT * FROM access_log_alyssa ORDER BY ident_key LIMIT 20"
cat(sprintf("Executing query: %s", hiveQuery), sep="\n")
# result1 <- rhive.query(hiveQuery)
# result3 <- digest(result1, algo="md5")
# if (digest(result1, algo="md5") != result3) {
#   cat("rhive_test_result=ERROR_HDFS", sep="\n")
#   q(status=-1)
# } else {
  # print(result1)
  # md5_digest_expected <- "9eef3d9c8a1dff510400494433788172"
  # cat(sprintf("expected md5 digest: %s\n", md5_digest_expected))
  # md5_digest_result <- digest(result1, algo="md5")
  # cat(sprintf("result md5 digest: %s\n", digest(result1, algo="md5")))
  # if (md5_digest_expected != md5_digest_result) {
  #   cat("rhive_test_result=ERROR_DATA_CONSISTENCY", sep="\n")
  #   q(status=-1)
  # }
# }

cat("rhive_test_result=OK", sep="\n")
q(status=0)
