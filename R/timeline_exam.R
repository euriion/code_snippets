
connection <- textConnection("1/1/1/Drug A/ Begin (A), Begin (B), End (B), End (A)/0.0000/21.000 
1/1/1/Drug B/ Begin (A), Begin (B), End (B), End (A)/0.7143/18.000 
1/2/1/Drug A/ Begin (A, B, C), End (A, B), End (C)/0.0000/20.000 
1/2/1/Drug B/ Begin (A, B, C), End (A, B), End (C)/0.0000/20.000 
1/2/1/Drug C/ Begin (A, B, C), End (A, B), End (C)/0.0000/36.000 
2/1/1/Drug A/ Begin (A, B), End (A, B), Begin (C), End (C), Begin (D), End (D)/0.0000/7.429 
2/1/1/Drug B/ Begin (A, B), End (A, B), Begin (C), End (C), Begin (D), End (D)/0.0000/7.429 
2/1/1/Drug C/ Begin (A, B), End (A, B), Begin (C), End (C), Begin (D), End (D)/14.5714/21.857 
2/1/1/Drug D/ Begin (A, B), End (A, B), Begin (C), End (C), Begin (D), End (D)/25.4286/231.286 
2/2/1/Drug A/ Begin (A, B), End (A, B)/0.0000/35.286 
2/2/1/Drug B/ Begin (A, B), End (A, B)/0.0000/35.286 
3/1/1/Drug B/Begin (A, B, C), End (A, B, C), Begin (C), Begin (D), End (C, D)/0/17.0000 
3/1/1/Drug A/Begin (A, B, C), End (A, B, C), Begin (C), Begin (D), End (C, D)/0/17.0000 
3/1/1/Drug C/Begin (A, B, C), End (A, B, C), Begin (C), Begin (D), End (C, D)/0/17.0000 
3/1/1/Drug D/Begin (A, B, C), End (A, B, C), Begin (C), Begin (D), End (C, D)/20/32.8571 
3/1/2/Drug C/Begin (A, B, C), End (A, B, C), Begin (C), Begin (D), End (C, D)/18/32.8571 
") 

testdata <- data.frame(scan(connection, list(profile_key=0, line=0, instance=0, drug="", pattern="", start_drug=0, stop_drug=0), sep="/")) 

dislocations <- c(-1,1,-.5)
ggplot(testdata) + 
  geom_text( aes(x = V1, y=dislocations, label = V2), position="jitter" ) + 
  geom_hline( yintercept=0, size=1, scale="date" ) + 
  geom_segment(  aes(x = V1, y=dislocations, xend=V1, yend=0, alpha=.7 ))

closeAllConnections() 

testdata 

require(reshape2) 
testdata <- melt(TestData, measure.vars = c("start_drug", "stop_drug")) 
testdata$drug <- factor(TestData$drug, levels = c("Drug D", "Drug C", "Drug B", "Drug A")) 
testdata$key_line <- with(TestData,paste(profile_key, line, sep = "")) 
testdata

require(ggplot2) 

temp <- testdata 
TempData <- split(testdata, testdata$key_line) 

for(temp in TempData){ 

#png(filename = paste("plot", unique(temp$key_line), ".png", sep = ""), width=600, height=300) 

p <- ggplot(temp, aes(value, drug, fill = factor(instance))) + geom_line(size = 6) + xlab("\n Time (Weeks)") + ylab("") + theme_bw() +   
     opts(title = paste("Pattern = ", unique(temp$pattern), " \n (profile_key = ", unique(temp$profile_key), ", line = ", unique(temp$line), ") \n", sep = "")) + 
     opts(legend.position="none")   
print(p) 
#dev.off() 
} 

# --------

dat = as.data.frame(
  rbind(
    c("1492", "Columbus sailed the ocean blue"),
    c("1976", "Americans listened to Styx"),
                       c("2008", "Financial meltdown")))
dat$V1 <- as.Date(dat$V1,"%Y")
dat$val <- c(-1,1,-0.5)


# ----
dat = as.data.frame(rbind(c("1492", "Columbus sailed the ocean blue"),
                       c("1976", "Americans listened to Styx"),
                       c("2008", "Financial meltdown")))
dat$V1 <- as.Date(dat$V1,"%Y")
dat$val <- c(-1,1,-0.5)
data = as.data.frame(  rbind(   c("1492", "Columbus sailed the ocean blue"),
                                c("1976", "Americans listened to Styx"),
                                c("2008", "financial meltdown. great.")
                                ))
dislocations <- c(-1,1,-.5)
# -----                                
data <- data.frame( 
  V1=c(1492,1976,2008),
  V2=c("Columbus sailed the ocean blue","Americans listened to Styx","financial meltdown"),
  disloc=c(-1,1,-.5)
)


ggplot( data ) + 
  geom_text(aes(x = V1, y=dislocations, label = V2), position="jitter") + 
  geom_hline( yintercept=0, size=1, scale="date", colour="#990000") + 
  geom_segment(aes(x = V1, y=disloc, xend=V1, yend=0, alpha=.7 ))
                                

# -----                                
data <- data.frame( 
  V1=c(1492,1976,2008),
  V2=c("Columbus sailed the ocean blue","Americans listened to Styx","financial meltdown"),
  disloc=c(-1,1,-.5)
)

# -----
# http://www.krri.re.kr/teams/experiment/si_unit/si_index.html
geo <- NULL
geo.points <- NULL

geo.addressses <- c(
"서울특별시 서초구 서초동 1321-6",
"대한민국 서울특별시 서초구 서초2동 1332-3",
"대한민국 서울특별시 서초구 서초2동 1378",
"대한민국 서울특별시 서초구 서초2동 1376-14",
"서울특별시 서초구 양재동 산27-2",
"대한민국 서울특별시 서초구 양재1동 20-1",
"대한민국 서울특별시 서초구 양재2동 237-2",
"대한민국 서울특별시 서초구 양재2동 230-4",
"서울특별시 서초구 양재동 231"
)

geo.times <- c(
"2012-09-01 09:10",
"2012-09-01 09:23",
"2012-09-01 09:34",
"2012-09-01 09:40",
"2012-09-01 09:45",
"2012-09-01 09:48",
"2012-09-01 09:52",
"2012-09-01 09:56",
"2012-09-01 10:10"
)

# 거리 (임의의 값, 단위 Km)
geo.distance <- c(
	0,
	1.2,
	0.4,
	0.45,
	0.650,
	0.670,
	0.690,
	0.690,
	0.690
)

# 연료사용 (임의의 값, 리터)
geo.oiltaken <- c(
	0.00,
	0.05,
	0.012,
	0.08,
	0.09,
	0.11,
	0.12,
	0.13,
	0.10
)

geo.points <- geocode(geo.addressses)

geo.data <- data.frame(
  address=geo.addressses,
  lonlat=geo.points,
  time=as.POSIXct(geo.times, "%Y-%m-%d %H:%M", tz="Asia/Seoul"),
)

# -----
ggplot( data ) + 
  geom_text(aes(x = V1, y=dislocations, label = V2), position="jitter") + 
  geom_hline( yintercept=0, size=1, scale="date", colour="#990000") + 
  geom_segment(aes(x = V1, y=disloc, xend=V1, yend=0, alpha=.7 ))

