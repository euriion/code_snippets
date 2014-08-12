
## Data spec

* Airport ID  Unique OpenFlights identifier for this airport.
* Name	Name of airport. May or may not contain the City name.
* City	Main city served by airport. May be spelled differently from Name.
* Country	Country or territory where airport is located.
* IATA/FAA	3-letter FAA code, for airports located in Country "United States of America".
* 3-letter IATA code, for all other airports. Blank if not assigned.
* ICAO	4-letter ICAO code.Blank if not assigned.
* Latitude	Decimal degrees, usually to six significant digits. Negative is South, positive is North.
* Longitude	Decimal degrees, usually to six significant digits. Negative is West, positive is East.
* Altitude	In feet.
* mezone	Hours offset from UTC. Fractional hours are expressed as decimals, eg. India is 5.5.
* DST	Daylight savings time. One of E (Europe), A (US/Canada), S (South America), O (Australia), Z (New Zealand), N (None) or U (Unknown). See also: Help: Time


```r
work_direcotory <- "C:\\Users\\aiden.hong\\Documents\\workspace\\nexr-analytics\\codes\\airports"

setwd(work_direcotory)
```




```r
airports <- read.table("./data/airports.dat", sep = ",", header = F)
colnames(airports) <- c("id", "name", "city", "country", "iata", "icao", "latitude", 
    "gongitude", "altitude", "timezone", "dst")
```



```r
airports.bycountry <- aggregate(data = airports, id ~ country, FUN = length)
colnames(airports.bycountry) <- c("country", "airport_count")
top30 <- head(airports.bycountry[order(airports.bycountry$airport_count, decreasing = T), 
    ], 30)
rownames(top30) <- NULL
top30
```

```
##             country airport_count
## 1     United States          1566
## 2            Canada           405
## 3           Germany           316
## 4         Australia           258
## 5            France           226
## 6            Russia           223
## 7            Brazil           212
## 8             China           210
## 9    United Kingdom           196
## 10            India           137
## 11            Japan           131
## 12        Indonesia           111
## 13        Argentina           103
## 14     South Africa           103
## 15            Italy            91
## 16           Mexico            91
## 17           Sweden            82
## 18             Iran            81
## 19         Colombia            72
## 20            Spain            72
## 21           Turkey            71
## 22           Norway            68
## 23      Philippines            64
## 24           Greece            60
## 25        Venezuela            58
## 26 Papua New Guinea            57
## 27      New Zealand            56
## 28         Thailand            55
## 29            Kenya            54
## 30      Switzerland            53
```



```r
library(ggplot2)
ggplot(data = top30, aes(x = country, y = airport_count)) + geom_bar()
```

```
## Mapping a variable to y and also using stat="bin".
##   With stat="bin", it will attempt to set the y value to the count of cases in each group.
##   This can result in unexpected behavior and will not be allowed in a future version of ggplot2.
##   If you want y to represent counts of cases, use stat="bin" and don't map a variable to y.
##   If you want y to represent values in the data, use stat="identity".
##   See ?geom_bar for examples. (Deprecated; last used in version 0.9.2)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 

```r
airports[airports$country %in% c("North Korea"), ]
```

```
##        id             name     city     country iata icao latitude
## 6129 7553 Chongjin Airport Chongjin North Korea       \\N    41.80
## 6130 7554    Haeju Airport    Haeju North Korea  HAE  \\N    38.01
## 7354 8785   Sondok Airport  Hamhung North Korea  DSO  \\N    39.75
## 7355 8786 Samjiyon Airport Samjiyon North Korea  YJS  \\N    41.91
## 7399 8830 Chongjin Airport Chongjin North Korea  RGO ZZ07    41.43
##      gongitude altitude timezone dst
## 6129     129.9      500        9   U
## 6130     125.8      131        9   U
## 7354     127.5        0        9   U
## 7355     128.4        0        9   U
## 7399     129.6        0        9   U
```


