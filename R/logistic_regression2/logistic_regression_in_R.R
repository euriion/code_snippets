# =========================================================
# Logistic Regression in R - technote
#   * author: Seonghak Hong (euriion@gmail.com)
# =========================================================

# ---------------------------------------------------------
# Excel data is available in below site
# 김성수 교수님 사이트
# http://faculty.knou.ac.kr/~sskim
# ---------------------------------------------------------
# Sys.setenv(JAVA_HOME="C:\\Program Files\\Java\\jdk1.8.0_05")
# install.packages("rJava")
# install.packages("xlsx")
library(rJava)
library(xlsx)
drug.data <- read.xlsx("./drug.xlsx", 1)
# attach(drug.data)
plot(drug.data$age, drug.data$purchase, pch=19)
# 플롯상으로 age가 높을 수록 y=1에 속하는 것이 많으나 
# 이것만으로는 명확한 관계를 보기 어려움
# 나이를 그룹화해서 해결을 시도
agr <- drug.data$age
agr[agr >= 20 & agr <= 29] <- 1
agr[agr >= 30 & agr <= 34] <- 2
agr[agr >= 35 & agr <= 39] <- 3
agr[agr >= 40 & agr <= 44] <- 4
agr[agr >= 45 & agr <= 49] <- 5
agr[agr >= 50 & agr <= 54] <- 6
agr[agr >= 55 & agr <= 59] <- 7
agr[agr >= 60 & agr <= 65] <- 8

purchase.table <- table(agr, drug.data$purchase)
purchase.table
percent.table <- prop.table(purchase.table, 1)
perc.1 <- percent.table[,2]
agr.1 <- rownames(percent.table)
agr.1 <- as.numeric(agr.1)
plot(agr.1, perc.1, pch=19)
# agr과purchase의 scatter plot. S-shape형태의 플롯이 도출

# ---------------------------------------------------------
# 로지스틱 회귀의 구조 및 정의
# ---------------------------------------------------------
# 로지스틱함수는 종속변수 Y가 0 또는 1의 두 개의 값을 갖고, 독립변수 X가 하나인 경우,
# 주어진 X에서 Y가 1일 확률을 P(Y=1|x)라고 하고,
# X가 증가함에 따라 Y가 1에 수렴하고 X가 감소함에 따라 0에 수렴하는 S형태의 함수를
# 로지스틱 함수라 함을 기억한다
# 식은 다음과 같음
# Latex: P(Y=1|X) = \frac{\exp{(\beta_0+\beta_1X)}}{1+\exp{(\beta_0+\beta_1X)}}
# 자연로그로 우변의 exp를 제거하면 선형화가 가능하다
# \ln\left(\frac{p}{1-p}\right) = \beta_0 + \beta_1X
# 여기서 좌변의
# p/1-p를 Odds(오즈)라고 한다
# 이에 의해 독립변수(feature)가 2개 이상인 경우에도 로지스틱 회귀가 가능하다.
# 식은 다음과 같다
# \ln\left(\frac{p}{1-p}\right) = \beta_0 + \beta_1X_1 + \beta_2X_2 + \dots + \beta_pX_p

# ---------------------------------------------------------
# 잔디깎기 기계의 소유자여부 데이터를 통한 로지스틱 회귀 분석
# data: 수입과 집의 면적에 따른 잔디깎기 기계 보여 여부
# ---------------------------------------------------------
library(xlsx)
mower.data <- read.xlsx("./mower.xlsx", 1)
head(mower.data)
mower.logit <- glm(owner ~ . , family=binomial, data=mower.data)
mower.logit.summary <- summary(mower.logit)
# attributes(mower.logit.summary)  # summary에 속성들이 있으므로 참조할 것
mower.logit.summary
# PR(p-value)이 유의수준 알파 0.05이하이면 적합되었다고 볼 수 있다
# Null deviance는 상수항만 가지고 피팅한 것에 대한 통계량이며
# Residual deviance는 독립변수를 이용해 피팅한 것에 대한 통계량
# 귀무가설 H_0는 모델이 적합함이며 대립가설 H_1는 모델이 부적합

# 1-pchisq(mower.logit.summary$deviance, mower.logit.summary$df.residual)
# 1-pchisq(mower.logit.summary$null.deviance -mower.logit.summary$deviance, mower.logit.summary$df.residual)
# 주어진 자유도를 사용할 것
# 경우에 따라 mower.logit.summary$null.deviance -
if (1-pchisq(mower.logit.summary$deviance, mower.logit.summary$df.residual) > 0.05) {
  print("model is fit")
}

# ---------------------------------------------------------
# Odds ratio를 구한다
# ---------------------------------------------------------
exp(cbind(coef(mower.logit), confint(mower.logit)))

# prediction 수행
mower.predict <- predict(mower.logit, newdata=mower.data, type="response")
pred <- ifelse(mower.predict < 0.5, "no", "yes")
pred <- factor(pred)
# confusion matrix 도출
confusion.matrix <- table(mower.data$owner, pred)
# 에러율 구하기
error <- 1 - (sum(diag(confusion.matrix)/sum(confusion.matrix)))

confusion.matrix
error

# ---------------------------------------------------------
# pROC를 이용한 ROC커브
# ---------------------------------------------------------
# install.packages("pROC")
library("pROC")
mower.data.result <- mower.data
mower.data.result$pred <- mower.predict
g <- roc(owner ~ pred, data = mower.data.result)
plot(g)

# ---------------------------------------------------------
# ROCR을 이용한 ROC커브 및 성능 테스트
# ---------------------------------------------------------
install.packages("ROCR")
library(ROCR)
preds <- prediction(as.numeric(mower.data.result$pred), as.numeric(mower.data$owner))

perf.auc <- performance(preds, "auc")
aucvalue <- unlist(slot(perf.auc, "y.values"))

perf.tpr <- performance(preds, "tpr", "fpr")
plot(perf.tpr, colorize=T)

perf.fpr <- performance(preds,"fpr") # find list of fp rates
perf.fnr <- performance(preds,"fnr") # find list of fn rates

perf.pr <- performance(preds, "prec", "rec")
plot(perf.pr, colorize=T)

perf.acc <- performance(preds, "acc")
plot(perf.acc, avg= "vertical", spread.estimate="boxplot", show.spread.at= seq(0.1, 0.9, by=0.1))

acc.rocr<-max(perf.acc@y.values[[1]])   # accuracy using rocr
#find cutoff list for accuracies
cutoff.list.acc <- unlist(perf.acc@x.values[[1]])
#find optimal cutoff point for accuracy
optimal.cutoff.acc <- cutoff.list.acc[which.max(perf.acc@y.values[[1]])]
#find optimal cutoff fpr, as numeric because a list is returned
optimal.cutoff.fpr <- which(perf.fpr@x.values[[1]]==as.numeric(optimal.cutoff.acc))
# find cutoff list for fpr
cutoff.list.fpr <- unlist(perf.fpr@y.values[[1]])
# find fpr using rocr
fpr.rocr <- cutoff.list.fpr[as.numeric(optimal.cutoff.fpr)]

#find optimal cutoff fnr
optimal.cutoff.fnr<-which(perf.fnr@x.values[[1]]==as.numeric(optimal.cutoff.acc))
#find list of fnr
cutoff.list.fnr <- unlist(perf.fnr@y.values[[1]])
#find fnr using rocr
fnr.rocr<-cutoff.list.fnr[as.numeric(optimal.cutoff.fnr)]

perf.pcmiss <- performance(preds, "pcmiss","lift")
plot(perf.pcmiss, colorize=T, print.cutoffs.at=seq(0,1,by=0.1), text.adj=c(1.2,1.2), avg="threshold", lwd=3)

plot(perf.tpr, main="ROC Curve", lwd=2, col="darkgreen")
text(0.5, 0.5, paste0("AUC = ",aucvalue), cex=2.2, col="darkred")

plot(perf.pr, main="ROC Curve", lwd=2, col="darkgreen")
text(0.5, 0.5, paste0("AUC = ",aucvalue), cex=2.2, col="darkred")

# Total cutoff plotting을 위한 시뮬레이션 데이터
# http://www.r-bloggers.com/sab-r-metrics-logistic-regression/
# x = matrix(rnorm(30000),10000,3)
# lp = 0 + x[,1] - 1.42*x[2] + .67*x[,3] + 1.1*x[,1]*x[,2] - 1.5*x[,1]*x[,3] +2.2*x[,2]*x[,3] + x[,1]*x[,2]*x[,3]
# p = 1/(1+exp(-lp))
# y = runif(10000)<p
# mod = glm(y~x[,1]*x[,2]*x[,3],family="binomial")

perf <- function(cutoff, model, y, class_labels)
{
  yhat = (model$fit > cutoff)
  w = which(y == class_labels[1])
  sensitivity = mean( yhat[w] == 1 )
  specificity = mean( yhat[-w] == 0 )
  c.rate = mean( y==yhat )
  d = cbind(sensitivity,specificity)-c(1,1)
  d = sqrt( d[1]^2 + d[2]^2 )
  out = t(as.matrix(c(sensitivity, specificity, c.rate,d)))
  colnames(out) = c("sensitivity", "specificity", "c.rate", "distance")
  return(out)
}

cutoff_sequences <- seq(.01, .99, length=1000)
outputs = matrix(0, 1000, 4)
for(i in 1:1000) {
  outputs[i,] <- perf(cutoff_sequences[i], mower.logit, mower.data$owner, c("yes", "no"))
}
plot(cutoff_sequences, outputs[,1], xlab="Cutoff", ylab="Value", cex.lab=1.5, cex.axis=1.5, ylim=c(0, 1), type="l", lwd=2, axes=FALSE, col=2)
axis(1, seq(0, 1,length=5), seq(0, 1, length=5), cex.lab=1.5)
axis(2, seq(0, 1,length=5), seq(0, 1, length=5), cex.lab=1.5)
lines(cutoff_sequences, outputs[,2], col="darkgreen", lwd=2)
lines(cutoff_sequences, outputs[,3], col=4, lwd=2)
lines(cutoff_sequences, outputs[,4], col="darkred", lwd=2)
box()
legend(0, .25, col=c(2,"darkgreen", 4, "darkred"), lwd=c(2,2,2,2), c("Sensitivity", "Specificity", "Classification Rate", "Distance"))

# ---------------------------------------------------------
# install.packages("Epi")
library(Epi)

x <- rnorm( 100 )
z <- rnorm( 100 )
w <- rnorm( 100 )
tigol <- function( x ) 1 - ( 1 + exp( x ) )^(-1)
y <- rbinom( 100, 1, tigol( 0.3 + 3*x + 5*z + 7*w ) )
rc <- ROC( form = y ~ x + z, plot="sp" ) 
## optimal combination
opt <- which.max(rowSums(rc$res[, c("sens", "spec")]))
## optimal cut-off point 
rc$res$lr.eta[opt]

# ---------------------------------------------------------
# 추가테크노트
# ---------------------------------------------------------
# 잔차 자유도는 로지스틱에서는 차원의 수 만큼(변수의 개수) 빠진다

# * 로지스틱 회귀분석의 R^2 해석은 선형분석에서의 해석과 다름
#   * 종속변수가 범주형이므로, 오차의 등분산성 가정이 만족 되지 않음
#   * 오차분산이 예측된 확률에 따라 달라짐
# 	*  Var(e_i) = p_i x (1-p_i)
# 	*  종속변수의 값에 따라 R^2 값이 변하므로 종속변수의 R^2와 같이 해석할 수 없음
# 	*  또한, 로지스틱 회귀분석에서 R^2값은 대개 낮게 나오는 편이므로, 모형평가에서 R^2에 너무 의존할 필요가 없음
#
# * 로지스틱 회귀계수의 검증
# 	* t-distribution, chi-square distribution 모두 표집분포
# 	* 유의성검증
# 	* 선형 회귀분석 : t검증 ~ t
# 	* 로지스틱 회귀분석 : Wald ~ chi-square : 자유도 1인 카이스퀘어 분포를 따른다. Chi-square 또는 wald 검증이라고 부른다.
# 	* Wald 검증의 문제점
# 	* 로지스틱 회귀계수의 절대값이 큰 경우, 표준오차도 따라서 커지는 경향이 음
# 	* 따라서 회귀계수의 절대값이 크면 Wald 검증에만 의존할 것이 아니라,
#     해당 변수를 포함하지 않은 모형과 포함한 모형의 	-2LL 차이를 구하고
#     그 차이값이 자유도 1에서 유의미한지 우도비 검증(LR test)도 실시해야함
# likelihood.test를 수행해야 하는데 독립변수를 점증적으로 추가하면서 필요없는 변수를 제거하는 것도 겸한다
# * F test할 때 변수 하나 넣었을 때, 변수 하나가 통계적으로 유의하면 변수 test안해도 된다. 하나만 넣었을 때 하나의 변수가 통계적으로 유의미한 변수라고 하면,
# F test하면 변수 하나 추가된 모델이 더 좋은 모델이다.
#
# * Wald 검증과 우도비 검증 비교
# 	* 공통점 : 자유도 1에서 chi-square 검증을 한다.
# 	* Wald 검증과 우도비 검증은 표본이 커질수록 결과가 일치한다.
# 	* 하지만 한정된 표본크기를 이용하면 두 검증으로부터 얻은 결과는 다를 수도 있다. : 그럼 Wald 쓸까 -2LL 쓸까? 할 수 있는데, Wald보다는 -2LL을 지지하는 편이다.
# 	* 어느 검증을 사용할 것인가? : 더 많은 학자들이 우도비 검증을 지지한다.
# 	* 이런 경우는 표본의 크기가 크지 않은 상황이다. 그 상황에서는 우도비 검증을 따른다.
#
# * 로지스틱 회귀계수의 표준화
# 	*  output보면 표준화회귀계수값 보고 하지 않음
# 	*  통계 프로그램에서 로지스틱 회귀계수에 대한 표준화 값을 제공해 주지 않을 뿐만 아니라
# 	*  표준화된 값에 대한 해석 역시 선형 회귀분석에서처럼 간단하지 않음
# 	*  로짓에 대한 표준편차를 구해야 함 (복잡. 두번 세번 transform한 것에 대해서 구해야 ㅎ함)
# 	*  위계선형모형도 SAS를 쓰면 간편하게 돌릴 수 있음
# 	*  Cf. 선형 회귀분석에서는 비표준화 계수(b)에 SDx/SDy를 곱해서 표준화 계수 도출
# 	*  Beta = b(SD_x/SD_y)