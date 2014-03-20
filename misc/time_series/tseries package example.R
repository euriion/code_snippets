# Stationary Test example (kpss.test)
sam.data <- EuStockMarkets[,1]
plot(sam.data) 
acf(sam.data) # Non-Exponential Decay: Non-Stationary
pacf(sam.data)
kpss.test(sam.data) # Stationary Test


# Unit Roots Test example (adf.test, pp.test)
# method 1: ADF test
adf.test(sam.data)
# method 2: PP test
pp.test(sam.data)


# Normality Test example (jarque.bera.test)
jarque.bera.test(sam.data)


# Cointegration Test example (po.test)
sam.data2 <- EuStockMarkets[,2]
coint.data <- cbind(sam.data, sam.data2)
po.test(coint.data)


# i.i.d Test example (bds.test)
bds.test(sam.data)

# Randomness Test example (runs.test)
ran.data <- as.factor(sample(c(0,1), 100, replace=T))
runs.test(ran.data)

# ARMA example
arma.data <- tcm1y
head(arma.data)
acf(arma.data) # non-stationary
pacf(arma.data)
kpss.test(arma.data) # non-stationary
ndiffs(arma.data) # calculating difference
diff.arma.data <- diff(arma.data)
acf(diff.arma.data)
pacf(diff.arma.data)
fit1 <- arma(diff.arma.data, order=c(2,2))
fit1.1 <- arima(diff.arma.data, order=c(2,0,0))
fit2 <- auto.arima(diff.arma.data)
rbind(accuracy(forecast(fit1.1)), accuracy(forecast(fit2)))


# ARCH, GARCH example
# first order = 0: ARCH Model
data(EuStockMarkets)
dax <- diff(log(EuStockMarkets))[,"DAX"]
dax.garch <- garch(dax) # GARCH Model fitting: GARCH(1,1)
summary(dax.garch) 
plot(dax.garch)
plot(dax^2, main="GARCH(1,1)") # fitting value plotting 
lines(dax.garch$fitted.values[,1]^2, col="red")


# read.ts example
data(sunspots)
st <- start(sunspots)
fr <- frequency(sunspots)
write(sunspots, "sunspots", ncolumns=1)
x <- read.ts("sunspots", start=st, frequency=fr)


# read.matrix example
x <- matrix(0, 10, 10)
write(x, "test", ncolumns=10)
x <- read.matrix("test")


# na.remove example
test1 <- c(111:120, " ", " ", 101:115)
test1 <- as.numeric(test)
test1 <- na.remove(test)

test2 <- ts(c(5453.08, 5409.24, 5315.57, 5270.53, 5211.66, NA, NA, 5160.80, 5172.37))
na.remove(test2)


# portfolio.optim example
x <- rnorm(1000)
dim(x) <- c(500,2)
res <- portfolio.optim(x)
res$pw


# seqplot.ts example
data1 <- EuStockMarkets[,1]
data2 <- EuStockMarkets[,2]
seqplot.ts(data1, data2, ylab="index", main="DAX and SMI Time Series Graph (EuStockMarkets data)")
legend(1991.5,8600,c("DAX index","SMI index"), lty=c(1,1), col=c("black","red"))


# plotOHCL example
nDays <- 50
instrument <- "^gspc"
start <- strftime(as.POSIXlt(Sys.time() - nDays*24*3600), format="%Y-%m-%d") # Start day setting
end <- strftime(as.POSIXlt(Sys.time()), format = "%Y-%m-%d") # End day setting
x <- get.hist.quote(instrument = instrument, start = start, end = end, retclass = "ts") # "http://quote.yahoo.com"에서 자료를 가지고 옴
plotOHLC(x, ylab = "price", main = instrument)


