한국날씨 RSS 불러오기
====================

정보제공: Andrew.Kim (NexR기상전문분석가)

기상청에서 제공하는 날씨 RSS를 R에서 동적으로 읽어들여 data.frame으로 변환하는 예제 코드입니다.
기상정 데이터를 이용해서 동네 예보와 주간예보를 볼 수 있으며제공하는 xml의 상세한 설명문서도 제공되고 있습니다.


- 기상청 날씨데이터 정보: http://www.kma.go.kr/weather/lifenindustry/sevice_rss.jsp

## 날씨 XML 의 스펙문서

- 동네예보: http://www.kma.go.kr/images/weather/lifenindustry/timeseries_XML.pdf
- 주간예보: http://www.kma.go.kr/images/weather/lifenindustry/weekly_XML.pdf

## 과거 기상자료

아래 주소에서 신청을 하면 제공받을 수 있다고 합니다.

주소: http://minwon.kma.go.kr/main.Navigation.laf# 

## 중기예보 전국데이터

중기예보의 전국데이터를 로딩하기 위해서 아래의 링크에서 데이터를 로딩할 것입니다.

http://www.kma.go.kr/weather/forecast/mid-term-rss3.jsp?stnId=108

긁어올 XML의 대략적인 구조는 다음과 같습니다.

```{xml}
<description>
<body>  
  <location wl_ver="3">
  <province>서울ㆍ인천ㆍ경기도</province>
  <city>서울</city>
  
  <data>
  <mode>A02</mode>
  <tmEf>2014-03-05 00:00</tmEf>
  <wf>구름많고 눈/비</wf>
  <tmn>0</tmn>
  <tmx>6</tmx>
  <reliability>보통</reliability>
  </data>  
```

패키지는 XML이 필요하며 XML은 의존성으로 RCurl을 가지고 있습니다. 


```r
if (!require(RCurl)) {
    install.packages("RCurl")
    require(RCurl)
}
```

```
## Loading required package: RCurl
## Loading required package: bitops
```

```r

if (!require(XML)) {
    install.packages("XML")
    require(XML)
}
```

```
## Loading required package: XML
```


다음은 XML 패키지를 이용하여 XML을 data.frame으로 변경하는 예제입니다.
XML에서 필요한 노드의 데이터를 가져오기 위해서는 XPATH문법을 사용해서 필요한 NodeSet을 가져온 뒤 getChildrent으로 하위 노드에 접근하는 것이 핵심입니다.


```r
source.url <- "http://www.kma.go.kr/weather/forecast/mid-term-rss3.jsp?stnId=108"
xml.text = getURIAsynchronous(source.url)
xml.parsed = xmlInternalTreeParse(xml.text)

locationNodes <- getNodeSet(xml.parsed, "/rss/channel/item/description/body/location")

df <- data.frame()
for (i in seq(1, length(locationNodes))) {
    node <- locationNodes[[i]]
    province <- xmlValue(xmlChildren(node)[[1]])
    city <- xmlValue(xmlChildren(node)[[2]])
    dataLength <- length(xmlChildren(node))
    dataList <- xmlChildren(node)[3:dataLength]
    
    data.mat <- sapply(dataList, function(x) {
        c(province, city, xmlValue(xmlChildren(dataList[[1]])$mode), xmlValue(xmlChildren(dataList[[1]])$tmEf), 
            xmlValue(xmlChildren(dataList[[1]])$wf), xmlValue(xmlChildren(dataList[[1]])$tmn), 
            xmlValue(xmlChildren(dataList[[1]])$tmx), xmlValue(xmlChildren(dataList[[1]])$reliability))
    })
    df <- rbind(df, t(data.mat))
}
rownames(df) <- NULL
colnames(df) <- c("province", "city", "mode", "tmEf", "wf", "tmn", "tmx", "reliability")
```


다음과 같이 변환된 결과를 볼 수 있습니다.


```r
head(df)
```

```
##             province city mode             tmEf   wf tmn tmx reliability
## 1 서울ㆍ인천ㆍ경기도 서울  A02 2014-03-06 00:00 맑음  -4   5        높음
## 2 서울ㆍ인천ㆍ경기도 서울  A02 2014-03-06 00:00 맑음  -4   5        높음
## 3 서울ㆍ인천ㆍ경기도 서울  A02 2014-03-06 00:00 맑음  -4   5        높음
## 4 서울ㆍ인천ㆍ경기도 서울  A02 2014-03-06 00:00 맑음  -4   5        높음
## 5 서울ㆍ인천ㆍ경기도 서울  A02 2014-03-06 00:00 맑음  -4   5        높음
## 6 서울ㆍ인천ㆍ경기도 서울  A02 2014-03-06 00:00 맑음  -4   5        높음
```


