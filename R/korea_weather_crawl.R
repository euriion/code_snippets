
# 날씨데이터 정보: http://www.kma.go.kr/weather/lifenindustry/sevice_rss.jsp
# 동네 예보와 주간예보를 볼 수 있으며 해당 xml의 상세한 설명

# XML 의 스펙설명
# 동네예보: http://www.kma.go.kr/images/weather/lifenindustry/timeseries_XML.pdf
# 주간예보: http://www.kma.go.kr/images/weather/lifenindustry/weekly_XML.pdf
# 과거 기상자료
# 주소: http://minwon.kma.go.kr/main.Navigation.laf# 에서 신청을 하면 제공받을 수 있음

# 중기예보 전국은 다음과 같다.
# http://www.kma.go.kr/weather/forecast/mid-term-rss3.jsp?stnId=108

#<description>
#<body>  
#  <location wl_ver="3">
#  <province>서울ㆍ인천ㆍ경기도</province>
#  <city>서울</city>
#  
#  <data>
#  <mode>A02</mode>
#  <tmEf>2014-03-05 00:00</tmEf>
#  <wf>구름많고 눈/비</wf>
#  <tmn>0</tmn>
#  <tmx>6</tmx>
#  <reliability>보통</reliability>
#  </data>  

if (!require(RCurl)) {
  install.packages("RCurl")
  require(RCurl)
}

if (!require(XML)) {
  install.packages("XML")
  require(XML)
}

source.url <- "http://www.kma.go.kr/weather/forecast/mid-term-rss3.jsp?stnId=108"
xml.text = getURIAsynchronous(source.url)
xml.parsed = xmlInternalTreeParse(xml.text)

locationNodes <- getNodeSet(xml.parsed, "/rss/channel/item/description/body/location")

df <- data.frame()
for (i in seq(1, length(locationNodes)))
  node <- locationNodes[[i]]
  province <- xmlValue(xmlChildren(node)[[1]])
  city <- xmlValue(xmlChildren(node)[[2]])
  dataLength <- length(xmlChildren(node))
  dataList <- xmlChildren(node)[3:dataLength]
  
  data.mat <- sapply(dataList, function(x) {
    c(province, city, xmlValue(xmlChildren(dataList[[1]])$mode),
      xmlValue(xmlChildren(dataList[[1]])$tmEf),
      xmlValue(xmlChildren(dataList[[1]])$wf),
      xmlValue(xmlChildren(dataList[[1]])$tmn),
      xmlValue(xmlChildren(dataList[[1]])$tmx),
      xmlValue(xmlChildren(dataList[[1]])$reliability))
  })
  df <- rbind(df,t(data.mat))
})

df
