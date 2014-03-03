
# 날씨데이터 정보: http://www.kma.go.kr/weather/lifenindustry/sevice_rss.jsp
# 동네 예보와 주간예보를 볼 수 있으며 해당 xml의 상세한 설명

# XML 의 스펙설명
# 동네예보: http://www.kma.go.kr/images/weather/lifenindustry/timeseries_XML.pdf
# 주간예보: http://www.kma.go.kr/images/weather/lifenindustry/weekly_XML.pdf
# 과거 기상자료
# 주소: http://minwon.kma.go.kr/main.Navigation.laf# 에서 신청을 하면 제공받을 수 있음

# 중기예보 전국은 다음과 같다.
# http://www.kma.go.kr/weather/forecast/mid-term-rss3.jsp?stnId=108

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
# xml.parsed = xmlParse(xml.text)
xml.parsed = xmlInternalTreeParse(xml.text)
xmlToDataFrame(getNodeSet(xml.parsed, "//body/location"), homogeneous=T)
xmlToDataFrame(getNodeSet(xml.parsed, "//body/location/data"), homogeneous=T)
head(xmlToDataFrame(getNodeSet(xml.parsed, "//body/location"), homogeneous=T), n=1)
getNodeSet(xml.parsed, "//body/location/city")
?xmlToDataFrame
xml.df1 <- xmlToDataFrame(nodes = getNodeSet(xml.parsed, "//body/location/city | "))



