# Finance forecase example
library(RHive)
library(forecast)

rhive.connect("192.168.93.11", 10001, "hdfs://192.168.93.11:9000", c(), FALSE, FALSE)
rhive.query("use bank")
rhive.query("show tables")

# Loading data
deposit <- read.csv("DEPOSIT.csv")
loan <- read.csv("LOAN.csv")


##################################################################
# 1-1) 수신금액이 1천만원 이상이고, 만기 이전에 중도해지가 일어난 건
##################################################################
hql <- ""
hql <- paste(hql, "select a.*")
hql <- paste(hql, "  from deposit a join (")
hql <- paste(hql, "    select distinct x.account, x.expiration")  
hql <- paste(hql, "    from deposit x join (select account, expiration") 
hql <- paste(hql, "                         from deposit")
hql <- paste(hql, "                         where bamount = 0")
hql <- paste(hql, "                         and expiration <> turn) y")
hql <- paste(hql, "    on (x.account = y.account and x.expiration = y.expiration)")
hql <- paste(hql, "    where x.bamount >= 10000) b")
hql <- paste(hql, "on (a.account = b.account and a.expiration = b.expiration)")
hql <- paste(hql, "order by account, basedata")

deposit_expr <- rhive.query(hql)
deposit_expr

##################################################################
# 1-2) 여신금액이 7백만원 이상이고, 만기 이전에 조기상환이 일어난 건
##################################################################
hql <- ""
hql <- paste(hql, "select a.*")
hql <- paste(hql, "  from loan a join (")
hql <- paste(hql, "    select distinct x.account, x.expiration")  
hql <- paste(hql, "    from loan x join (select account, expiration") 
hql <- paste(hql, "                         from loan")
hql <- paste(hql, "                         where bamount = 0")
hql <- paste(hql, "                         and expiration <> turn) y")
hql <- paste(hql, "    on (x.account = y.account and x.expiration = y.expiration)")
hql <- paste(hql, "    where x.bamount >= 7000) b")
hql <- paste(hql, "on (a.account = b.account and a.expiration = b.expiration)")
hql <- paste(hql, "order by account, basedata")

loan_expr <- rhive.query(hql)
loan_expr

##################################################################
# 2. 데이터 신규변수 생성
#   1) 회차 % = 회차/만기
#   2) 단위 조정 = 회차 * 1000
##################################################################
hql <- ""
hql <- paste(hql, "select basedata")
hql <- paste(hql, "      ,ramount")  	
hql <- paste(hql, "      ,bamount")		
hql <- paste(hql, "      ,iamount")		
hql <- paste(hql, "      ,extracost")
hql <- paste(hql, "      ,account")		
hql <- paste(hql, "      ,expiration")		
hql <- paste(hql, "      ,turn")
hql <- paste(hql, "      ,round(turn/expiration*100, 2) as pturn")
hql <- paste(hql, "      ,turn * 1000 as uturn") 
hql <- paste(hql, " from deposit")
hql <- paste(hql, "limit 100")

deposit_der <- rhive.query(hql)
deposit_der

##################################################################
# 3. 그룹핑 자료 생성
#   1) 기준일별 계좌수 및 잔액 추이, 이자금액 추이 
##################################################################
hql <- ""
hql <- paste(hql, "select basedata") 	
hql <- paste(hql, "      ,count(account) as account_cnt")
hql <- paste(hql, "      ,sum(bamount) as bamount")
hql <- paste(hql, "      ,sum(iamount) as iamount")
hql <- paste(hql, "  from loan")
hql <- paste(hql, " group by basedata")

loan_sum <- rhive.query(hql)
loan_sum 

##################################################################
# 4. 기본 통계(평균, 분산, 상관분석, 챠트그리기, 테이블 만들기) 
#   1) 기준일별 평균 및 분산
##################################################################
hql <- ""
hql <- paste(hql, "select basedata")   
hql <- paste(hql, "      ,avg(bamount) as bamount_avg")
hql <- paste(hql, "      ,var_samp(bamount) as bamount_var")
hql <- paste(hql, "  from loan")
hql <- paste(hql, " group by basedata")

loan_agg<- rhive.query(hql)
loan_agg 

##################################################################
# 4. 기본 통계(평균, 분산, 상관분석, 챠트그리기, 테이블 만들기) 
#   2) 여신잔액 시계열과 수신잔액 시계열간의 상관관계
##################################################################
hql <- ""
hql <- paste(hql, "select covar_samp(bamount_loan, bamount_deposit) as corr_amt")
hql <- paste(hql, " from")
hql <- paste(hql, "(select basedata")
hql <- paste(hql, "       ,sum(bamount) as bamount_loan")
hql <- paste(hql, "   from loan")
hql <- paste(hql, "  group by basedata) x join")
hql <- paste(hql, "(select basedata")
hql <- paste(hql, "       ,sum(bamount) as bamount_deposit")
hql <- paste(hql, "   from deposit")
hql <- paste(hql, "  group by basedata) y")
hql <- paste(hql, "     on (x.basedata = y.basedata)")

#amt_corr<- rhive.query(hql)
#amt_corr 
#corr_amt
#0.9907132

hql <- ""
hql <- paste(hql, "select bamount_loan, bamount_deposit")
hql <- paste(hql, " from")
hql <- paste(hql, "(select basedata")
hql <- paste(hql, "       ,sum(bamount) as bamount_loan")
hql <- paste(hql, "   from loan")
hql <- paste(hql, "  group by basedata) x join")
hql <- paste(hql, "(select basedata")
hql <- paste(hql, "       ,sum(bamount) as bamount_deposit")
hql <- paste(hql, "   from deposit")
hql <- paste(hql, "  group by basedata) y")
hql <- paste(hql, "     on (x.basedata = y.basedata)")

amts <- rhive.query(hql)

plot(amts, pch=16, main="Loan vs Deposit", xlab="loan", ylab="deposit")

cor(amts[,1], amts[,2])
cor.test(amts[,1], amts[,2])

panel.hist <- function(x, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col="cyan", ...)
}
pairs(amts, panel=panel.smooth,
      cex = 1.5, pch = 24, bg="light blue",
      diag.panel=panel.hist, cex.labels = 2, font.labels=2)


##################################################################
# 4. 기본 통계(평균, 분산, 상관분석, 챠트그리기, 테이블 만들기) 
#   3) 조기상환율 (기준일별) 조기상환건수/전체건수
#      중도해지율  (기준일별) 중도해지건수/전체건수 
##################################################################
hql <- ""
hql <- paste(hql, "select")
hql <- paste(hql, "       x.basedata")
hql <- paste(hql, "      ,count(x.account) as loan_cnt")
hql <- paste(hql, "      ,count(y.account) as prior_redemption_cnt")
hql <- paste(hql, "      ,count(y.account)/count(x.account) as prior_redemption_ratio")
hql <- paste(hql, "  from loan x left outer join (select account, basedata")
hql <- paste(hql, "                                 from loan")
hql <- paste(hql, "                                where bamount = 0")
hql <- paste(hql, "                                  and expiration <> turn) y")
hql <- paste(hql, "    on (x.account = y.account and x.basedata = y.basedata)")
hql <- paste(hql, " group by x.basedata")

prior_redemption_ratio <- rhive.query(hql)
prior_redemption_ratio


hql <- ""
hql <- paste(hql, "select")
hql <- paste(hql, "       x.basedata")
hql <- paste(hql, "      ,count(x.account) as deposit_cnt")
hql <- paste(hql, "      ,count(y.account) as drop_out_cnt")
hql <- paste(hql, "      ,count(y.account)/count(x.account) as drop_out_ratio")
hql <- paste(hql, "  from deposit x left outer join (select account, basedata")
hql <- paste(hql, "                                 from deposit")
hql <- paste(hql, "                                where bamount = 0")
hql <- paste(hql, "                                  and expiration <> turn) y")
hql <- paste(hql, "    on (x.account = y.account and x.basedata = y.basedata)")
hql <- paste(hql, " group by x.basedata")

drop_out_ratio <- rhive.query(hql)
drop_out_ratio


##################################################################
# 4. 기본 통계(평균, 분산, 상관분석, 챠트그리기, 테이블 만들기) 
#   4) 신규증가율 (기준일별) 신규건수/전체건수
##################################################################
hql <- ""
hql <- paste(hql, "select")
hql <- paste(hql, "       x.basedata")
hql <- paste(hql, "      ,sum(1) as loan_cnt")
hql <- paste(hql, "      ,sum(case when turn=0 then 1 else 0 end) as new_cnt")
hql <- paste(hql, "      ,sum(case when turn=0 then 1 else 0 end)/sum(1) as new_loan_ratio")
hql <- paste(hql, "  from loan x")
hql <- paste(hql, "group by x.basedata")

new_loan_ratio <- rhive.query(hql)
new_loan_ratio


hql <- ""
hql <- paste(hql, "select")
hql <- paste(hql, "       x.basedata")
hql <- paste(hql, "      ,sum(1) as deposit_cnt")
hql <- paste(hql, "      ,sum(case when turn=0 then 1 else 0 end) as new_cnt")
hql <- paste(hql, "      ,sum(case when turn=0 then 1 else 0 end)/sum(1) as new_deposit_ratio")
hql <- paste(hql, "  from deposit x")
hql <- paste(hql, "group by x.basedata")

new_deposit_ratio <- rhive.query(hql)
new_deposit_ratio


##################################################################
# 4. 기본 통계(평균, 분산, 상관분석, 챠트그리기, 테이블 만들기) 
#   5) 만기연장율 산출 (기준일별) 만기연장건수/만기도래건수
##################################################################
hql <- ""
hql <- paste(hql, "select a.basedata")
hql <- paste(hql, ",sum(a.due_cnt) as due_cnt")
hql <- paste(hql, ",sum(case when b.account_cnt = 2 then 1 else 0 end) as renew_cnt")
hql <- paste(hql, ",sum(case when b.account_cnt = 2 then 1 else 0 end)/sum(a.due_cnt) as renew_ratio")
hql <- paste(hql, "from (select x.basedata")
hql <- paste(hql, "      ,sum(case when expiration=turn then 1 else 0 end) due_cnt")
hql <- paste(hql, "      from loan x")
hql <- paste(hql, "      group by x.basedata) a join") 
hql <- paste(hql, "(select x.basedata")
hql <- paste(hql, " ,x.account")
hql <- paste(hql, " ,count(*) account_cnt")
hql <- paste(hql, " from loan x")
hql <- paste(hql, " group by x.basedata, x.account) b")
hql <- paste(hql, "on (a.basedata = b.basedata)")
hql <- paste(hql, "group by a.basedata")

renew_ratio <- rhive.query(hql)
renew_ratio

###########################################################################
# 4. 기본 통계(평균, 분산, 상관분석, 챠트그리기, 테이블 만들기) 
#   6) 기준일별 순이자마진율  (여신이자금액 – 수신이자금액 ) / 여신 잔액
###########################################################################
hql <- ""
hql <- paste(hql, "select x.basedata")
hql <- paste(hql, "      ,sum(bamount_loan) as bamount_loan")
hql <- paste(hql, "      ,sum(iamount_loan) as iamount_loan")
hql <- paste(hql, "      ,sum(iamount_deposit) as iamount_deposit")
hql <- paste(hql, "      ,sum(bamount_loan-iamount_deposit)/sum(bamount_loan) as margin")
hql <- paste(hql, "  from")
hql <- paste(hql, " (select basedata")
hql <- paste(hql, "        ,sum(bamount) as bamount_loan")
hql <- paste(hql, "        ,sum(iamount) as iamount_loan")
hql <- paste(hql, "    from loan")
hql <- paste(hql, "   group by basedata) x join")
hql <- paste(hql, " (select basedata")
hql <- paste(hql, "        ,sum(iamount) as iamount_deposit")
hql <- paste(hql, "    from deposit")
hql <- paste(hql, "   group by basedata) y")
hql <- paste(hql, "      on (x.basedata = y.basedata)")
hql <- paste(hql, "   group by x.basedata")

margin <- rhive.query(hql)
margin


##################################################################
# 5. 고급 통계(군집분석, Regression, Forecasting, Optimization) 
#   1) 여신잔액 시계열로 향후 12개월 여신 잔액 예측 (ARIMA)
##################################################################
(fit <- auto.arima(amts[, 1]))
(loan_12 <- forecast(fit, h=12))
plot(loan_12)


##################################################################
# 5. 고급 통계(군집분석, Regression, Forecasting, Optimization) 
#   2) 수신잔액 시계열로 향후 12개월 수신 잔액 예측 (ARIMA)
##################################################################
(fit <- auto.arima(amts[, 2]))
(diposit_12 <- forecast(fit, h=12))
plot(diposit_12)


#####################################################################################################
# 5. 고급 통계(군집분석, Regression, Forecasting, Optimization) 
#   3) 2012년 순이자마진율을 1%p 높이기 위해 필요한 여신 금리 인상분 계산 혹은 수신금리 인하분 계산
#####################################################################################################
margin

fit <- auto.arima(margin[, "bamount_loan"])
bamount_loan <- forecast(fit, h=84)
bamount_loan <- as.data.frame(bamount_loan)[, 1][73:84]

fit <- auto.arima(margin[, "iamount_loan"])
iamount_loan <- forecast(fit, h=84)
iamount_loan <- as.data.frame(iamount_loan)[, 1][73:84]

fit <- auto.arima(margin[, "iamount_deposit"])
iamount_deposit <- forecast(fit, h=84)
iamount_deposit <- as.data.frame(iamount_deposit)[, 1][73:84]

# (여신잔액 * x –수신이자금액)/여신잔액 - (여신이자금액–수신이자금액)/여신잔액  = 0.01
# (여신잔액 * x –수신이자금액) - (여신이자금액–수신이자금액) = 0.01 * 여신잔액
# (여신잔액 * x –수신이자금액) = (여신이자금액–수신이자금액) + 0.01 * 여신잔액
# 여신잔액 * x = (여신이자금액–수신이자금액) + 0.01 * 여신잔액 + 수신이자금액
# x = ((여신이자금액–수신이자금액) + 0.01 * 여신잔액 + 수신이자금액) / 여신잔액

((sum(iamount_loan)-sum(iamount_deposit)) + 0.01 * sum(bamount_loan) + sum(iamount_deposit)) / sum(bamount_loan)



