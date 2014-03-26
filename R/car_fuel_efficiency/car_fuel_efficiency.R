
setwd("C:\\Users\\aiden.hong\\Documents\\workspace\\nexr-analytics\\codes\\car_fuel_efficiency")

car_efficiency = read.table(file="car_fuel_efficiency.tsv", header=F, sep="\t", fileEncoding="utf-8")
# 번호  	모델명		업체		유종		배기량		공차중량		변속형식		연비(㎞/ℓ)		구등급		신등급		CO2(g/㎞)		예상연료비(원)
# 번호, 모델명, 업체, 유종, 배기량, 공차중량, 변속형식, 연비(㎞/ℓ), 구등급, 신등급, CO2(g/㎞), 예상연료비(원)
# no, model, maker, fuletype, displacement, weight, transmissiontype, mileage, oldgrade, newgrade, co2, oilmoneyperyear
# 예상연료비는 1년간 16,000㎞의 주행조건을 기준으로 산출된 금액입니다.
# (휘발유 1,929.53원/ℓ, 경유 1,754.82원/ℓ, LPG 1,099.26원/ℓ)

colnames(car_efficiency) <- c("no", "model", "maker", "fueltype", "displacement", "weight", "transmissiontype", "mileage", "oldgrade", "newgrade", "co2", "oilmoneyperyear")
car_efficiency$oilmoneyperyear <- as.numeric(gsub(",", "", car_efficiency$oilmoneyperyear))

summary(car_efficiency)

# distribution 1
# boxplot(car_efficiency$mileage)
# distribution 2
# boxplot(car_efficiency$oilmoneyperyear)
# distribution 3
# boxplot(car_efficiency$weight)

par(xaxt="n")
par(mar=c(9,4,4,2) + 0.1)
boxplot(mileage ~ maker, data = car_efficiency)
axis(1, at=seq(1, length(car_efficiency$maker)), labels = FALSE)
text(x = car_efficiency$maker, par("usr")[1], labels = car_efficiency$maker, srt = 270, pos = 1, xpd = TRUE)
dev.off()

# checking outliers
car_efficiency[car_efficiency$maker %in% "(주)AD 모터스",]
car_efficiency[car_efficiency$maker %in% "한불모터스(주)",]$model


summary(car_efficiency)
