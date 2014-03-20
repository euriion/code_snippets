# Stochatic process example (AR, MA, ARMA, ARIMA Model)
library(forecast)
library(tseries)

data <- EuStockMarkets[1:200, 1] 
plot(data, type="l")
kpss.test(data) # Non-stationary
ndiffs(data) # Difference order: 1

diff.data <- diff(data, differences=1)
plot(diff.data, type="l")
kpss.test(diff.data) # Stationary

# Method 1: Use the ACF, PACF plot
acf(diff.data) # cut-off 2 Lag
pacf(diff.data) # Exponential decay
# ACF, PACF => MA(2) Model
model1 <- arima(data, order = c(0,1,2)) # Difference order: 1, MA order: 2
plot(forecast(model1))

# Method 2: Use auto.arima function
model2 <- auto.arima(time.data)
plot(forecast(modelasdfasdf2))

# Residual test
acf(model1$residuals)
pacf(model1$residuals)