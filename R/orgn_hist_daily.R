#!/usr/bin/Rscript  --vanilla 

# all message to stdout 
sink(stdout(), type="message")

library(RHive)
library(lubridate)
library(RMySQL)

library(RscriptUtils)

#################################################################################
# Historical Orgn
# Sales & NonSale
# Soap & UI
# logdate, orgn_id, orgn_name, orgn_cls, appls_cls, rho, p_value, freq, appls_count
#################################################################################
getHistoricalOrgn <- function(data, basedate, n=50)
{
  orgn_cls <- c("nonsales", "sales")
  appls_cls <- c("Soap", "Ui")

  iter <- expand.grid(orgn_cls, appls_cls)
  names(iter) <- c("orgn_cls", "appls_cls")

  fromdata <- gsub("-", "", as.character(as.Date(basedate, format="%Y%m%d")-30))
  day_flag <- ifelse(as.character(format(as.Date(basedate, format="%Y%m%d"), "%a")) %in% c("Sat", "Sun"),
               "weekend", "weekday")

  data <- data[data$logdate>=fromdata & data$logdate<=basedate, ]
  data$day_flag <- ifelse(as.character(format(as.Date(as.character(data$logdate), format="%Y%m%d"), "%a")) %in% c("Sat", "Sun"),
               "weekend", "weekday")
  data <- data[data$day_flag==day_flag, ]

  results <- data.frame(log_dt=character(0), log_mt=character(0), orgn_id=character(0), orgn_nm=character(0),
             bm_id=character(0), bb_id=character(0), cn_id=character(0), js_id=character(0), drj_id=character(0), 
             bm_nm=character(0), bb_nm=character(0), cn_nm=character(0), js_nm=character(0), drj_nm=character(0),
             sales_cls=character(0), app_cls=character(0), rho=numeric(0), pvalue=numeric(0), freq=numeric(0),
             unq_svc_cnt=numeric(0), create_dt=character(0), modify_dt=character(0))

  for (i in 1:NROW(iter)) {
    chunk <- data[data$orgn_cls==iter$orgn_cls[i] & data$appls_cls==iter$appls_cls[i] , 
    c("logdate", "orgn_id", "orgn_name", "appls_code", "freq")]

    if (NROW(chunk)==0) next

    orgn_id <- as.character(chunk[chunk$logdate==basedate, "orgn_id"])
    orgn_id <- unique(orgn_id)
    chunk <- chunk[as.character(chunk$orgn_id) %in% orgn_id, ]

    if (NROW(chunk)==0) next
    m <- length(orgn_id)

    on.exit({print(orgn_id)
            print(iter[i])}) 
    result <- data.frame(log_dt=character(m), log_mt=character(m), orgn_id=orgn_id, orgn_nm=character(m), 
             bm_id=character(m), bb_id=character(m), cn_id=character(m), js_id=character(m), drj_id=character(m), 
             bm_nm=character(m), bb_nm=character(m), cn_nm=character(m), js_nm=character(m), drj_nm=character(m),
             sales_cls=character(m), app_cls=character(m), rho=numeric(m), pvalue=numeric(m), freq=numeric(m),
             unq_svc_cnt=numeric(m), create_dt=character(m), modify_dt=character(m), stringsAsFactors=FALSE)

    for (j in 1:length(orgn_id)) {
      indivisual <- chunk[chunk$orgn_id==orgn_id[j], ]    

#if (NROW(indivisual[indivisual$logdate==basedate,])==0) next
      if (NROW(indivisual[indivisual$logdate!=basedate,])==0) {
        basecase <- indivisual[indivisual$logdate==basedate, c("appls_code", "freq")]
        appls_cnt <- length(unique(basecase$appls_code))
        freq <- sum(basecase$freq)

        result[j, ] <- c(basedate, substr(basedate,1,6), as.character(orgn_id[j]), 
                unique(as.character(indivisual$orgn_name)), '','','','','','','','','','', 
                toupper(as.character(iter$orgn_cls[i])), toupper(as.character(iter$appls_cls[i])), 
                1, 0, freq, appls_cnt,'','')
        next
      }

      services <- aggregate(freq ~ appls_code, data=indivisual, sum, subset=logdate!=basedate)  
      services <- services[order(services$freq, decreasing=T), ]
      m <- NROW(services)  
      services$newapp <- ifelse(services[,"appls_code"] %in% as.character(services[1:min(m, n), "appls_code"]),
      as.character(services[,"appls_code"]), "etc")
      services <- aggregate(freq ~ newapp, data=services, sum)
      names(services) <- c("newapp", "tot_freq")

      basecase <- indivisual[indivisual$logdate==basedate, c("appls_code", "freq")]
      appls_cnt <- length(unique(basecase$appls_code))
      basecase$newapp <- ifelse(basecase[,"appls_code"] %in% as.character(services[, "newapp"]),  
      as.character(basecase[,"appls_code"]), "etc")
      basecase <- aggregate(freq ~ newapp, data=basecase, sum)
      freq <- sum(basecase$freq)

      dat <- merge(services, basecase, all=T)

      if (NROW(dat) < 3) {
        result[j, ] <- c(basedate, substr(basedate,1,6), as.character(orgn_id[j]), unique(as.character(indivisual$orgn_name)), 
                      '','','','','','','','','','', toupper(as.character(iter$orgn_cls[i])), 
                      toupper(as.character(iter$appls_cls[i])), 1, 1, freq, appls_cnt,'','')
        next
      }

      test_result <- cor.test(dat[,2], ifelse(is.na(dat[,3]), 0 ,dat[,3]), method="spearman", alternative="less")

      rho <- round(test_result$estimate, 5)
      pvalue <- round(test_result$p.value, 5)

      result[j, ] <- c(basedate, substr(basedate,1,6), as.character(orgn_id[j]), unique(as.character(indivisual$orgn_name)), 
                      '','','','','','','','','','', toupper(as.character(iter$orgn_cls[i])), 
                      toupper(as.character(iter$appls_cls[i])), rho, pvalue, freq, appls_cnt,'','')

    }
    results <- rbind(results, result)
  }

  results <- results[results$freq>0, ]
  return(results)
}

time_msg <- function(msg, conn=stdout()){
  new_msg <- paste(strftime(now(), "[%Y-%m-%d %H:%M:%S]"), msg)
  write(new_msg, conn)
}

check_results <- function (checksum, msg) {
  if(!checksum) {
    time_msg(paste("Fails on", msg), conn=stderr())
    q(status=1)
  }
}


# 0. Preparation -------------------------------------------------------------

args <- commandArgs(TRUE)
HIVE_MASTER = "10.220.177.26"

basedate <- args[1]
limit <- 0.05

###########################################################
# appls_ID  code split
# Input : logdate, appls_id, appls_code
# Output : logdate, appls_id, appls_code, appls_cls, short_code
###########################################################

rhive.connect(HIVE_MASTER)
hist_orgn <- rhive.load.table2("jennifer_orgn_hist_tmp")
time_msg("Import jennifer_orgn_hist_tmp")

detail <- data.frame(log_dt=character(0), 
                     log_mt=character(0), 
                     orgn_id=character(0), 
                     orgn_nm=character(0),
                     bm_id=character(0), 
                     bb_id=character(0), 
                     cn_id=character(0), 
                     js_id=character(0), 
                     drj_id=character(0),
                     bm_nm=character(0), 
                     bb_nm=character(0), 
                     cn_nm=character(0), 
                     js_nm=character(0), 
                     drj_nm=character(0),
                     appls_code=character(0), 
                     appls_cls=character(0), 
                     comp_rank=numeric(0), 
                     comp_freq=numeric(0), 
                     rank=numeric(0), 
                     freq=numeric(0), 
                     create_dt=character(0), 
                     modify_dt=character(0))

hist_orgn_result <- getHistoricalOrgn(hist_orgn, basedate, n=100)

drv <- dbDriver("MySQL")
con <- dbConnect(drv, user = "nlog", password="nlog1234", host = "10.220.177.27", dbname="nstepDB")

# Trend data truncation on RDBMS 
delete <- sprintf("delete from Orgn_Anomaly_Trend where LOG_DT = '%s'", basedate)
print(delete)
dbGetQuery(con, delete)

hist_orgn_result <- hist_orgn_result[hist_orgn_result$pvalue<=limit, ]

if (NROW(hist_orgn_result)>=1) {
  ret <- dbWriteTable(con, name="Orgn_Anomaly_Trend", value=hist_orgn_result, append=TRUE, row.names=FALSE)
  print(ret)
}

time_msg("Export Orgn_Anomaly_Daily")

# Detail trunctation on RDBMS
delete <- sprintf("delete from Orgn_Anomaly_Detail where LOG_DT = '%s'", basedate)
print(delete)
#dbGetQuery(con, delete)

#if (NROW(detail)>=1) {
#  ret <- dbWriteTable(con, name="Orgn_Anomaly_Detail", value=detail, append=TRUE, row.names=FALSE)
#  print(ret)
#}

time_msg("Export Orgn_Anomaly_Detail")

time_msg("Sucessifully Processed!")
q(status=0)

