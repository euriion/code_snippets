
# McLeod, A. I. and Hyukjun Gweon. (2013). Optimal Deseasonalization for Geophysical Time Series. Journal of Environmental Statistics. Vol. 4, Issue 11
# stl package의 harmonic regression 확장판
# 환경통계
# 중점사항: harmonic regression
# 결측치 보정에 harmonic regression으로 seasonality를 고려한 결측치 보정을 지원함
# anomaly에 사용할 수 있을 듯하나 결측치에 대한 결정을 해야 하는 무리가 있음

if (!require(sltl)) {
  install.packages("sltl")
}
library(sltl)
# co2
out <- sltl(as.timeSeries(co2), 
            c.window=101, 
            c.degree=1, 
            type="monthly")

summary(out)

plot.sltl(out) 
?sltl

# ============
TSA package 
# ============
require(graphics)

plot(stl(nottem, "per"))
plot(stl(nottem, s.window = 4, t.window = 50, t.jump = 1))

plot(stllc <- stl(log(co2), s.window = 21))
summary(stllc)
## linear trend, strict period.
plot(stl(log(co2), s.window = "per", t.window = 1000))

## Two STL plotted side by side :
stmd <- stl(mdeaths, s.window = "per") # non-robust
summary(stmR <- stl(mdeaths, s.window = "per", robust = TRUE))
op <- par(mar = c(0, 4, 0, 3), oma = c(5, 0, 4, 0), mfcol = c(4, 2))
plot(stmd, set.pars = NULL, labels  =  NULL,
     main = "stl(mdeaths, s.w = \"per\",  robust = FALSE / TRUE )")
plot(stmR, set.pars = NULL)
# mark the 'outliers' :
(iO <- which(stmR $ weights  < 1e-8)) # 10 were considered outliers
sts <- stmR$time.series
points(time(sts)[iO], 0.8* sts[,"remainder"][iO], pch = 4, col = "red")
par(op)   # reset


# =======================
co2
fftobj = fft(x)
plot(Mod(fftobj)[1:floor(length(x)/2)])
