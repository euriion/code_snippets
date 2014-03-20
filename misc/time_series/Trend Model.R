# Constant trend model
data <- EuStockMarkets[1:200, 1]
c <- rep(1, length(data))
model <- lm(data ~ c)
plot(data, type="l")
lines(model$fitted.values, col=4)
legend(0, 1760, c("data", "fitting"), lty=1, col=c(1,4))
title("Constant trend model")


# Linear trend Model 
data <- co2
t <- rep(1:length(co2))
model1 <- lm(data ~ t)
summary(model1)
plot(co2)
temp <- data
coredata(temp) <- model1$fitted.values
lines(temp, col=2)
legend(1960, 365, c("data", "fitting"), lty=1, col=c(1,2))
title("Linear trend Model")

# Quadratic trend model 
t2 <- t^2
model2 <- lm(data ~ t + t2)
summary(model2)
plot(data)
temp <- data
coredata(temp) <- model2$fitted.values
lines(temp, col=2)
legend(1960, 365, c("data", "fitting"), lty=1, col=c(1,2))
title("Quadratic trend model")


# Seasonal trend Model
data <- co2 - model2$fitted.values
plot(data, ylim=c(-7,7))
sin.t <- sin(2*pi*t/12)
cos.t <- cos(2*pi*t/12)
model <- lm(data ~ sin.t + cos.t)
summary(model)
temp3 <- data
coredata(temp3) <- model$fitted.values
lines(temp3, col=2)
legend(1960, 7, c("data", "fitting"), lty=1, col=c(1,2))
title("Seasonal trend Model")


# Linear and Seasonal trend Model
data <-co2
model <- lm(data ~ t + t2 + sin.t + cos.t)
summary(model)
plot(data)
temp4 <- data
coredata(temp4) <- model$fitted.values
lines(temp4, col=2)
legend(1960, 365, c("data", "fitting"), lty=1, col=c(1,2))
title("Linear and Seasonal trend Model")