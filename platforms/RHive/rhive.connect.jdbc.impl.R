
library(RJDBC)

if (hiveHomeDirectory == "") {
  cat("error")
}

if (!file.info(Sys.getenv("HIVE_HOME"))$isdir) {
  cat("[RHIVE-ERROR] Can not find HIVE_HOME directory in you system!")
}


initRHiveJDBC <- function() {
  hiveHomeDirectory <- "a"
  hiveLibDirectory <- paste(Sys.getenv("HIVE_HOME"), "lib", sep="/", collapse="")
  hiveLibJars <- list.files(hiveLibDirectory, pattern="*.jar$")
  
  invisible(sapply(hiveLibJars, function(filename) {
    .jaddClassPath(paste(hiveLibDirectory, filename, sep="/", collpase=""))
  }))
  
  
  hadoopCoreJars <- list.files(Sys.getenv("HADOOP_HOME"), pattern="*.jar$")
  invisible(sapply(hadoopCoreJars, function(filename) {
    .jaddClassPath(paste(Sys.getenv("HADOOP_HOME"), filename, sep="/", collpase=""))
  }))
  
  
  hadoopLibDirectory <- paste(Sys.getenv("HADOOP_HOME"), "lib", sep="/", collapse="")
  hadoopLibJars <- list.files(hadoopLibDirectory, pattern="*.jar$")
  
  invisible(sapply(hadoopLibJars, function(filename) {
    .jaddClassPath(paste(hadoopLibDirectory, filename, sep="/", collpase=""))
  }))
  # .jclassPath()
  
  rhive.jdbc.drv <<- JDBC("org.apache.hive.jdbc.HiveDriver",
       "/home/ndap/ndap/hive/lib/hive-jdbc-0.10.0-nr1012.jar",
       identifier.quote="`")
}


rhiveJdbcConnect <- function(host="127.0.0.1", port=10000, databaseName="default", driver=NA) {
  return(dbConnect(rhive.jdbc.drv, sprintf("jdbc:hive2://%s:%d/%s", host, port, databaseName)))
}

rhive.jdbc.connect <- rhiveJdbcConnect

initRHiveJDBC()
conn <- rhive.jdbc.connect("192.168.93.11", 10000)
dbGetQuery(conn, "show tables")

# replacing dbDataType function to new (risky but for testing)
setMethod("dbDataType", signature(dbObj="JDBCConnection", obj = "ANY"),
          def = function(dbObj, obj, ...) {
            if (is.integer(obj)) "INT"
            else if (is.numeric(obj)) "DOUBLE"
            else "STRING"
          }, valueClass = "character")

dbWriteTable(conn, "iris", iris, overwrite=TRUE)  # this doesn't work with Hive because Hive doesn't provide INSERT INTO syntax

dbGetQuery(conn, "show tables")


