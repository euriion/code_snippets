# Decomposition Method
# Trend, Seasonal, Irregular
data <- co2
plot(data)
model <- stl(co2,s.window="periodic")
plot(model)
plot(co2-model$time.series[,2]) # remove trend plot

# Use the trend model
# case 1: stats package
data <- co2
t <- rep(1:length(co2))
t2 <- t^2
model <- lm(co2 ~ t + t2)
temp <- co2
coredata(temp) <- model$residuals
plot(temp)

# case 2: forecast package
data <- ts(rnorm(120,0,3) + 1:120 + 20*sin(2*pi*(1:120)/12), frequency=12) # data setting
model <- tslm(data ~ trend + season)
model.trend <- tslm(tslm.data ~ trend)
plot(data)
lines(model.trand$fitted.values, col="red")
lines(model.trand$residuals, col="blue")
legend(1, 120, c("data","trend","seasonal"), lty=1, col=c(1,2,4))


# Use the moving average
data <- EuStockMarkets[1:200, 1]
plot(data, type="l")
model1 <- filter(data, filter=rep(1/5,5), side=1)
model2 <- filter(data, filter=rep(1/20,20), side=1)
model3 <- filter(data, filter=rep(1/50,50), side=1)
lines(model1, col=2)
lines(model2, col=3)
lines(model3, col=4)
title("Moving Average Model")
legend(0,1750,c("data", "order=5", "order=20", "order=50"),lty=1, col=c(1:4))