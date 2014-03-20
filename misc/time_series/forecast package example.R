# accuracy example and sim plotting
time.data   <- EuStockMarkets[1:200, 1] # non-stationary data
model.rwf   <- rwf(time.data, h=200) # Random Walk Model fittig and forecasting
model.arima <- forecast(auto.arima(time.data), h=200) # ARIMA Model fitting and forecasting
model.rwf.index   <- accuracy(model.rwf)
model.arima.index <- accuracy(model.arima)
rbind(model.rwf.index, model.arima.index) # Model evaluation




# acf, pacf example
# line in graph: Confidence Interval(CI)
# calculation(upper: 2/sqrt(n), lower: -2/sqrt(n))
time.data.acf  <- acf(time.data) # exponential decay: non-stationary
time.data.pacf <- pacf(time.data) 
# difference (defalut order = 1)
diff.time.data <- diff(time.data) # stationary data
diff.time.data.acf  <- acf(diff.time.data) 
diff.time.data.pacf <- pacf(diff.time.data)




# arima, auto.arima example
model.arima      <- arima(time.data, order = c(0,1,2)) # arime(0,1,2) model fitting
model.auto.arima <- auto.arima(time.data)
plot(forecast(model.arima), h=20)
plot(forecast(model.auto.arima), h=20)




# ets example
model.ets <- ets(time.data) # Exponentail Smoothing Model fitting
plot(forecast(model.ets, h=200)) # plotting
lines(EuStockMarkets[1:400,1])



# rwf example
model.rwf <- rwf(time.data,h=200) # Randow Walk model fitting
plot(model.rwf) # plotting
lines(EuStockMarkets[1:400,1])




# ma example
model.ma <- ma(time.data, order = 5) # Moving Average model fitting
model.ma2 <- ma(time.data, order = 20)
model.ma3 <- ma(time.data, order = 50)
plot(time.data,type="l", lty=1, col="black", main = "Moving Average model (order = 5, 20, 50)") # plotting
lines(model.ma, lty=2, col="red")
lines(model.ma2, lty=3, col="blue")
lines(model.ma3, lty=4, col="green")
legend(145,1600,c("time.data","order=5","order=20","order=50"),lty=1:4,col=c("black","red","blue","green"))




#tslm example
tslm.data    <- ts(rnorm(120,0,3) + 1:120 + 20*sin(2*pi*(1:120)/12), frequency=12) # data setting
model.tslm   <- tslm(tslm.data ~ trend + season) # Linear model fitting (trend, season)
tslm.fitdata <- forecast(model.tslm) # store the fitting value 
plot(tslm.fitdata) # plotting

model.trend <- tslm(tslm.data ~ trend) # trend fitting
del.trend.data <- tslm.data - model.trend$fitted # delete trend (only season)
plot(tslm.fitdata) # plotting data
lines(model.trand$fitted.values, lty=2, col="red") # plotting trend
lines(del.trend.data, lty=3, col="blue") #plotting season


# forecast example
# store the fitting value: ARIMA, Moving Average, Exponential Smoothing...
model.arima     <- auto.arima(time.data) # fitting ARIMA Model
model.arima.fit <- forecast(model.arima, h = 100) # store the fitting value(n=100) of ARIMA Model
plot(model.arima.fit) # plotting




# ndiffs, nsdiffs, diff example 
# non-stationary data -> stationary data: difference
# number of difference? => ndiffs, nsdiffs
# calculating difference => diff
nonst.data <- time.data # non-stationary data

ndiffs(nonst.data) # calculating difference

st.data    <- diff(nonst.data, lag = 1) # stationary data
plot(nonst.data, type="l", main = "Non-stationary")
plot(st.data, type ="l", main = "stationary")




# BoxCox, BoxCox.lambda example
# Transmation method
data <- lynx # non normal distribution
plot(data, type ="l")
hist(data) # Histogram
qqnorm(data) # Normal Probability plot
lambda <- BoxCox.lambda(data) # calculating lambda
trans.data <- BoxCox(data, lambda) # transformation to normal distribution
plot(trans.data, type ="l")
hist(trans.data)
qqnorm(trans.data) 
acf(trans.data)
pacf(trans.data)
model.fit1 <- arima(trans.data, order = c(2,0,0)) # ARIMA(0,0,2) Model fitting
model.fit2 <- auto.arima(trans.data) # ARIMA Model fitting (Auto)
plot(forecast(model.fit1, h=10))                    
plot(forecast(model.fit2, h=10))
rbind(accuracy(model.fit1),accuracy(model.fit2)) # Model evaluation
