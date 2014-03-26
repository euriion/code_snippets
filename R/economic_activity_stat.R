

# 경제활동인구 데이터 (http://kosis.kr/feature/feature_0103List.jsp?mode=getList&menuId=03&NUM=180)
#  경제활동인구 : 만 15세 이상 인구 중 조사대상주간 동안 상품이나 서비스를 생산하기 위하여 실제로 수입이 있는 일을 한 취업자와 일을 하지 않았으나 구직활동을 한 실업자를 말함. 단위(천명)

econonic_activity_population <- "month;population
2009.09;24,630
2009.10;24,655
2009.11;24,625
2009.12;24,063
2010.01;24,082
2010.02;24,035
2010.03;24,382
2010.04;24,858
2010.05;25,099
2010.06;25,158
2010.07;25,232
2010.08;24,836
2010.09;24,911
2010.10;25,004
2010.11;24,847
2010.12;24,538
2011.01;24,114
2011.02;24,431
2011.03;24,918
2011.04;25,240
2011.05;25,480
2011.06;25,592
2011.07;25,473
2011.08;25,257
2011.09;25,076
2011.10;25,409
2011.11;25,318
2011.12;24,880
2012.01;24,585
2012.02;24,825
2012.03;25,210
2012.04;25,653
2012.05;25,939
2012.06;25,939
2012.07;25,901
2012.08;25,623"

library(ggplot2)
library(scales)

statdata <- read.table(file=textConnection(econonic_activity_population), header = TRUE, sep = ";", quote = "\"'", as.is=TRUE,colClasses=c("character", "character"))

statdata$month <- as.Date(paste(statdata$month, ".01", sep=""), "%Y.%m.%d", tz="Asia/Seoul")
statdata$population <- as.numeric(gsub(",", "", statdata$population))

#dev.new(width=11, height=3.5)
png("p1.png", width=1200, height=400)
ggplot(statdata, aes(x=month, y=population)) + geom_line()
dev.off()

png("p2.png", width=1200, height=400)
ggplot(statdata, aes(x=month, y=population)) + geom_line(colour="blue")
dev.off()

png("p3.png", width=1200, height=400)
ggplot(statdata, aes(x=month, y=population)) + geom_area()
dev.off()

png("p4.png", width=1200, height=400)
ggplot(statdata, aes(x=month, y=population)) + geom_area() + coord_cartesian(ylim = c(23500, 26500))
dev.off()

png("p5.png", width=1200, height=400)
ggplot(statdata, aes(x=month, y=population)) + geom_area(colour="gray10", fill="gray50") + coord_cartesian(ylim = c(23500, 26500))
dev.off()

png("p6.png", width=1200, height=400)
ggplot(statdata, aes(x=month, y=population)) + geom_area(colour="#5c0ab9", fill="#8a4fcd") + coord_cartesian(ylim = c(23500, 26500))
dev.off()

statdata <- read.table(file=textConnection(econonic_activity_population), header = TRUE, sep = ";", quote = "\"'", as.is=TRUE,colClasses=c("character", "character"))

statdata$month <- as.Date(paste(statdata$month, ".01", sep=""), "%Y.%m.%d", tz="Asia/Seoul")
statdata$population <- as.numeric(gsub(",", "", statdata$population)) * 1000

png("p7.png", width=1200, height=400)
ggplot(statdata, aes(x=month, y=population)) + geom_area(colour="#5c0ab9", fill="#8a4fcd") + coord_cartesian(ylim = c(23500000, 26500000))
dev.off()

png("p8.png", width=1200, height=400)
ggplot(statdata, aes(x=month, y=population)) + geom_area(colour="#5c0ab9", fill="#8a4fcd") + coord_cartesian(ylim = c(23500000, 26500000)) + scale_y_continuous(labels=comma)
dev.off()

# fc-list

png("p9.png", width=1200, height=400)
ggplot(statdata, aes(x=month, y=population)) + geom_area(colour="#5c0ab9", fill="#8a4fcd") + coord_cartesian(ylim = c(23500000, 26500000)) + scale_y_continuous(labels=comma) + scale_x_date(labels = date_format("%Y년 %m월")) + theme(axis.text.x = element_text(family="Apple SD Gothic Neo"))
dev.off()

png("p10.png", width=1200, height=400)
ggp <- ggplot(statdata, aes(x=month, y=population))
ggp <- ggp + geom_area(colour="#5c0ab9", fill="#8a4fcd")
ggp <- ggp + coord_cartesian(ylim = c(23500000, 26500000))
ggp <- ggp + scale_y_continuous(labels=comma)
ggp <- ggp + scale_x_date(labels = date_format("%Y년 %m월"))
ggp <- ggp + xlab("년도/월") + ylab("경제활동인구")
theme.title <- element_text(family="Apple SD Gothic Neo", face="bold", size=12, angle=00, hjust=0.54, vjust=0.5)
theme.text <- element_text(family="Apple SD Gothic Neo", size=10)
ggp <- ggp + theme(axis.title.x = theme.title, axis.title.y = theme.title, axis.text.x = theme.text)
ggp
rm(theme.title)
rm(theme.text)
gc()
dev.off()

