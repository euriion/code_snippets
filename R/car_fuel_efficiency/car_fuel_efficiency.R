# -------------------------------------------------------------------
# 필드명
# 번호, 모델명, 업체, 유종, 배기량, 공차중량, 변속형식, 연비(㎞/ℓ), 구등급, 신등급, CO2(g/㎞), 예상연료비(원)
# no, model, maker, fuletype, displacement, weight, transmissiontype, mileage, oldgrade, newgrade, co2, oilmoneyperyear
# 예상연료비는 1년간 16,000㎞의 주행조건을 기준으로 산출된 금액입니다.
# (휘발유 1,929.53원/ℓ, 경유 1,754.82원/ℓ, LPG 1,099.26원/ℓ)
# -------------------------------------------------------------------
Sys.setlocale("LC_ALL", "ko_KR.UTF-8")
library(RCurl)

webpage <- getURL("https://raw.githubusercontent.com/euriion/code_snippets/master/R/car_fuel_efficiency/car_fuel_efficiency.tsv", .encoding="UTF-8")
car_efficiency = read.table(file=textConnection(webpage), header=F, sep="\t", encoding="UTF-8", stringsAsFactors=FALSE)
colnames(car_efficiency) <- c("no", "model", "maker", "fueltype", "displacement", "weight", "transmissiontype", "mileage", "oldgrade", "newgrade", "co2", "oilmoneyperyear")

colnames(car_efficiency) <- c("no", "model", "maker", "fueltype", "displacement", "weight", "transmissiontype", "mileage", "oldgrade", "newgrade", "co2", "oilmoneyperyear")
car_efficiency$oilmoneyperyear <- as.numeric(gsub(",", "", car_efficiency$oilmoneyperyear))

# dim(car_efficiency)
# head(car_efficiency)
# plot(table(car_efficiency$mileage))

# 윈도 폰트 셋티
# WindowsFonts(fontfamily1=WindowsFont("맑은 고딕"))
# par(family="fontfamily1")
par(family="나눔고딕") # mac and linux
par(mar=c(12,1,1,1) + 0.1)
boxplot(mileage ~ maker, data=car_efficiency, las=2)
# dev.off()



par(family="나눔고딕") # mac and linux
par(mar=c(4,1,1,1) + 0.1)
boxplot(mileage ~ fueltype, data=car_efficiency, las=2)
# dev.off()

# checking outliers
car_efficiency[car_efficiency$maker %in% "(주)AD 모터스",]
car_efficiency[car_efficiency$maker %in% "한국토요타자동차㈜",]
car_efficiency$maker[grep("^한국", car_efficiency$maker)]

# =======================
# 히스토그램 확인 및 빈도 확인
dev.off()
#colnames(car_efficiency)
par(family="나눔고딕")
hist(car_efficiency$mileage)
hist(car_efficiency$co2)
hist(car_efficiency$weight)
barplot(table(car_efficiency$fueltype))
barplot(table(car_efficiency$newgrade))
barplot(table(car_efficiency$transmissiontype))

# ============================================================
# install.packages('reshape')
library(reshape2)
mat <- dcast(car_efficiency, maker ~ fueltype, mean, value.var='mileage', fill=0)
row.names(mat)  <- mat$maker
mat <- subset(mat, select=-maker)
mat <- as.matrix(mat)
dev.off()
par(mar=c(5,1,1,11))
par(family="나눔고딕") # mac and linux
heatmap(mat)

library(ggplot2)
library(scales)
car_df <- dcast(car_efficiency, maker ~ transmissiontype, mean, value.var='mileage', fill=0)
dev.off()
car_df.melt <- melt(car_df,id=c("maker"))
ggplot(car_df.melt, aes(x=variable, y=maker), fill=value) + 
  geom_tile(aes(fill=value)) + 
  scale_fill_gradient(low="white", high="steelblue") +
  theme(text=element_text(family="나눔고딕"))
# ====================================
# co2, 무게, 연비의 상호 관계를 살펴본다
dev.off()
colnames(car_efficiency)
car_df <- car_efficiency[,c("co2", "weight", "mileage")]
plot(car_df)

install.packages("scatterplot3d")
library(scatterplot3d)


attach(car_efficiency)
scatterplot3d(co2, weight, mileage,  
  main="car efficiency", highlight.3d=TRUE)
detach(car_efficiency)

# 한꺼번에 다 보자
panel.hist <- function(x, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col="darkorchid4", ...)
}

panel.cor <- function(x, y, digits=2, prefix="", cex.cor)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y))
  txt <- format(c(r, 0.123456789), digits=digits)[1]
  txt <- paste(prefix, txt, sep="")
  if(missing(cex.cor)) cex <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex = cex * r)
}

