# Time Series Models of Heteroskedasticity example
library(tseries)

data(EuStockMarkets)
data <- log(EuStockMarkets[,"DAX"]) # Log return
plot(data)
kpss.test(data) # Non-stationary

ndiffs(data)
data <- diff(data, differences=1)
kpss.test(data) # stationary

acf(data)
pacf(data)

plot(data^2) # varience cluster

model <- garch(data) # GARCH Model fitting: GARCH(1,1)
summary(model) 
plot(data^2) 
lines(model$fitted.values[,1]^2, col="red")
legend(1997, 0.009, c("data", "fitting"), lty=1, col=1:2)
title("Time Series Models of Heteroskedasticity: GARCH(1,1)")

# Residual checking
acf(model$residuals[-1])
pacf(model$residuals[-1])