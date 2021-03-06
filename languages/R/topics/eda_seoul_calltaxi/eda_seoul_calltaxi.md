
# 콜택시/대리운전 데이터 분석 예제 #1

SKT의 빅데이터허브에서 받은 콜택시/대리운전 데이터를 이용한 간단한 Data Munging과 EDA 예제입니다.

들어가기 앞서서

Data Muning은 데이터를 분석하기 위해 데이터를 여러 형태로 변환하는 것을 말합니다.  
간단한 형태의 on-demand ETL이라고 생각하면 됩니다.

EDA는 다들 알다시피 탐색적데이터분석(Exploratory Data Analysis)입니다.

우선 [bigdatahub.co.kr](http://bigdatahub.co.kr)에서 콜택시/대리운전 데이터를 다운로드 모두 받습니다.  
tsv 형식으로 받으면 좋습니다.  
csv형식은 escaping등의 문제가 늘있으므로 문제를 미연에 방지하기 위해 TSV형식을 사용합니다.  
TSV형식은 Tab Seprated View의 약어로 delimiter가 tab 문자로 구분된 형식입니다.

이 예제에서 파일들이 저장된 경로는 다음과 같습니다.  
각자의 경로에 맞게 잘 수정하시기 바랍니다.


```r
filepath <- "/Users/euriion/Downloads/skt_datahub/seoul_calltaxi/"
```


저장된 파일 목록을 살펴봅니다.


```r
system(paste("cd", filepath, "; ", "ls -1 *.tsv"))
```


이제 파일이름들로 된 character 타입 벡터를 하나 만들어 줍니다.  
copy & paste를 하시던가 타이핑을 열심히 하던가 해야 합니다.

```r
filenames <- 
  c("서울지역+콜택시+대리운전+이용분석_2013년+8월.tsv",
    "서울_콜택시_대리운전이용분석_201309.tsv",
    "서울_콜택시_대리운전이용분석_201310.tsv",
    "서울_콜택시_대리운전이용분석_201311.tsv",
    "서울_콜택시_대리운전이용분석_201312.tsv",
    "서울_콜택시_대리운전이용분석_201401.tsv",
    "서울_콜택시_대리운전이용분석_201402.tsv")
```

다른 tsv파일들이 들어있지 않다면 타이핑하지 않고 그냥 불러올 수 있습니다.  
오타방지와 노동력 낭비 방지를 위해서도 이 방법이 더 낫습니다.  
system 펑션에 intern 옵션을 True로 해주면 됩니다.  


```r
filenames <- system(paste("cd", filepath, "; ", "ls -1 *.tsv"), intern = T)
```


filename들이 잘 정해졌는지 봅니다.


```r
filenames
```

```
## [1] "서울_콜택시_대리운전이용분석_201309.tsv"   "서울_콜택시_대리운전이용분석_201310.tsv"   "서울_콜택시_대리운전이용분석_201311.tsv"  
## [4] "서울_콜택시_대리운전이용분석_201312.tsv"   "서울_콜택시_대리운전이용분석_201401.tsv"   "서울_콜택시_대리운전이용분석_201402.tsv"  
## [7] "서울지역+콜택시+대리운전+이용분석_2013년+8월.tsv"
```


7개의 파일이 잘 있습니다.  
> 한글 자모가 분리된 형태로 보일 수 있는데 제 작업PC가  Mac OS X라서 그렇습니다.
> 문제는 없습니다.

이제 읽어들일 파일이 헤더가 포함되었는지와 모든 헤더들이 동일한지  간단히 확인합니다.  
만약 헤더가 일치하지 않으면 data.frame을 머지(merge)할 때 곤란해집니다.  
편의를 위해서 unix 명령을 사용할 것이고 Mac OS X나 Linux를 사용하고 있다면 바로 쓸 수 있습니다.  
R을 windows를 사용하고 있다면 msys나 cygwin등을 설치하거나 수작업으로 하는 방법이 있습니다.


```r
system(paste("cd", filepath, "; ", "ls -1 *.tsv | xargs -n 1 head -1  | sort | uniq -c"))
```


결과를 보면 한 개의 파일이 다른 헤더를 가지고 있음을 알 수 있습니다.  
아마도 "서울지역+콜택시+대리운전+이용분석_2013년+8월.tsv"라는 파일이름을 가진 파일이 원흉일 것입니다.  

여튼 header들이 일치하지 않는데 결국  header를 고쳐주거나 header를 무시하고 읽어온 뒤에 header를 다시 붙여주는 방법을 사용해야 합니다.  
그리고 어차피 컬럼명이 한글이므로 header는포기하는 것이 유리합니다.  
header를 포기하고 column name들은 임의로 붙일 것입니다.

자 이제 여러 tsv를 읽어서 하나 data.frame으로 만들어야 합니다.  
그래야 다루기 쉽습니다.

7번 읽어서 rbind하는 방법등 여러가지 방법이 있습니다.
그 외에도 방법은 여러가지가 있습니다만  
여기서는 작업의 편의를 위해서 plyr를 이용해서 한 번에 읽어 버리도록 하겠습니다.

plyr을 불러옵니다.  
설치가 되어 있지 않다면 당연히 설치를 해 주어야 합니다.


```r
if (!require(plyr)) {
    install.packages("plyr")
}
```

```
## Loading required package: plyr
```


이제 paste0를 이용해 파일 이름들의 fullpath 벡터를 만들어줍니다.


```r
filenames.fullpath <- paste0(filepath, filenames)
filenames.fullpath
```

```
## [1] "/Users/euriion/Downloads/skt_datahub/seoul_calltaxi/서울_콜택시_대리운전이용분석_201309.tsv"  
## [2] "/Users/euriion/Downloads/skt_datahub/seoul_calltaxi/서울_콜택시_대리운전이용분석_201310.tsv"  
## [3] "/Users/euriion/Downloads/skt_datahub/seoul_calltaxi/서울_콜택시_대리운전이용분석_201311.tsv"  
## [4] "/Users/euriion/Downloads/skt_datahub/seoul_calltaxi/서울_콜택시_대리운전이용분석_201312.tsv"  
## [5] "/Users/euriion/Downloads/skt_datahub/seoul_calltaxi/서울_콜택시_대리운전이용분석_201401.tsv"  
## [6] "/Users/euriion/Downloads/skt_datahub/seoul_calltaxi/서울_콜택시_대리운전이용분석_201402.tsv"  
## [7] "/Users/euriion/Downloads/skt_datahub/seoul_calltaxi/서울지역+콜택시+대리운전+이용분석_2013년+8월.tsv"
```


파일 이름이 절대경로로 잘 붙어 있는 것을 확인할 수 있습니다.

자 이제 ldply를 이용해서 몽땅 불러옵니다.  
header를 읽지 않기 위해서 skip=1 옵션을 준 것을 주의하세요.


```r
df <- ldply(filenames.fullpath, function(filename) data.frame(Filename = filename, 
    read.table(filename, , sep = "\t", header = F, skip = 1)))
```


자 읽어 왔습니다. 내용을 확인해 봅니다.

```r
head(df)
```

확인해보니 ldply를 사용하면서column이 하나 더 붙었습니다만  
그것은 나중에 확인하기로 하고  
우선 레코드를 빼먹지 않고 모두 data.frame으로 읽어 왔는지 확인해 봅니다.

```r
NROW(df)
```

총 3115 개의 레코드가 읽혔는데 맞는지 확인해 봅니다.

unix명령어의 wc를 이용해서 확인합니다.


```r
system(paste("cd", filepath, "; ", "wc -l *.tsv"))
```


3122개가 나왔는데 header의 개수 7을 빼면 3115가 맞습니다.

자 이제 컬럼명을 바꿔줍니다.  
원래 컬럼명은 아래와 같습니다.


```r
colnames(df)
```

```
## [1] "Filename" "V1"       "V2"       "V3"       "V4"       "V5"
```


안 바꿔도 되겠지만 컬럼의 의미를 인식하기 어려우므로 바꿔줍니다.  
그전에 맨 앞의 컬럼은 filename인데 쓸모가 없으므로 먼저 제거합니다.


```r
df <- df[-1]
```


이제 컬럼명을 붙여줍니다.  
> 컬럼이름이 무식하지만 체신청에서도 채택하고 있는  전통적으로 많이 쓰는 스타일입니다.


```r
colnames(df) <- c("yearmon", "sido", "gugun", "dong", "freq")
```


잘 바뀌었는지 확인해 봅니다.


```r
head(df)
```

```
##   yearmon       sido  gugun      dong freq
## 1  201309 서울특별시 강남구  압구정동    5
## 2  201309 서울특별시 강남구   일원2동    8
## 3  201309 서울특별시 강남구   대치3동   39
## 4  201309 서울특별시 강남구    일원동   55
## 5  201309 서울특별시 강남구 압구정1동   82
## 6  201309 서울특별시 강남구   대치1동   87
```


다 되었습니다.

여기까지 데이터를 읽어오는 과정이었습니다.

