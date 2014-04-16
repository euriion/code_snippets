

# Histogram
hist(mtcars$mpg)

# break를 지정한 히스토그램
hist(mtcars$mpg, breaks = c(0, 5, 10, 15, 20, 25, 30, 35, 40), freq = TRUE)

summary(mtcars$mpg)
?hist


qqplot(mtcars$mpg, qchisq(ppoints(mtcars$mpg), df = 4))

library(ggplot2)
ggplot(data=mtcars, aes(x=mpg)) + geom_histogram(aes(fill=..count..))


library(heatmap)
heatmap(mpg ~ cyl, data=mtcars)

require(graphics); require(grDevices)
x  <- as.matrix(mtcars)
rc <- rainbow(nrow(x), start = 0, end = .3)
cc <- rainbow(ncol(x), start = 0, end = .3)
hv <- heatmap(x, col = cm.colors(256), scale = "column",
              RowSideColors = rc, ColSideColors = cc, margins = c(5,10),
              xlab = "specification variables", ylab =  "Car Models",
              main = "heatmap(<Mtcars data>, ..., scale = \"column\")")
utils::str(hv) # the two re-ordering index vectors

install.packages("xts")
library(xts)

data(sample_matrix)

class(sample_matrix)
plot(as.ts(sample_matrix))
plot(as.ts(sample_matrix), plot.type = "single", lty = 1:3)


sample.xts <- as.xts(sample_matrix, descr='XTS sample data')
plot(sample.xts)
plot(sample.xts,z  type='candles')

require(graphics)

ts(1:10, frequency = 4, start = c(1959, 2)) # 2nd Quarter of 1959
print( ts(1:10, frequency = 7, start = c(12, 2)), calendar = TRUE)
# print.ts(.)
## Using July 1954 as start date:
gnp <- ts(cumsum(1 + round(rnorm(100), 2)),
          start = c(1954, 7), frequency = 12)
plot(gnp) # using 'plot.ts' for time-series plot

## Multivariate
z <- ts(matrix(rnorm(300), 100, 3), start = c(1961, 1), frequency = 12)
class(z)
head(z) # as "matrix"
plot(z)
plot(z, plot.type = "single", lty = 1:3)


?hist

require(stats)
set.seed(14)
x <- rchisq(100, df = 4)

## Comparing data with a model distribution should be done with qqplot()!
qqplot(x, qchisq(ppoints(x), df = 4)); abline(0, 1, col = 2, lty = 2)

## if you really insist on using hist() ... :
hist(x, freq = FALSE, ylim = c(0, 0.2))
curve(dchisq(x, df = 4), col = 2, lty = 2, lwd = 2, add = TRUE)
curve(dchisq(x, df = 4), col = 2, lty = 2, lwd = 2, add = TRUE)

## QQplot을 그린다


qqplot(mtcars$mpg, mtcars$cyl)
?qqplot


## Scatter Plot 예제

attach(mtcars)
plot(wt, mpg, main="ScatterPlot exam",  xlab="Weight ", ylab="MPG(갤런)", pch=19)
abline(lm(mpg~wt), col="red") # regression line (y~x) 
lines(lowess(wt,mpg), col="blue") # lowess line (x,y)

plot(mtcars[,c("mpg","cyl", "wt")])
abline(lm(mtcars$mpg~mtcars$wt), col="red") # regression line (y~x) 
lines(lowess(wt,mpg), col="blue") # lowess line (x,y)

pairs(~mpg+disp+drat+wt,data=mtcars,  main="Scatterplot Matrix")

install.packages("car")
library(car)
scatterplot.matrix(~mpg+disp+drat+wt|cyl, data=mtcars, main="Three Cylinder Options")
expr1 <- expression(a<-"한글")
eval(expr1)
a
Sys.setlocale("LC_ALL", "ko_KR.UTF-8")

?renderPlot

.globals <- list()
output <- list()

fe1 <- function(func) {
  print(func)
  print(class(func))
  xxx <- list()
  func(xxx)
  print(xxx$aa)
}

fe1(function(output){
  output$aa <- 1
})

# ==============================================
f <- function(x) {
  x$a <- 2
  x
}
x <- list(a = 1)
f(x)
#> $a
#> [1] 2
x$a
#> [1] 1

# ==============================

ne1 <- new.env()
#address(ne1)
ne1$aaa <- 0

address(ne1$aaa)
mf1 <- function(x) {
  address(x$aaa)
  x$aaa <- 1
  address(x$aaa)
}
mf1(ne1)
address(x)

ne1$aaa
?enviroment
?new.env

.GlobalEnv

library(hash)
install.packages("hash")
h <- hash()
h['a'] <- 1
h[['a']]
h[['b']] <- 2
h[['h2']] <- hash()
h[['h2']][['hh1']] <- 1


id(a)
?id
??id
address(x)
http://stackoverflow.com/questions/10912729/r-object-identity

?identical
a<-1
b<-1
identical(a,b)
library(data.table)
install.packages("data.table")
address(a)
address(b)
address(iris)
.Internal(inspect(iris))
xxx <- function(aaa=x){
  print(address(aaa))
}
xxx(iris)

?capture.output
"sum"(1,2)
?"`"
class(quote(a))
class(`a`)
?missing
missing(xsadfsadfsadf)
exist(xsadfsadfsadf)
?exists
exists("aaa")
?renderTable
renderTable


a<- rep("white",3)
a[2] <- "red"
a
?div

?a
a?
renderUI
a
A
?HTML
tagList(...)
?div
rm(a)
a
