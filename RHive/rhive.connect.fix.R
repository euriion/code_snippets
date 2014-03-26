#http://stackoverflow.com/questions/8661526/permanently-replacing-a-function
R에서 Debugging 용으로 쓰는 편법 공유합니다.
RHive 디버깅하면서 계속 패키지를 고쳐서 재설치했었는데 손가락이 부러질것 같아서 다른 방법으로 시도해봤습니다.
지금은 R을 쓰시는 분들이 별로 없어서 RHive 디버깅하실일이 없겠지만...
디버깅 용도 뿐만 아니라 R패키지중에서 로딩되면서 다른 패키지에 있는 function의 내용을 동적으로 확장시켜 버리는 것들이 있는데 그것들도 유사한 방법을 씁니다.

# -- 코드 시작 --
library(RHive)  # 일단 function이 들어 있는 패키지 로딩

temp.env <- as.environment("package:RHive")  # 패키지 namespace 땡겨오기
# 덮어 씌울 펑션 복사해다 붙이고 고친다. print문과 debugging용 코드를 마음껏 넣는다.
temp.func <- function(host="127.0.0.1",port=10000, hdfsurl=NULL ,hosts = RHIve:::rhive.defaults("slaves"),verbose=T) {
     filesystem <- NULL

     if (verbose) { print("Start RHive connecting") }

     if(!is.null(hdfsurl)) {
        if (verbose) {print(sprintf("connecting to HDFS %s", hdfsurl))}
        filesystem <- rhive.hdfs.connect(hdfsurl)
        
     } else {
        print("loading config...")
        config <- RHive:::rhive.defaults('hconfig')
        if(!is.null(config)) {
            if (verbose) { print("Getting fs.default.name") }
            hdfsurl <- config$get("fs.default.name")
            if (verbose) { print(sprintf("connecting to HDFS %s", hdfsurl)) }
            hdfs <- rhive.hdfs.connect(hdfsurl)
            if (verbose) { print(sprintf("connected to HDFS %s", hdfsurl)) }
            print(sprintf("hdfs url is %s",hdfsurl))
        }   
     }   

     print("Loading java class 'org.apache.thrift.transport.TSocket'")
     TSocket <- J("org.apache.thrift.transport.TSocket")
     print("Loading java class 'org.apache.thrift.protocol.TProtocol'")
     TProtocol <- J("org.apache.thrift.protocol.TProtocol")
     HiveClient <- J("org.apache.hadoop.hive.service.HiveClient")
     hivecon <- .jnew("org/apache/thrift/transport/TSocket",.jnew("java/lang/String",host),as.integer(port))
     tpt <- .jnew("org/apache/thrift/protocol/TBinaryProtocol",.jcast(hivecon, new.class="org/apache/thrift/transport/TTransport",check = FALSE, convert.array = FALSE)) 
     client <- .jnew("org/apache/hadoop/hive/service/HiveClient",.jcast(tpt, new.class="org/apache/thrift/protocol/TProtocol",check = FALSE, convert.array = FALSE)) 
    
     result <- try(hivecon$open(), silent = FALSE)
     if(class(result) == "try-error") {
        if(!is.null(hdfs)) {
            rhive.hdfs.close(hdfs)
        }   
        sprintf("fail to connect RHive [hiveserver = %s:%s, hdfs = %s]\n", host,port,hdfsurl)
        return(NULL)
     }

     if (verbose) { print("Adding UDF functions for RHive") }
    
     client$execute(.jnew("java/lang/String","add jar hdfs:///rhive/lib/rhive_udf.jar"))
     client$execute(.jnew("java/lang/String","create temporary function R as 'com.nexr.rhive.hive.udf.RUDF'"))
     client$execute(.jnew("java/lang/String","create temporary function RA as 'com.nexr.rhive.hive.udf.RUDAF'"))
     client$execute(.jnew("java/lang/String","create temporary function unfold as 'com.nexr.rhive.hive.udf.GenericUDTFUnFold'"))
     client$execute(.jnew("java/lang/String","create temporary function expand as 'com.nexr.rhive.hive.udf.GenericUDTFExpand'"))
     client$execute(.jnew("java/lang/String","create temporary function rkey as 'com.nexr.rhive.hive.udf.RangeKeyUDF'"))
     client$execute(.jnew("java/lang/String","create temporary function scale as 'com.nexr.rhive.hive.udf.ScaleUDF'"))
     client$execute(.jnew("java/lang/String","create temporary function array2String as 'com.nexr.rhive.hive.udf.GenericUDFArrayToString'"))

     hiveclient <- list(client,hivecon,c(host,port),hosts,hdfs,hdfsurl)

     class(hiveclient) <- "rhive.client.connection"
     #reg.finalizer(hiveclient,function(r) {
     #     hivecon <- .jcast(r[[2]], new.class="org/apache/thrift/transport/TSocket",check = FALSE, convert.array = FALSE) 
     #     hivecon$close()    
     #      print("call finalizer")
    # })
     assign('hiveclient', hiveclient, envir=RHive:::.rhiveEnv)

     if (verbose) { print("End RHive connecting") }

}

unlockBinding( "rhive.connect", env = temp.env )  # Lock 해제
assignInNamespace( "rhive.connect", temp.func , envir = temp.env )  # Namespace안에 있는 펑션교체
assign( "rhive.connect", temp.func , envir = temp.env )  # Namespace밖에 있는 펑션교체
rm(temp.func)  # 임시 펑션 제거
lockBinding( "rhive.connect", env = temp.env )  # 다시 locking
rhive.connect()  # 바뀐 펑션 실행
# -- 코드 끝 --


# 주의
# 패키지내에 존재하는 다른 function을 호출하는 문제 때문에 실행이 안되는 경우가 있음 (이론상으로는 되야 하는데 왜 안되는지..)
rhive.defaults("slaves") # <-- 이런것들을
RHive:::rhive.defaults("slaves") # <-- function의 body나 argument선언 안에서 이렇게 바꿔줌



# ------------------
#"hdfs://dst6:9000"
#config
# Checking code
library(RHive)
hdfsurl = RHive:::rhive.hdfs.default.name()
config <- .jnew("org/apache/hadoop/conf/Configuration")
config$set(.jnew("java/lang/String", "fs.default.name"), .jnew("java/lang/String", hdfsurl))
fileSystem <- J("org.apache.hadoop.fs.FileSystem")
fs <- fileSystem$get(config)

temp.env <- as.environment("package:RHive")
temp.func <- function (hdfsurl = RHive:::rhive.hdfs.default.name(), verbose=T) 
{
    if (verbose) { print("Start HDFS connecting") }
    if (is.null(hdfsurl)) 
        stop("missing parameter or HADOOP_HOME must be set")

    config <- .jnew("org/apache/hadoop/conf/Configuration")

    config$set(.jnew("java/lang/String", "fs.default.name"), 
        .jnew("java/lang/String", hdfsurl))
    fileSystem <- J("org.apache.hadoop.fs.FileSystem")

    if (verbose) { print("Loading Hadoop configuration") }
    fs <- fileSystem$get(config)

    if (verbose) { print("Initializing FsShell") }
    fsshell <- .jnew("org/apache/hadoop/fs/FsShell", config)

    if (verbose) { print("Initializing DFUtils") }
    dfutils <- .jnew("com/nexr/rhive/util/DFUtils", config)

    hdfs <- list(fs, fsshell, dfutils)
    assign("hdfs", hdfs, envir = RHive:::.rhiveEnv)
    if (verbose) { print("Putting rhive_udf.jar") }
    if (rhive.hdfs.exists("/rhive/lib/rhive_udf.jar")) 
        rhive.hdfs.rm("/rhive/lib/rhive_udf.jar")

    if (verbose) {print("putting /rhive/lib/rhive_udf.jar")}
    result <- try(rhive.hdfs.put(paste(system.file(package = "RHive"), 
        "java", "rhive_udf.jar", sep = .Platform$file.sep), "/rhive/lib/rhive_udf.jar"), 
        silent = FALSE)
    if (class(result) == "try-error") {
        sprintf("fail to connect HDFS with %s - %s", hdfsurl, 
            result)
        return(NULL)
    }
    return(hdfs)
}
unlockBinding( "rhive.hdfs.connect", env = temp.env )
assignInNamespace( "rhive.hdfs.connect", temp.func , envir = temp.env )
assign( "rhive.hdfs.connect", temp.func , envir = temp.env )
rm(temp.func)
lockBinding( "rhive.hdfs.connect", env = temp.env )
as.environment("package:RHive")
rhive.connect()

