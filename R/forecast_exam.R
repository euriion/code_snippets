# http://robjhyndman.com/software/forecast/

library(stats)
arima(lh, order = c(1,0,0))
arima(lh, order = c(3,0,0))
arima(lh, order = c(1,0,1))

arima(lh, order = c(3,0,0), method = "CSS")

arima(USAccDeaths, order = c(0,1,1), seasonal = list(order=c(0,1,1)))
arima(USAccDeaths, order = c(0,1,1), seasonal = list(order=c(0,1,1)),
      method = "CSS") # drops first 13 observations.
# for a model with as few years as this, we want full ML

arima(LakeHuron, order = c(2,0,0), xreg = time(LakeHuron)-1920)

## presidents contains NAs
## graphs in example(acf) suggest order 1 or 3
require(graphics)
(fit1 <- arima(presidents, c(1, 0, 0)))
tsdiag(fit1)
(fit3 <- arima(presidents, c(3, 0, 0)))  # smaller AIC
tsdiag(fit3)

#----
od <- options(digits=5) # avoid too much spurious accuracy
predict(arima(lh, order = c(3,0,0)), n.ahead = 12)

(fit <- arima(USAccDeaths, order = c(0,1,1),
              seasonal = list(order=c(0,1,1))))
predict(fit, n.ahead = 6)
options(od)
	
	
# -----
library(forecast)
fit <- Arima(WWWusage,c(3,1,0))
plot(forecast(fit))
 
x <- fracdiff.sim( 100, ma = -.4, d = .3)$series
fit <- arfima(x)
plot(forecast(fit,h=30))


# ----- Arima forecast for memory usage (unit %) -----
library(forecast) # need to install the package "forecast"

memory.usage.threshold <- 100  # 100%
memory.usage.forecast.period <- 30  # 미래 30일분까지 예측
memory.usage.observations.startdate <- "2012-09-01"
memory.usage.observations <- c(10,11,30,35,36,39,48,56,75,69,68,72,71,72,83) # 관측치 12일분

memory.usage.period <- seq(as.Date(memory.usage.observations.startdate), length=length(memory.usage.observations), by="1 day") # 날짜세팅
memory.usage.df <- data.frame(row.names=memory.usage.period, memory=memory.usage.observations) # data.frame으로 변환
memory.usage.ts <- ts(data=memory.usage.df)  # time series 생성
memory.usage.model <- auto.arima(memory.usage.ts)  # arima 모델 생성
memory.usage.forecast <- forecast(memory.usage.model, h=memory.usage.forecast.period)  # forecast 결과 생성
memory.usage.forecast.df <- as.data.frame(memory.usage.forecast)  # forecast 결과 변환

d <- as.numeric(row.names(memory.usage.forecast.df[memory.usage.forecast.df$`Point Forecast` >= memory.usage.threshold,][1,]))  # 100 이 넘는 최초 데이터 추출
if(is.na(d)) {
  print(sprintf("앞으로 %s일동안 %s%% 초과하지 않음", memory.usage.forecast.period, d - length(memory.usage.observations)))	
} else {
  print(sprintf("%s일 후에 %s%% 초과됨", d - length(memory.usage.observations), memory.usage.threshold))	
}

# Plotting
plot(memory.usage.forecast)  # plotting
abline(h=100, col = "red", lty=3)
abline(v=d, col = "red", lty=3)


#axis(1, memory.usage.period, format(memory.usage.period, "%b %d")))
#ggplot(data = memory.usage.df, aes(memory)) + geom_line() 

library(ggplot2)
library(scales)
  
plt <- ggplot(data=pd,aes(x=date,y=observed)) 
p1a<-p1a+geom_line(col='red')
p1a<-p1a+geom_line(aes(y=fitted),col='blue')
p1a<-p1a+geom_line(aes(y=forecast))+geom_ribbon(aes(ymin=lo95,ymax=hi95),alpha=.25)
p1a<-p1a+scale_x_date(name='',breaks='1 year',minor_breaks='1 month',labels=date_format("%b-%y"),expand=c(0,0))
p1a<-p1a+scale_y_continuous(name='Units of Y')
p1a<-p1a+opts(axis.text.x=theme_text(size=10),title='Arima Fit to Simulated Data\n (black=forecast, blue=fitted, red=data, shadow=95% conf. interval)')
# ----
?ts
#-------
## The classic 'airline model', by full ML
(fit <- arima(log10(AirPassengers), c(0, 1, 1),
              seasonal = list(order=c(0, 1 ,1), period=12)))
update(fit, method = "CSS")
update(fit, x=window(log10(AirPassengers), start = 1954))
pred <- predict(fit, n.ahead = 24)
tl <- pred$pred - 1.96 * pred$se
tu <- pred$pred + 1.96 * pred$se
ts.plot(AirPassengers, 10^tl, 10^tu, log = "y", lty = c(1,2,2))

## full ML fit is the same if the series is reversed, CSS fit is not
ap0 <- rev(log10(AirPassengers))
attributes(ap0) <- attributes(AirPassengers)
arima(ap0, c(0, 1, 1), seasonal = list(order=c(0, 1 ,1), period=12))
arima(ap0, c(0, 1, 1), seasonal = list(order=c(0, 1 ,1), period=12),
      method = "CSS")

## Structural Time Series
ap <- log10(AirPassengers) - 2
(fit <- StructTS(ap, type= "BSM"))
par(mfrow=c(1,2))
plot(cbind(ap, fitted(fit)), plot.type = "single")
plot(cbind(ap, tsSmooth(fit)), plot.type = "single")

# ----- Memory usage forecasting







