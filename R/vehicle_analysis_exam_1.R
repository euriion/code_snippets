library(RHive)
library(rgdal)
library(maptools)
library(sp)
rhive.connect("10.10.189.120", 10001)
rhive.use.database("poc2")
rhive.show.tables()

# rhive.desc.table("vcrm_weather")
# rhive.query("select * from vcrm_weather limit 10")
# rhive.query("select distinct(state_code) from vcrm_weather")
# freqState <- rhive.query("select state_code, count(*) as cnt from vcrm_weather group by state_code")
# rhive.desc.table("vcrm_tm_gps_ext_clean")

gpsStateFrquency <- rhive.query("
  select state, count(state) 
  from vcrm_tm_gps_ext_clean 
  group by state 
  order by state
")

stateTC <- textConnection("AK	02	ALASKA
AL	01	ALABAMA
AR	05	ARKANSAS
AS	60	AMERICAN SAMOA
AZ	04	ARIZONA
CA	06	CALIFORNIA
CO	08	COLORADO
CT	09	CONNECTICUT
DC	11	DISTRICT OF COLUMBIA
DE	10	DELAWARE
FL	12	FLORIDA
GA	13	GEORGIA
GU	66	GUAM
HI	15	HAWAII
IA	19	IOWA
ID	16	IDAHO
IL	17	ILLINOIS
IN	18	INDIANA
KS	20	KANSAS
KY	21	KENTUCKY
LA	22	LOUISIANA
MA	25	MASSACHUSETTS
MD	24	MARYLAND
ME	23	MAINE
MI	26	MICHIGAN
MN	27	MINNESOTA
MO	29	MISSOURI
MS	28	MISSISSIPPI
MT	30	MONTANA
NC	37	NORTH CAROLINA
ND	38	NORTH DAKOTA
NE	31	NEBRASKA
NH	33	NEW HAMPSHIRE
NJ	34	NEW JERSEY
NM	35	NEW MEXICO
NV	32	NEVADA
NY	36	NEW YORK
OH	39	OHIO
OK	40	OKLAHOMA
OR	41	OREGON
PA	42	PENNSYLVANIA
PR	72	PUERTO RICO
RI	44	RHODE ISLAND
SC	45	SOUTH CAROLINA
SD	46	SOUTH DAKOTA
TN	47	TENNESSEE
TX	48	TEXAS
UT	49	UTAH
VA	51	VIRGINIA
VI	78	VIRGIN ISLANDS
VT	50	VERMONT
WA	53	WASHINGTON
WI	55	WISCONSIN
WV	54	WEST VIRGINIA
WY	56	WYOMING")
stateFipsTable <- read.csv(stateTC, sep="\t", header=F)
colnames(stateFipsTable) <- c("code", "fips", "name")
stateFipsTable$fips <- sprintf("%02d", stateFipsTable$fips)
stateFipsTable$fips <- as.character(stateFipsTable$fips)

# ogrInfo("/home/ndap/map/County/", "countyp010")
# ogrInfo("/home/ndap/map/State/", "statep010")
# ogrInfo("/home/ndap/map/roads/", "roadtrl020")

states <- readOGR("/home/ndap/map/State/", "statep010")
counties <- readOGR("/home/ndap/map/County/", "countyp010")
roads <- readOGR("/home/ndap/map/roads/", "roadtrl020")

# Default plotting
# plot(counties, axes=TRUE, border="gray", xlim=c(-170,-80))
# plot(states, axes=TRUE, border="black", xlim=c(-170,-80), add=T)
# plot(states, axes=TRUE, border="black", xlim=c(-170,-80), add=T)
# lines(roads, col="blue", lwd=0.3, add=T)

mapvalues <- rep(0, nrow(states)) # initialization
states$STATESP010 <- sprintf("%02d", states$STATESP010)

values <- apply(as.data.frame(states$STATESP010), 1, function(x) {
  value <- gpsStateFrquency[gpsStateFrquency$state == x[1], ]
  if (length(value) > 0) {
    value$X_c1  
  } else {
    0
  }
})

mapvalues <- unlist(values)
mapvalues[is.na(mapvalues)] <- 0  # set NA to zero
mapvalues <- (mapvalues - min(mapvalues)) / diff(range(mapvalues))  # normalization
colorfun <- colorRamp(c("white","red"))
                      
plot(states, axes=TRUE, border="black", lwd=1.0, xlim=c(-170,-80), col=rgb(colorfun(mapvalues), maxColorValue=256))
plot(counties, axes=TRUE, border="gray", lwd=0.5, xlim=c(-170,-80), add=T)
lines(roads, col="black", lwd=0.3, alpha=0.5, add=T)

# 주별로 한국인이 많이 사는지
# 인구가 많은지
# 현대차가 많은지 알 수 없음
# 주별로 해당 데이터의 운행건을 본 것임

library(ggplot2)
colnames(gpsStateFrquency) <-c("state_fips", "gps_freq")
gpsStateFrquency$state_fips <- sprintf("%02d", gpsStateFrquency$state_fips)
head(gpsStateFrquency)
head(stateFipsTable)
stateNameList <- apply(gpsStateFrquency, 1, function(x) {
  y <- as.character(stateFipsTable[x[1] == stateFipsTable$fips,]$name)
  
  stateName <- "Unknown"
  if (length(y) != 0) {
    stateName <- y
  }
  stateName
})


gpsStateFrquency <- cbind(gpsStateFrquency, state_name=stateNameList)

ggp <- ggplot(data=gpsStateFrquency, aes(x=state_name, y=gps_freq, fill=gps_freq)) + geom_bar()
ggp <- ggp + theme(axis.text.x=element_text(angle=-90))
ggp

