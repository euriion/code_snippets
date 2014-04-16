# mtcars의 mpg 변수가 정규분포를 따르는지 확인하기
qqnorm(mtcars$mpg)
qqline(mtcars$mpg)
?qqnorm
library(car)
qqPlot(mtcars$mpg)

# original
s <- sort(mtcars$mpg)
s1 <- seq(1:length(s))
s2 <- (s1 - 0.5) / length(s)
q <- qnorm(s2,mean=0,sd=1)
plot(x=q, y=s)

