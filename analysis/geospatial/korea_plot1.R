# ========================================================================
# Title: Korea Map plotting example1
# Author: Seonghak Hong (euriion@gmail.com)
# Description: Korean plotting example for utilities
# ========================================================================
library(rgdal) 
library(maptools)
library(sp)
library(ggmap)
library(foreign)
# ------------------------------------------------------------------------
# Map file description
# ------------------------------------------------------------------------
# 지도파일 저장경로: ~/kostat_map_2012
# 등고면: BAS_CNTR_PG.shp
# 등고선: BAS_CNTR_LS.shp
# 파일이름 규칙: postfix '_PG': 면
# 파일이름 규칙: postfix '_LS': 선

# 좌표계: T.M중부좌표계
# proj4 string: +proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=bessel +units=m +no_defs
# 좌표계: WGS84좌표계
# proj4 string: +proj=longlat +zone=52 +ellps=WGS84 +datum=WGS84 +units=m +no_defs +lat_0=38N +lon_0=127E

#crsTM <- CRS("+proj=tmerc +lat_0=38N +lon_0=127E +ellps=bessel +x_0=200000 +y_0=500000 +k=0.9999 +towgs84=-146.43,507.89,681.46")  # 네이버좌표계
#crsWGS84utm <- CRS("+proj=utm +zone=52 +ellps=WGS84 +datum=WGS84 +units=m +no_defs +lat_0=38N +lon_0=127E")  # WGS84 UTM좌표계
#crsWGS84norm <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")  # WGS84 노말좌표계
# ------------------------------------------------------------------------

map_base_dir <- "/Users/euriion/Documents/kostat_map_2012"
sido_map <- paste0(map_base_dir, "/", "BND_SIDO_PG.shp")

# 좌표계, 투영법 설정
# TM중부 좌표계: 통계청지도
# WGS84 경위도좌표계: 구글지도
crsTMcenter <- CRS("+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=bessel +units=m +no_defs")  # TM중부좌표계
crsWGS84lonlat <- CRS("+proj=longlat +zone=52 +ellps=WGS84 +datum=WGS84 +units=m +no_defs +lat_0=38N +lon_0=127E")  # WGS94 경위도좌표계
#crsTM <- CRS("+proj=tmerc +lat_0=38N +lon_0=127E +ellps=bessel +x_0=200000 +y_0=500000 +k=0.9999 +towgs84=-146.43,507.89,681.46")  # 네이버좌표계
#crsWGS84utm <- CRS("+proj=utm +zone=52 +ellps=WGS84 +datum=WGS84 +units=m +no_defs +lat_0=38N +lon_0=127E")  # WGS84 UTM좌표계
#crsWGS84norm <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")  # WGS84 노말좌표계

# 데이터로딩하기
map.filename.shape <- paste0(map_base_dir, "/", "BND_SIGUNGU_PG.shp")
map.filename.dbf <- paste0(map_base_dir, "/", "BND_SIGUNGU_PG.dbf")
map.data.shape <- readShapePoly(map.filename.shape, verbose=T, proj4string=crsTMcenter)  # 지도 shape
map.data.dbf <- read.dbf(map.filename.dbf)  # 지도메타정보

colnames(map.data.dbf)
# [1] "BASE_YEAR"  "SIGUNGU_CD" "SIGUNGU_NM" "OJBECTID"  


# 확장완성형을 유니코드로 변환
map.data.dbf$SIGUNGU_NM <- iconv(map.data.dbf$SIGUNGU_NM, "cp949", "utf8")

# example: 구글에서 주소를 경위도계로 가져오고 출력하는 지도의 좌표계(TM중부계)로 변환
lonlat <- geocode("서울특별시 서초구 서초동 1321-6")  # 넥스알 주소
lonlat <- geocode("제주시")  # 제주시
lonlat.tmc <- spTransform(SpatialPoints(lonlat, proj4string=crsWGS84lonlat), crsTMcenter)

# 출력하기전에 경계값 설정
map.xlim <- map.data.shape@bbox[1, ]
map.ylim <- map.data.shape@bbox[2, ]

# 지도 그리기
plot(map.data.shape,
     axes = F,
     xlim = map.xlim,
     ylim = map.ylim,
     bty = "n",
     lwd=0.5,
     col="gray",
     border="darkgray")

points(lonlat.tmc, pch=8)

# ----------------------------------------------------------------------------
# 영역 선택 및 색칠 테스트
# ----------------------------------------------------------------------------

# 강남구 폴리곤을 가져와서 빨간색으로 찍기 (OJBECTID는 통계청의 오타)
map_object_id <- map.data.dbf[grep("^강남구", map.data.dbf$SIGUNGU_NM),]$OJBECTID

plot(map.data.shape[map.data.shape$OJBECTID == map_object_id,],
     axes = F,
     xlim = map.xlim,
     ylim = map.ylim,
     bty = "n",
     lwd=0.5,
     col="red",
     border="#990000",
     add=T)

# 해남군의 영역 색칠하기
map_object_id <- map.data.dbf[grep("^해남", map.data.dbf$SIGUNGU_NM),]$OJBECTID

plot(map.data.shape[map.data.shape$OJBECTID == map_object_id,],
     axes = F,
     xlim = map.xlim,
     ylim = map.ylim,
     bty = "n",
     lwd=0.5,
     col="red",border="#990000",
     add=T)


