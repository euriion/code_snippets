# http://stackoverflow.com/questions/10000926/how-can-i-overlay-timeseries-models-for-exponential-decay-into-ggplot2-graphics

set.seed(101)
dat <- data.frame(d=seq.Date(as.Date("2010-01-01"),
                         as.Date("2010-12-31"),by="1 day"),
                y=rnorm(365,mean=exp(5-(1:365)/100),sd=5))

library(ggplot2)
g1 <- ggplot(dat,aes(x=d,y=y))+geom_point()+expand_limits(y=0)
g1+geom_smooth(method="glm",family=gaussian(link="log"),
               start=c(5,0))
               
               
