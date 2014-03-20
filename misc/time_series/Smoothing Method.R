# Exponenatial Smoothing Method
# case1: One Parameter
data <- EuStockMarkets[1:200, 1]
plot(data, type="l")
model <- HoltWinters(data, beta=F, gamma=F)
lines(model$fitted[,1], col=2)

# case2: Two Parameter
model <- HoltWinters(data, gamma=F)
lines(model$fitted[,1], col=4)
legend(0, 1760, c("data", "One parameter", "Two parameter"), lty=1, col=c(1,2,4))
title("Exponential Smoothing Method")



# Winter's Seasonal Smoothing Method
# Case1: Winter's Additive Seasonal Model
data <- co2
plot(data)
model <- HoltWinters(data, seasonal="additive")
summary(model1)
lines(model$fitted[,1], col=2)
legend(1960, 365, c("data", "fitting"), lty=1, col=c(1,2))
title("Winter's Additive Seasonal Model: Constant Variance")

# Case2: Winter's Multiplicative Seasonal Model
data <- AirPassengers
plot(data)
model <- HoltWinters(data, seasonal="multi")
summary(model)
lines(model$fitted[,1], col=4)
legend(1949, 600, c("data", "fitting"), lty=1, col=c(1,4))
title("Winter's Multiplicative Seasonal Model: Increase Variance")