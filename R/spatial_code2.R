library(maptools)
# /home/aiden.hong/kostat2012/climbheight
# BAS_CNTR_PG.shp (등고선)
# BAS_CNTR_LS.shp (등고면)
crsTMM2 <- CRS("+proj=tmerc +lat_0=38N +lon_0=127E +ellps=bessel +x_0=200000 +y_0=500000 +k=0.9999 +towgs84=-146.43,507.89,681.46")
crsWGS84 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
crsWGS84_norm <- CRS("+proj=longlat +datum=WGS84")


library(rgdal) 
library(ggmap)
xy <- cbind(c(127.0252), c(37.49594)) 
project(xy, "+proj=longlat +ellps=WGS84 +datum=WGS84 proj=tmerc lat_0=38N lon_0=127E ellps=bessel x_0=200000 y_0=500000 k=0.9999 towgs84=-146.43,507.89,681.46")
#          [,1]      [,2]
# [1,] 2.217008 0.6544276
geocode("서울특별시 서초구 서초동 1321-6")
#        lon      lat
# 1 127.0252 37.49594
names(attributes(map.data.shape))
# [1] "bbox"        "proj4string" "polygons"    "plotOrder"  
# [5] "data"        "class"       "comment" 
map.data.shape@proj4string
map.data.shape@bbox
head(map.data.shape@data)
head(map.data.shape@polygons)
head(map.data.shape@comment)

path.map <- "/home/aiden.hong/kostat2012/climbheight"
filename.shape <- paste(path.map,"/", "BAS_CNTR_PG.shp", sep="", collapse="")
map.data.shape <- readShapePoly(filename.shape, verbose=T, proj4string=crsTMM2)
filename.dbf <- paste(path.map,"/", "BAS_CNTR_PG.dbf", sep="", collapse="")
map.data.dbf <- read.dbf(filename.dbf)

names(map.data.shape)
names(attributes(map.data.shape))
unique(map.data.shape$LEN)
# checking attributes of the objects
names(map.data.shape)
names(map.data.dbf)

head(map.data.shape)
head(map.data.dbf)

#xlim <- map.data.shape@bbox[1, ]
#ylim <- map.data.shape@bbox[2, ]

#mapvalues <- rep(0, nrow(map.data.shape)) # initialization
# converting encode
#map.data.shape$SIGUNGU_NM <- iconv(map.data.shape$SIGUNGU_NM, "cp949", "utf-8")

xlim <- map.data.shape@bbox[1, ]
ylim <- map.data.shape@bbox[2, ]
plot(map.data.shape, 
     axes = F,  
     xlim = xlim, 
     ylim = ylim, 
     bty = "n", 
     lwd=0.5, 
     #     col="blue", 
     border="blue")

xlim <- map.data.lines@bbox[1, ]
ylim <- map.data.lines@bbox[2, ]
plot(map.data.lines, 
     axes = F,  
     xlim = xlim, 
     ylim = ylim, 
     bty = "n", 
     lwd=0.5, 
     #     col="blue", 
     border="blue")

