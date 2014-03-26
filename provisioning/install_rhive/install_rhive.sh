---  kisti ndap(v2.2.2 GA)설치   ---

-- Information --

1.namenode
 -> Hostname : kistiname
 -> IP : 210.108.181.117
 -> pw : kstadm13:
 -> RHive설치/R설치

2.datanode1
 -> Hostname : kistidata
 -> IP : 210.108.181.118
 -> pw : kstadm13:
 -> R설치
 
3.datanode2
 -> Hostname : kistidata2
 -> IP : 210.108.181.119
 -> pw : kstadm13: 
 -> R설치

 * mysqlpw : kstadm13:


-----------------------------------------------------------------------------------------------
* R을 설치
  - yum + EPL
     - http://fedoraproject.org/wiki/EPEL
        - Centos5/6확인

        Centos 5.x

        wget http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
        wget http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
        sudo rpm -Uvh remi-release-5*.rpm epel-release-5*.rpm

        Centos 6.x

        wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
        wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    - R은 전체 Node에 설치
  - source compile
     - 매우 복잡해짐
-----------------------------------------------------------------------------------------------
* RHive prerequsite packages 설치
  * Rserve (반드시 root 설치해야 함) 
    - 설치 명령어
    - R안에서: install.packages("Rserve", repos="http://cran.nexr.com")
    - shell에서: R -e 'install.packages("Rserve", repos="http://cran.nexr.com")'
    - /etc/Rserv.conf 고치거나 생성 (http://stats.math.uni-augsburg.de/rserve/doc.shtml 참조)
       - remote enable 한줄 추가해서 행성
      - echo "remote enable" > /etc/Rserv.conf (Rstudio서버 또는 namenode에는 할필요 없지만 하자. 정확히는 RHive가 설치되는 서버는 필요 없음)
  * rJava 설치
     - ndap_home: /home/ndap/ndap 
     - Java버젼을 확인하고 ndap에 있는 경우는 ndap 것으로 교체해서 사용 (ndap이 없는 경우 다른 Java 버전 사용)
     - ndap의 java_home: /home/ndap/ndap/jdk
       - /root/.bashrc 를 수정 (/etc/profile을 수정해도 됨)해서 아래 내용을 추가
          export JAVA_HOME="/home/ndap/ndap/jdk"
          export HADOOP_HOME="/home/ndap/ndap/hadoop"
          export HIVE_HOME="/home/ndap/ndap/hive"
          export PATH="/home/ndap/ndap/jdk/bin:$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin"
          source ~/.bashrc
          - 확인
             # env | grep HOME
             # which java
                /home/ndap/ndap/jdk/bin/java
     - rJava package 설치
        - R CMD javareconf -e 해야함 (아래 내용을 확인. 제대로 원하는 java를 인식하는지 확인 필요)
            Java interpreter : /home/ndap/ndap/jdk/jre/bin/java
            Java version     : 1.6.0_35
            Java home path   : /home/ndap/ndap/jdk
            Java compiler    : /home/ndap/ndap/jdk/bin/javac
            Java headers gen.: /home/ndap/ndap/jdk/bin/javah
            Java archive tool: /home/ndap/ndap/jdk/bin/jar
        - R안에서: install.packages("rJava", repos="http://cran.nexr.com")
        - shell에서: R -e 'install.packages("rJava", repos="http://cran.nexr.com"); library(rJava)'
        - R 실행 후 library(rJava) 로 확인
    - /usr/lib64/R/etc/Renviron 수정해야 함 (아래 넉줄 추가)
        JAVA_HOME=/home/ndap/ndap/jdk
        HADOOP_HOME=/home/ndap/ndap/hadoop
        HIVE_HOME=/home/ndap/ndap/hive
        PATH=/home/ndap/ndap/jdk/bin:${PATH}:${HADOOP_HOME}/bin:${HIVE_HOME}/bin
        # RHIVE_DATA=/tmp (경우에 따라 /mnt/data/rhive_temp 이런식으로 변경 가능)
        - 전체 적용
        # scp /usr/lib64/R/etc/Renviron kistidata:/usr/lib64/R/etc/
-----------------------------------------------------------------------------------------------
* RHive설치 (root계정으로 설치)
   - CRAN설치는 install.packags("RHive") 버전이 낮으므로 비추
   - 소스설치
     - 경로: https://github.com/nexr/RHive
     - prerequsite: git, ant
        - yum install git ant -y
     - mkdir rhive;cd rhive (하거나 생략)
     - git clone https://github.com/nexr/RHive
     - cd RHive (현재경로 exam: /root/rhive_install/RHive) 
     - Jar 빌드를 반드시 시도해서 확인 **
       - build.xml을 열어서 main-hive10을 확인
       - 그냥 ant가 안되면 ant main-hive10를 해서 BUILD SUCCESS이 나오는지는 확인
       - 이동 /root/rhive_install/RHive/RHive/inst/javasrc
         - ant main 실행
     - R로 RHive 패키지 빌드
        - R CMD build ./RHive
        - RHive_0.0-7.1.tar.gz가 생김
     - R로 RHive_0.0-7.1.tar.gz 설치
        - R CMD INSTALL ./RHive_0.0-7.1.tar.gz
        * (datanode에는 안해도 됨)
     - tar.gz를 생성하지 않고 설치 (에러가 나는 경우에 시도해 볼것)
        - R CMD INSTALL ./RHive

-----------------------------------------------------------------------------------------------
* RHive 구동확인

  - Hive-Server port 열린것 확인
    - netstat -nltp (10000 또는 10001이 열린 것을 확인)
  - Hive-Server가 작동하는지 확인
    - 접속: hive -h localhost -p 10000
    - 실행: show tables 또는 show databases
    - 어쨌든 ndap계정으로 전환
    - /home/ndap/ndap/hive/bin 으로이동
       - 목적은 hive-server1을 10001 포트로 오픈하는 것(***)
       - Hive-Server stop: ./hive-server stop
        Ndap user 로 hive server stop
        Hive port 지정 합니다.
        # -- 아래가 중요
        export HIVE_SERVER2_THRIFT_PORT=10000
        export HIVE_PORT=10001

        Hive Server Start 합니다
        Hive Server2 start  :  ./hive-server start 
        Hive Server start :  ./hive --service hiveserver &  # 중요

        ./beeline 으로 hive cli 실행 확인
        beeline> 상에서 hive server 연결 확인
        hive server 2 연결 : !connect jdbc:hive2://localhost:10000 org.apache.hive.jdbc.HiveDriver
        hive server 연결 : !connect jdbc:hive://localhost:10001 org.apache.hadoop.hive.jdbc.HiveDriver
  - RHive 접속 확인
     - ------이하 R코드
library(RHive)
rhive.connect(host="127.0.0.1", port=10001)
Error in .jcall("RJavaTools", "Ljava/lang/Object;", "invokeMethod", cl,  :
  java.lang.NoClassDefFoundError: com.sun.security.auth.UnixPrincipal
# 자버 버전 문제의 error
  # R CMD javareconf -e등과 RHive install을 root에서 다시 재시도 (특히 source로 바로 설치를 시도해 볼 것)

# 아래와 에러 발생
 rhive.connect("localhost", 10001)
Error in .jcall("RJavaTools", "Ljava/lang/Object;", "invokeMethod", cl,  :
  org.apache.hadoop.security.AccessControlException: org.apache.hadoop.security.AccessControlException: Permission denied: user=root, access=WRITE, inode="/":ndap:supergroup:drwxr-xr-x
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/home/ndap/ndap/hive/lib/slf4j-log4j12-1.6.1.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/home/ndap/ndap/hadoop/lib/slf4j-log4j12-1.4.3.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
Hive history file=/tmp/ndap/hive_job_log_ndap_201305151412_1390992628.txt
converting to local hdfs://kistiname:9000/rhive/lib/0.0-7.1/rhive_udf.jar
Failed to read external resource hdfs://kistiname:9000/rhive/lib/0.0-7.1/rhive_udf.jar
다음에 오류가 있습니다.jcall("RJavaTools", "Ljava/lang/Object;", "invokeMethod", cl,  :
  HiveServerException(message:Query returned non-zero code: 1, cause: hdfs://kistiname:9000/rhive/lib/0.0-7.1/rhive_udf.jar does not exist., errorCode:1, SQLState:null)

이유
  1.hdfs://kistiname:9000/rhive/lib/0.0-7.1/rhive_udf.jar가 없음
  2. root계정해서 RHive를 실행하면 반드시 에러가 발생함 (아래 경로를 권한 문제로 생성하지 못함. 왜? root는 ndap의 관리자 계정이 아니므로 권한이 없음)
    hadoop fs -ls /rhive/lib/0.0-7.1/
    ls: Cannot access /rhive/lib/0.0-7.1/: No such file or directory.
해결방법
  1. ndap계정으로 전환
  2. 접속이 되는지 확인 rhive.... 등
  Added resource: hdfs://kistiname:9000/rhive/lib/0.0-7.1/rhive_udf.jar:/tmp/ndap/hive_resources/rhive_udf97874572195746589.jar
OK
OK
OK
OK
OK
OK
OK
  3. rhive.connect를 할 때마다 /rhive/lib/0.0-7.1/rhive_udf.jar 파일을 복사하기 때문에 문제가 발생할 여지가 있음. 특히 다른 계정에서 연결할 때 문제가 발생
   권한을 전부 설정: hadoop fs -chmod -R 777 /rhive

-----------------------------------------------------------------------------------------------
* Rstudio server 설치 (root계정으로 할 것 반드시!)
  - 사이트: http://www.rstudio.com/ide/download/server
  - 아래 명령으로 설치
  $ wget http://download2.rstudio.org/rstudio-server-0.97.551-x86_64.rpm
  $ sudo yum install --nogpgcheck rstudio-server-0.97.551-x86_64.rpm
* Rstudio server 시작
  - 시작 명령: /etc/init.d/rstudio-server start
  - 확인: 
    ps aux | grep rstudio
    497      21418  0.0  0.0 301844  2504 ?        Ssl  15:05   0:00 /usr/lib/rstudio-server/bin/rserver
  - netstat -nltp
    tcp        0      0 0.0.0.0:8787 확인
* chrome 설치 (desktop)
* 연결확인
  - telnet 210.108.181.117 8787
  - 연결이 안되면 서버에서 iptables를 죽이고 proxy세팅등이나 방화벽 해제등을 해야함
* Rstudio접속해서 확인
  - root계정은 Rstudio접속이 불가
  - 기타 계정은 home directory가 모두 /home 이하에 존재해야 함 (/home2 이런것 안됨)

-----------------------------------------------------------------------------------------------
* Rserve 실행 및 연결확인
  - Rserve를 모든 datanode에서 실행 (namenode 및 Rstudio server는 제외)
  - 각 datanode에 접속해서 아래 명령을 실행
      R CMD Rserv
  - ps axu | grep Rserve
root     30728  0.0  0.1 211224 28556 ?        Ss   15:20   0:00 /usr/lib64/R/bin/Rserve
  - netstat -nltp 
      tcp        0      0 0.0.0.0:6311                0.0.0.0:*                   LISTEN      30728/Rserve 확인


* Rstudio에서 아래 코드를 실행
==================================
library(RHive)
rhive.connect("127.0.0.1", 10001)
rhive.write.table(iris)
hive_tablename <- "iris"
query <- sprintf("SELECT sum(sepallength) AS c1, avg(sepalwidth) AS c2, min(petallength) AS c3, max(petalwidth) AS c4 FROM %s ORDER BY c1", hive_tablename)
cat(sprintf("Query: %s", query), sep="\n")
result <- rhive.query(query)

sumAllColumns <- function(prev, values) {
  values
}

# Map combine
sumAllColumns.partial <- function(values) {
  values
}

# Reduce iteration
sumAllColumns.merge <- function(prev, values) {
  values
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
rhive.query("SELECT species, 
  RA('sumAllColumns', sepallength, sepalwidth, petallength, petalwidth, 0.0) as aa 
FROM iris 
GROUP BY species")

==================================

















