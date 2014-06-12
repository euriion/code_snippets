wd<-"### 작업디렉토리경로 ###"
setwd(wd)
fastfood <- read.csv("fastfood_stat.csv", sep="\t")
head(fastfood)
colnames(fastfood)

df.aggrbydate <- aggregate(freq ~ date, data=fastfood, FUN=sum)
colnames(df.aggrbydate)
ggplot(df.aggrbydate, aes(x=date, y=freq)) + geom_bar(stat='identity', colour="black", fill="lightgray")
plot(df.aggrbydate, type="l", xaxt="n")


head(fastfood$week)
df.aggrbyweekday <- aggregate(freq ~ weekday, data=fastfood, FUN=median)
plot()

#plot(table(fastfood), xlab=as.character(fastfood$date))
#df.aggrbytime <- aggregate(freq ~ time, data=fastfood, FUN=sum)
#
