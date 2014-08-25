detach("package:RHive", unload=T)  # RHive unloading if RHive is loaded already
library(RHive)  # RHive loading

rhive.connect(host="ds1")  # connect to Hive-Thrift server

# create a data.frame for an example
card_transaction <- read.table(text="customer,shop,auth_date,auth_time,cardno,class
cust1,shop1,20130415,161518,card01,reject
cust1,shop1,20130415,161519,card02,reject
cust1,shop1,20130415,161520,card03,reject
cust1,shop1,20130415,161521,card04,accept
cust1,shop1,20130415,162538,card02,reject
cust1,shop1,20130415,162539,card03,reject
cust1,shop1,20130415,162540,card04,accept
cust1,shop1,20130415,162541,card05,reject
cust2,shop3,20130416,041538,card11,reject
cust2,shop3,20130416,041548,card11,reject
cust2,shop3,20130416,041558,card12,reject
cust2,shop3,20130416,041641,card13,reject
cust2,shop3,20130416,041813,card14,accept
", sep=",", header=TRUE, colClasses=rep("character", 6))

# write data.frame to a Hive table
rhive.query("DROP TABLE IF EXIST card_transaction")
rhive.write.table(card_transaction)


# -------------------------------------------------------
# RHive UDAF functions 1 set (4 functions) and others
# -------------------------------------------------------

# Checking time diff between prior transaction and current transaction
isSeparatedSequence <- function(prev_dt, curr_dt) {
  diffSecs <- as.numeric(strptime(curr_dt, "%Y%m%d%H%M%S") - strptime(prev_dt, "%Y%m%d%H%M%S"), unit="secs")
  if (diffSecs <= 600) {
    return(FALSE)
  } else {
    return(T)
  }
}

# Global values to store values for iteration
prevDate <- ""
prevTime <- ""

# Map iteration
getTransactionSequence <- function(prevValues, currValues) {
  if(is.null(prevValues)) {
    prevDate <<- currValues[1]
    prevTime <<- currValues[2]
    paste(currValues, sep="", collapse=",")
  } else {
    if (isSeparatedSequence(paste(prevDate, prevTime, sep="", collapse=""), paste(currValues[1], currValues[2], sep="", collapse=""))) {  # new transaction
      prevDate <<- currValues[1]
      prevTime <<- currValues[2]
      # delimiter = '@'
      paste(c(prevValues, paste(currValues, sep="", collapse=",")), sep="", collapse="@")  
    } else {
      prevDate <<- currValues[1]
      prevTime <<- currValues[2]
      # delimiter = '|'
      paste(c(prevValues, paste(currValues, sep="", collapse=",")), sep="", collapse="|")  
    }    
  }
}

# Map aggregation
getTransactionSequence.partial <- function(mergedValues) {
  library(stringr)
  recordsRaw <- str_split(mergedValues, "@")
  records <- as.vector(recordsRaw[[1]])
  tidyRecords <- sapply(records, function(x) {
    splitX <- str_split(x, "[|]")
    paste(splitX[[1]][1], splitX[[1]][2], sep="|", collapse="")
  }, USE.NAMES=FALSE)
  paste(tidyRecords, sep="", collapse="@")
}

# Reduce iteration
getTransactionSequence.merge <- function(prevValues, currValues) {
  if(is.null(prevValues)) {
    prevDate <<- currValues[1]
    prevTime <<- currValues[2]
    paste(currValues, sep="", collapse=",")
  } else {
    if (isSeparatedSequence(paste(prevDate, prevTime, sep="", collapse=""), paste(currValues[1], currValues[2], sep="", collapse=""))) {  # new transaction
      prevDate <<- currValues[1]
      prevTime <<- currValues[2]
      # delimiter = '@'
      paste(c(prevValues, paste(currValues, sep="", collapse=",")), sep="", collapse="@")  
    } else {
      prevDate <<- currValues[1]
      prevTime <<- currValues[2]
      # delimiter = '|'
      paste(c(prevValues, paste(currValues, sep="", collapse=",")), sep="", collapse="|")  
    }    
  }
}

# Reduce aggregation
getTransactionSequence.terminate <- function(mergedValues) {
  library(stringr)
  recordsRaw <- str_split(mergedValues, "@")
  records <- as.vector(recordsRaw[[1]])
  tidyRecords <- sapply(records, function(x) {
    splitX <- str_split(x, "[|]")
    paste(splitX[[1]][1], splitX[[1]][2], sep="|", collapse="")
  }, USE.NAMES=FALSE)
  paste(tidyRecords, sep="", collapse="@")
}

# assigning functions and variables before deploying
rhive.assign("isSeparatedSequence", isSeparatedSequence)
rhive.assign("prevDate", prevDate)
rhive.assign("prevTime", prevTime)
rhive.assign("getTransactionSequence", getTransactionSequence)
rhive.assign("getTransactionSequence.partial", getTransactionSequence.partial)
rhive.assign("getTransactionSequence.merge", getTransactionSequence.merge)
rhive.assign("getTransactionSequence.terminate", getTransactionSequence.terminate)

# deploying all functions and variables which were assigned above
rhive.exportAll("getTransactionSequence")

# dropping old table
rhive.query("DROP TABLE card_trans_aggr")

# RHive hate No-MR, RHive like Yes-MR!!!
rhive.query("set hive.fetch.task.conversion=minimal")

# running the RHive UDAF
rhive.query("            
CREATE TABLE card_trans_aggr AS
  SELECT c.customer,
         c.shop,
         RA('getTransactionSequence',  -- RHive aggregation
            c.auth_date,
            c.auth_time,
            c.cardno,
            c.class) AS ra_value
  FROM (
    SELECT a.customer  AS customer,
           a.shop      AS shop,
           a.auth_date AS auth_date,
           a.auth_time AS auth_time,
           a.cardno    AS cardno,
           a.class     AS class
      FROM card_transaction a
    ORDER BY customer, shop, auth_date, auth_time
  ) c
GROUP BY c.customer, c.shop
")

# rhive.query('show functions')  # checking if RHive UDAF jar were deployed well
# rhive.query("desc card_trans_aggr")
rhive.query("SELECT * FROM card_trans_aggr")

# !! Yeah! Monkey magic!
rhive.query("
SELECT customer, 
       shop,
       SPLIT(SPLIT(c1, '[|]')[0], ',')[0] AS start_auth_date,  -- dirty string split
       SPLIT(SPLIT(c1, '[|]')[0], ',')[1] AS start_auth_time,  -- dirty string split
       SPLIT(SPLIT(c1, '[|]')[0], ',')[2] AS start_card,       -- dirty string split
       SPLIT(SPLIT(c1, '[|]')[0], ',')[3] AS start_class,      -- dirty string split
       SPLIT(SPLIT(c1, '[|]')[1], ',')[0] AS end_auth_date,    -- dirty string split
       SPLIT(SPLIT(c1, '[|]')[1], ',')[1] AS end_auth_time,    -- dirty string split
       SPLIT(SPLIT(c1, '[|]')[1], ',')[2] AS end_card,         -- dirty string split
       SPLIT(SPLIT(c1, '[|]')[1], ',')[3] AS end_class         -- dirty string split
FROM (
  SELECT customer, 
         shop, 
         regexp_replace(c1, \"'\", '') AS c1 
     FROM card_trans_aggr 
     LATERAL VIEW EXPLODE(SPLIT(ra_value, '@')) L AS c1
  ) a
")

# -- we can get off work now
