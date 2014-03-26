workdir.vrm.spatial <- "/home/aiden.hong/projects/HMC-SensorLog/analytics/VRM/spatial"
setwd(workdir.vrm.spatial)
getwd()
source("../hmc_vrm_loading.R")  # loading data from CSV file

# loading VRM data
filename.csv.address <- "/data/hmc_vrm/converted/csv/vrm.merged.final.csv.address"

vrm.address.colclasses <- c(
  "character",
  "character",
  "character",
  "character",
  "character",
  "character" 
)

# loading address parts
vrm.address <- read.csv(filename.csv.address, header = TRUE, colClasses = vrm.address.colclasses, sep = ";")

if (nrow(vrm) != nrow(vrm.address)) {
  print("Error! count of record are mismatched")
}

# merging data with address columns
vrm.addraggr <- cbind(vrm, vrm.address)
head(vrm.addraggr)

# TripCount per Wide area
vrm.addraggr.aggr.address1 <- aggregate(VIN ~ address1, vrm.addraggr, length)
colnames(vrm.addraggr.aggr.address1) <- c("address1", "tripcount")

library(ggplot2)
# vrm.addraggr.aggr.address1<-vrm.addraggr.aggr.address1[vrm.addraggr.aggr.address1$address1!="경기도",]
ggp <- ggplot(vrm.addraggr.aggr.address1)
ggp <- ggp + geom_bar(aes(x=address1, y=tripcount), fill="#AA0000", colour="#330000")
ggp <- ggp + xlab("주소1단계")
ggp <- ggp + ylab("트립 회수")
ggp

#vrm.addraggr.address1.tbl <- as.data.frame(table(vrm.addraggr$address1))
#vrm.addraggr.address1.tbl[vrm.addraggr.address1.tbl$Var1 == "경기",]$Freq <- vrm.addraggr.address1.tbl[vrm.addraggr.address1.tbl$Var1 == "경기",]$Freq + vrm.addraggr.address1.tbl[vrm.addraggr.address1.tbl$Var1 == "경기도",]$Freq + vrm.addraggr.address1.tbl[vrm.addraggr.address1.tbl$Var1 == "경기안양시",]$Freq
#colnames(vrm.addraggr)
vrm.addraggr.aggr.vin <- aggregate(TRVG_INFO_UNQ_NO ~ VIN, vrm.addraggr, length)
colnames(vrm.addraggr.aggr.vin) <- c("VIN", "tripcount")
colnames(vrm.addraggr)

uniquecount <- function(x) {
  length(unique(x))
}

# VIN별 주소 변경여부 확인
vrm.addraggr.aggr.vinaddr <- aggregate(HOME_ADR_LGLB_NM ~ VIN, vrm.addraggr, uniquecount)
colnames(vrm.addraggr.aggr.vinaddr) <- c("VIN", "addresscount")
vrm.addraggr.aggr.vinaddr[vrm.addraggr.aggr.vinaddr$addresscount > 1,]
vrm.addraggr[vrm.addraggr$VIN == "KMHEC41BBAA011085",]$HOME_ADR_LGLB_NM

# 주소지가 변경된 차량들 확인
VIN addresscount
7     KMHEC41BBAA011085            2
105   KMHEC41BBAA054422            2
128   KMHEC41BBAA079957            2
155   KMHEC41BBAA158436            2
176   KMHEC41BBBA242463            2
1497  KMHFF41CBBA024939            2
4778  KMHFF41EBBA001224            3
4884  KMHFF41EBBA001525            2
4936  KMHFF41EBBA001852            2
5759  KMHFF41EBBA040378            2
6400  KMHFG41EBBA001773            2
6519  KMHFG41EBBA008132            2
6524  KMHFG41EBBA008957            2
6557  KMHFG41EBBA012364            2
6712  KMHFG41EBBA017211            2
7997  KMHFG41EBBA035651            2
8077  KMHFG41EBBA036792            2
8396  KMHFG41EBBA046527            2
9869  KMHFH41EBBA000868            2
9961  KMHFH41EBBA012146            2
10505 KMHFH41EBBA021195            2
10515 KMHFH41EBBA021380            2
10557 KMHFH41EBBA021866            2
10681 KMHFH41EBBA023328            2
10696 KMHFH41EBBA023541            2
10724 KMHFH41EBBA024097            2
11076 KMHFH41EBBA029525            2
11150 KMHFH41EBBA031195            2
11220 KMHFH41EBBA031883            2
11323 KMHFH41EBBA033930            2
11554 KMHFH41EBBA040731            2
12139 KMHFH41EBBA059720            2
12451 KMHFH41EBBA074901            2
12892 KMHFH41NBBA039318            2
13925 KMHFK41GBCA087932            2
14220 KNALL416BCA060800            2
14388 KNALL416BCA068049            2
14553 KNALM412BAA003055            2
14606 KNALM412BAA011956            2
14682 KNALM412BAA019810            2
14748 KNALM412BBA028377            2
14776 KNALM412BBA035110            2
14789 KNALM412BBA036883            2
14840 KNALM412BBA043172            2
14918 KNALM412BBA050287            2
15185 KNALM412BBA055761            2
15442 KNALM415BCA059393            2
16516 KNALM416BCA060056            2
16841 KNALN412BAA012726            2
16901 KNALN412BAA019603            2
16935 KNALN412BBA023210            2
16995 KNALN412BBA039145            2
17302 KNALN413BAA018874            2
17320 KNALN413BBA025966            2
17354 KNALN413BBA046117            2
17502 KNALN414BAA009969            2
17587 KNALN414BBA024380            2
17616 KNALN414BBA033748            2
17640 KNALN414BBA045064            2
17701 KNALN414BBA052943            2
17815 KNALN414BBA058147            2
17819 KNALN414BBA058180            2
17919 KNALN416BCA060528            2
17936 KNALN416BCA060805            2
18155 KNALN416BCA062898            2
18219 KNALN416BCA064612            2
18586 KNALN416BCA070494            2

# 정말 바뀌었는지 확인
vrm.addraggr[vrm.addraggr$VIN == "KMHEC41BBAA011085",]$HOME_ADR_LGLB_NM


# 주소지별 VIN
lastitem <- function(x) {
  tail(x, n=1)
}
#lastitem(c("서울","대전"))

# -----
# VIN별 최종주소 구하기
vrm.addraggr.aggr.vinaddr1 <- aggregate(address1 ~ VIN, vrm.addraggr, lastitem)
colnames(vrm.addraggr.aggr.vinaddr1) <- c("VIN", "address1")

vrm.addraggr.aggr.vinaddr.aggr <- aggregate(VIN ~ address1, vrm.addraggr.aggr.vinaddr1, length)
#vrm.addraggr.aggr.vinaddr.aggr <- vrm.addraggr.aggr.vinaddr.aggr[order(vrm.addraggr.aggr.vinaddr.aggr$VIN),]
library(ggplot2)
ggp <- ggplot(vrm.addraggr.aggr.vinaddr.aggr)
ggp <- ggp + geom_bar(aes(x=address1, y=VIN), fill="#AA0000", colour="#330000")
ggp <- ggp + xlab("주소1단계")
ggp <- ggp + ylab("고유차량수")
ggp
# iris

# ---------------------------------------------------------------------
# 2단계 지역별 VIN 구하기

# a function to get unique count
uniquecount <- function(x) {
  length(unique(x))
}

vrm.addraggr.aggr.temp1 <- data.frame(VIN=vrm.addraggr$VIN, address1=vrm.addraggr$address1, address1_2=paste(vrm.addraggr$address1, " ", vrm.addraggr$address2,, " ", vrm.addraggr$address3 sep=""))
vrm.addraggr.aggr.temp2 <- aggregate(VIN ~ address1_2, vrm.addraggr.aggr.temp1, uniquecount)
address_map <- unique(vrm.addraggr.aggr.temp1[,c("address1","address1_2")])
vrm.addraggr.aggr.temp3 <- merge(vrm.addraggr.aggr.temp2, address_map, by="address1_2", all.x=TRUE)

address1_unique <- unique(vrm.addraggr.aggr.temp3$address1)

vrm.addraggr.aggr.temp3$address2 <- sapply(strsplit(as.character(vrm.addraggr.aggr.temp3$address1_2), " "), "[[", 2)

for (addr in address1_unique) {
  png(filename=sprintf("./%s.png", addr), width=1024, height=768)
  ggp <- ggplot(vrm.addraggr.aggr.temp3[vrm.addraggr.aggr.temp3$address1==addr, ], aes(address1_2, VIN))
  ggp <- ggp + geom_bar(fill="#AA0000", colour="#660000")
  ggp <- ggp + xlab(sprintf("%s 지역", addr))
  ggp <- ggp + ylab("고유차량수")
  ggp <- ggp + scale_x_discrete(labels=vrm.addraggr.aggr.temp3[vrm.addraggr.aggr.temp3$address1==addr, ]$address2)
  print(ggp)
  dev.off()
}


# 차량수가 많은 지역 순으로 소팅
vrm.addraggr.aggr.temp3[order(vrm.addraggr.aggr.temp3$VIN, decreasing=T),c(3,4,2)]

# ----- 지도 (map spatial) -----
library(maptools)
library(sp)
library(stringr)
library(rgdal)
library(RColorBrewer)
library(classInt)
library(gpclib) # Polygon Clippering

options(digit=10)

# ----- Defining Projection
crsTMM2 <- CRS("+proj=tmerc +lat_0=38N +lon_0=127E +ellps=bessel +x_0=200000 +y_0=500000 +k=0.9999 +towgs84=-146.43,507.89,681.46")
crsWGS84 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
crsWGS84_krrrr <- CRS("+proj=utm +ellps=WGS84 +lat_0=38N +lon_0=127E")
crsKostat <- CRS("+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=bessel +units=m +no_defs")
crsGoogle <- CRS("+proj=utm +zone=52 +ellps=WGS84 +datum=WGS84 +units=m +no_defs +lat_0=38N +lon_0=127E")

path.map <- "/home/aiden.hong/projects/HMC-SensorLog/analytics/VRM/spatial/kostat/2010_admin_district_boundary_last"
filename.shape <- paste(path.map,"/", "BND_SIGUNGU_PG.shp", sep="", collapse="")
#map.data.shape <- readShapePoly(filename.shape, verbose=T, proj4string=crsTMM2)
map.data.shape <- readShapePoly(filename.shape, verbose=T, proj4string=crsKostat)

filename.dbf <- paste(path.map,"/", "BND_SIGUNGU_PG.dbf", sep="", collapse="")
map.data.dbf <- read.dbf(filename.dbf)

xlim <- map.data.shape@bbox[1, ]
ylim <- map.data.shape@bbox[2, ]

library(rgdal) 
library(ggmap)
xy <- geocode("광주광역시 서구 화정동 현대아파트")
xy <- geocode("울릉도는 경상북도 울릉군 울릉읍")
xy <- geocode("경상북도 울릉군 울릉읍 독도리")
xy <- geocode("독도리")
xy <- data.frame(lat=xy$lat, lon=xy$lon)
#new_xy <- project(xy, "+proj=longlat +datum=WGS84 proj=tmerc lat_0=38N lon_0=127E ellps=bessel x_0=200000 y_0=500000 k=0.9999 towgs84=-146.43,507.89,681.46")
in_crs <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
out_crs <- CRS("+proj=tmerc +lat_0=38N +lon_0=127E +ellps=bessel +x_0=200000 +y_0=500000 +k=0.9999 +towgs84=-146.43,507.89,681.46")
crds.out <- SpatialPoints(xy, proj4string=crsWGS84_kr)
crds.out <- spTransform(SpatialPoints(xy, proj4string=crsGoogle), crsKostat)
crds.out <- spTransform(SpatialPoints(xy, proj4string=in_crs), out_crs)
#bbox(crds.out)
plot(map.data.shape,
  axes = F,  
  xlim = xlim, 
  ylim = ylim, 
  bty = "n", 
  lwd=0.5, 
  col=rgb(colorfun(mapvalues), maxColorValue=256), 
  border="#666666")

points(crds.out,pch=8)



mapvalues <- rep(0, nrow(map.data.shape)) # initialization

# converting encode
map.data.shape$SIGUNGU_NM <- iconv(map.data.shape$SIGUNGU_NM, "cp949", "utf-8")

values <- apply(as.data.frame(as.character(map.data.shape$SIGUNGU_CD)), 1, function(x) {
  address2 <- map.data.dbf[map.data.dbf$SIGUNGU_CD == x, ]$SIGUNGU_NM
  value <- vrm.addraggr.aggr.temp3[vrm.addraggr.aggr.temp3$address2 == address2, ]$VIN
  value[1]
})
mapvalues <- unlist(values)
names(mapvalues) <- as.character(map.data.shape$SIGUNGU_CD)
mapvalues[is.na(mapvalues)] <- 0  # set NA to zero

# 구가 분리된 도시의 데이터를 시 레벨로 합치기 (지도 표시를 위한 것)
for (city in c("포항시", 
  "창원시", 
  "수원시", 
  "성남시", 
  "안양시", 
  "부천시", 
  "안산시", 
  "고양시", 
  "용인시", 
  "청주시", 
  "천안시", 
  "전주시")) {
  vin_count <- vrm.addraggr.aggr.temp3[vrm.addraggr.aggr.temp3$address2 == city, ]$VIN  
  mapvalues[grep(sprintf("^%s", city), map.data.shape$SIGUNGU_NM)] <- vin_count
}


mapvalues <- (mapvalues - min(mapvalues)) / diff(range(mapvalues))  # normalization




# Special address
# 포항시남구         
# 포항시북구      
# 창원시의창구    
# 창원시성산구     
# 창원시마산합포구
# 창원시마산회원구 
# 창원시진해구    
# 수원시장안구    
# 수원시권선구     
# 수원시팔달구    
# 수원시영통구     
# 성남시수정구    
# 성남시중원구     
# 성남시분당구    
# 안양시만안구    
# 안양시동안구     
# 부천시원미구    
# 부천시소사구     
# 부천시오정구    
# 안산시상록구    
# 안산시단원구     
# 고양시덕양구    
# 고양시일산동구   
# 고양시일산서구  
# 용인시처인구     
# 용인시기흥구    
# 용인시수지구     
# 청주시상당구    
# 청주시흥덕구
# 천안시동남구     
# 천안시서북구    
# 전주시완산구    
# 전주시덕진구


colorfun <- colorRamp(c("white","red")) 
rgb(cols, maxColorValue=256)
par(mai = rep(.1, 4))
plot(map.data.shape, 
     axes = F,  
     xlim = xlim, 
     ylim = ylim, 
     bty = "n", 
     lwd=0.5, 
     col=rgb(colorfun(mapvalues), maxColorValue=256), 
     border="#666666")

# -------------- map heatmap by address1
# 한국행정구역분류 연계표(2012.06.30) 중 총괄표 시트만 추출 및 변환해서 로딩
filename.csv <- "/home/aiden.hong/projects/HMC-SensorLog/analytics/VRM/spatial/kostat/admin_district_total_table_20120401.csv"
admin_district_total_table <- read.table(filename.csv, header=T, sep=",", colClasses=c("character", "character", "character", "character", "character", "character", "character", "character", "character"), na.strings="")

area.list <- unique(vrm.addraggr.aggr.temp3$address1)
map <- new.env(hash=T)
map[["강원"]] <- "강원도"
map[["경기"]] <- "경기도"
map[["경남"]] <- "경상남도"
map[["경북"]] <- "경상북도"
map[["광주"]] <- "광주광역시"
map[["대구"]] <- "대구광역시"
map[["대전"]] <- "대전광역시"
map[["부산"]] <- "부산광역시"
map[["서울"]] <- "서울특별시"
map[["울산"]] <- "울산광역시"
map[["인천"]] <- "인천광역시"
map[["전남"]] <- "전라남도"
map[["전북"]] <- "전라북도"
map[["제주"]] <- "제주특별자치도"
map[["충남"]] <- "충청남도"
map[["충북"]] <- "충청북도"

#colnames(vrm.addraggr.aggr.temp3)
#vrm.addraggr.aggr.temp3[vrm.addraggr.aggr.temp3$address1 == "대구", ]
area.list <- "대구"

for (area.name in area.list) {
  # 지역의 코드중 2단계 코드만 추출
  area.name.full <- map[[area.name]]
  temp.codelist <- unique(admin_district_total_table[grep(sprintf("^%s", area.name.full), admin_district_total_table$sido), ]$code2)
  # 지역의 폴리곤만 추출
  map.data.shape.temp <- map.data.shape[map.data.shape$SIGUNGU_CD %in% temp.codelist,]
  length(map.data.shape.temp)
  
  # VRM 데이터에서 값 따내기
  values <- apply(as.data.frame(as.character(map.data.shape.temp$SIGUNGU_CD)), 1, function(x) {
    address2 <- map.data.dbf[map.data.dbf$SIGUNGU_CD == x, ]$SIGUNGU_NM
    value <- vrm.addraggr.aggr.temp3[intersect(grep(sprintf("^%s", area.name), vrm.addraggr.aggr.temp3$address1), grep(sprintf("^%s$", address2), vrm.addraggr.aggr.temp3$address2)), ]$VIN
    value[1]
  })
  
  map_values <- unlist(values)  # 벡터로 변환
  names(map_values) <- as.character(map.data.shape.temp$SIGUNGU_CD)  # 이름 지정
  map_values[is.na(map_values)] <- 0  # set NA to zero
  
  for (city in c("포항시", "창원시", "수원시", "성남시", "안양시", 
                 "부천시", "안산시", "고양시", "용인시", "청주시", 
                 "천안시", "전주시")) {
    vin_count <- vrm.addraggr.aggr.temp3[vrm.addraggr.aggr.temp3$address2 == city, ]$VIN
    map_values[grep(sprintf("^%s", city), map.data.shape.temp$SIGUNGU_NM)] <- vin_count
  }
  
  # map_values <- (map_values - min(map_values)) / diff(range(map_values))
  map_values <- map_values / max(map_values)  # 색상 레인지를 위한 정규화 (min==0 으로 취급)
  
  # 선택된 지도들의 바운더리를 꺼내옴
  xlim <- map.data.shape.temp@bbox[1, ]
  ylim <- map.data.shape.temp@bbox[2, ]
  
  colorfun <- colorRamp(c("white","red"))  # 칼라 생성용 펑션 생성. return값이 펑션임
  
  png(filename=sprintf("./spatial_heatmap_area_%s.png", area.name), width=1000, height=1000)
  par(mai = rep(.1, 4))
  plot(map.data.shape.temp, 
       axes = F,  
       xlim = xlim, 
       ylim = ylim, 
       bty = "n", 
       lwd=0.5, 
       col=rgb(colorfun(map_values), maxColorValue=256), 
       border="#666666")
  
  centroids <- coordinates(map.data.shape.temp)
  text(centroids, label=map.data.shape.temp$SIGUNGU_NM, cex=0.85)
  dev.off()
}

# -------------------------------------------------------------
# 특정 구역만 따로 표시

#colnames(admin_district_total_table)
#admin_district_total_table[admin_district_total_table$code2 == "11020", ]
names(map.data.shape.temp)
temp.codelist <- unique(admin_district_total_table[intersect(grep("^서울", admin_district_total_table$sido), grep("^중구", admin_district_total_table$sigugun)), ]$code2)
plot(map.data.shape.temp[map.data.shape.temp$SIGUNGU_CD %in% temp.codelist, ], 
     axes = F,  
     xlim = xlim, 
     ylim = ylim, 
     bty = "n", 
     lwd=0.5, 
      #     col="blue", 
     border="blue", add=T)


# -------------- sptransform (deprecated)

#spTransform()
#spplot(orcounty.shp.proj, "AREA", col.regions=plotclr, at=round(class$brks, digits=1))
#plotvar <- map.data.shape.proj@data$AREA
#head(map.data.shape.proj@data)

#map.data.shape.proj <- spTransform(map.data.shape, crsTMM2)
#class <- classIntervals(1:length(map.data.shape.proj), nclr, style="quantile")
#colcode <- findColours(class, plotclr)
#spplot(map.data.shape.proj, "AREA", col.regions=plotclr, at=round(class$brks, digits=1))

#colnames(map.data.dbf)
#map.data.dbf$SIGUNGU_CD
#map.data.dbf$SIGUNGU_NM
#map.data.dbf$SIGUNGU_NM <- iconv(map.data.dbf$SIGUNGU_NM, "cp949", "utf-8")

area.name <- "서초구"
map.data.dbf[str_detect(map.data.dbf$SIGUNGU_NM, area.name), ]$SIGUNGU_CD
colnames(map.data.shape)

plot(map.data.shape, axes = F,xlim = xlim, ylim = ylim, bty = "n", lwd=0.5, col = "#eeeeee", border="#666666")

