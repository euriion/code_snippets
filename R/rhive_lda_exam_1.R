# install.packages(RHive)
library(RHive)
rhive.connect()

apropos("^rhive")  # checking RHive functions

# 1. 연결
rhive.connect()  # rhive.connect("localhost") or rhive.connect("127.0.0.1")
# 2. database 목록 확인
rhive.show.databases()
# 3. database 선택
rhive.use.database("ndapdemo")
# 4. table 목록 확인
rhive.show.tables()
# 5. table spec 확인
rhive.desc.table("tmp_dedup_traffic_raw")
# 6. EDA nad wrangling

# 6.1 table spec 확인
rhive.desc.table("tmp_dedup_traffic_raw")
 
# 6.2 key중복 확인
system.time(
  rhive.query("SELECT COUNT(*) AS traffic_raw_cnt FROM traffic_raw")
)

system.time(
  rhive.query("SELECT COUNT(distinct rpt_id) AS traffic_raw_cnt FROM traffic_raw")
)

rhive.query("SELECT COUNT(distinct rpt_id) AS traffic_raw_cnt FROM traffic_raw")

# 기존 임시테이블삭제
rhive.query("DROP TABLE IF EXISTS tmp_deduped_traffic_raw")

# 중복제거된 테이블 생성
rhive.query("CREATE TABLE tmp_deduped_traffic_raw AS
SELECT
  rpt_id,
  MAX(rpt_content) AS rpt_content,
  MAX(info_type)   AS info_type  ,
  MAX(info_title)  AS info_title ,
  MAX(occ_dtime)   AS occ_dtime  ,
  MAX(reg_dtime)   AS reg_dtime  ,
  MAX(end_dtime)   AS end_dtime  ,
  MAX(start_x)     AS start_x    ,
  MAX(start_y)     AS start_y    ,
  MAX(end_x)       AS end_x      ,
  MAX(end_y)       AS end_y
FROM traffic_raw
GROUP BY rpt_id
ORDER BY rpt_id DESC")

rhive.show.tables("^tmp_de")

# 테이블크기확인
rhive.desc.table("tmp_deduped_traffic_raw", detail=T)
rhive.desc.table("traffic_raw", detail=T)

traffic_data <- rhive.load.table("tmp_deduped_traffic_raw")
traffic_data <- rhive.load.table2("tmp_deduped_traffic_raw")
head(traffic_data)
length(unique(traffic_data$rpt_id))
colnames(traffic_data)
table(traffic_data$info_type)

# -- NA 제거
traffic_data_cleaned <- traffic_data[!is.na(traffic_data$rpt_id) ,]

# -- 플로팅
library(ggplot2)

# -- 단순 bar chart
ggplot(traffic_data_cleaned, aes(x=info_title,y=..count..)) + geom_bar(color="blue", fill="navy")

# -- 단순 pie chart
ggplot(traffic_data_cleaned, aes(x=factor(1),fill=info_title)) + geom_bar(width=1) + coord_polar(theta="y")

traffic_data_cleaned[traffic_data_cleaned$info_title == '행사/집회',]

# install.packages(c("RTextTools","topicmodels"))
library(RTextTools)
library(topicmodels)
library(stringr)

# -- 텍스트 랭글링
rpt_content <- traffic_data_cleaned$rpt_content
head(rpt_content)
rpt_content <- str_replace_all(rpt_content, " → ", " ")
rpt_content <- str_replace_all(rpt_content, "\\(", " ")
rpt_content <- str_replace_all(rpt_content, "\\)", " ")
rpt_content <- str_replace_all(rpt_content, "[,]", " ")
head(rpt_content)
rpt_content <- str_replace_all(rpt_content, "1차로에", "1차로")
rpt_content <- str_replace_all(rpt_content, "2Km구간과", "2Km구간")
rpt_content <- str_replace_all(rpt_content, "5차로에", "5차로")
rpt_content <- str_replace_all(rpt_content, "간", "")
rpt_content <- str_replace_all(rpt_content, "갓길에", "갓길")
rpt_content <- str_replace_all(rpt_content, "강풍이", "강풍")
rpt_content <- str_replace_all(rpt_content, "고장차여파로", "고장차 여파")
rpt_content <- str_replace_all(rpt_content, "고장차지점을", "고장차 지점")
rpt_content <- str_replace_all(rpt_content, "교보타워4거리부터", "교보타워4거리")
rpt_content <- str_replace_all(rpt_content, "구간구간", "")
rpt_content <- str_replace_all(rpt_content, "끝나", "")
rpt_content <- str_replace_all(rpt_content, "끝났으나", "끝")
rpt_content <- str_replace_all(rpt_content, "동탄분기점까지", "동탄분기점")
rpt_content <- str_replace_all(rpt_content, "못", "")
rpt_content <- str_replace_all(rpt_content, "방호벽보수작업은", "방호벽보수작업")
rpt_content <- str_replace_all(rpt_content, "불고있어", "")
rpt_content <- str_replace_all(rpt_content, "서하남나들목진출로만", "서하남나들목진출로")
rpt_content <- str_replace_all(rpt_content, "석바위4거리부터", "석바위4거리")
rpt_content <- str_replace_all(rpt_content, "성수대교부터", "성수대교")
rpt_content <- str_replace_all(rpt_content, "세척작업으로", "")
rpt_content <- str_replace_all(rpt_content, "안성나들목진출로에", "안성나들목진출로")
rpt_content <- str_replace_all(rpt_content, "이", "")
rpt_content <- str_replace_all(rpt_content, "이전부터", "이전")
rpt_content <- str_replace_all(rpt_content, "지나면", "")
rpt_content <- str_replace_all(rpt_content, "지난", "")
rpt_content <- str_replace_all(rpt_content, "지점에", "")
rpt_content <- str_replace_all(rpt_content, "차량증가로", "차량증가")
rpt_content <- str_replace_all(rpt_content, "처리작업은", "처리작업")
rpt_content <- str_replace_all(rpt_content, "추돌사고로", "추돌사고")
rpt_content <- str_replace_all(rpt_content, "충주휴게소부근", "충주휴게소 부근")
rpt_content <- str_replace_all(rpt_content, "판교분기점부근", "판교분기점 부근")
rpt_content <- str_replace_all(rpt_content, "판교에서", "판교")
rpt_content <- str_replace_all(rpt_content, "하고있어", "")
rpt_content <- str_replace_all(rpt_content, "홍제램프", "")
rpt_content <- str_replace_all(rpt_content, "화물이", "화물")
rpt_content <- str_replace_all(rpt_content, "화물차끼리", "화물차")

rpt_content <- str_replace_all(rpt_content, "차로에 ", "차로 ")
rpt_content <- str_replace_all(rpt_content, "부터 ", " ")
rpt_content <- str_replace_all(rpt_content, "으로 ", " ")
rpt_content <- str_replace_all(rpt_content, "작업을 ", "작업 ")
rpt_content <- str_replace_all(rpt_content, "있었던 ", " 있었던 ")
rpt_content <- str_replace_all(rpt_content, " 있었던", " 있었던 ")

rpt_content <- str_replace_all(rpt_content, "([0-9]거리)", " \\1 ")
rpt_content <- str_replace_all(rpt_content, "앞", " 앞 ")

# 긴 공백 정리
rpt_content <- str_replace_all(rpt_content, "[ ]{2,}", " ")

head(rpt_content)

# 매츄릭스 생성
traffic_data_matrix <- create_matrix(cbind(rpt_content), removeNumbers=TRUE, stemWords=FALSE, weighting=weightTf)

# Latent Dirichlet Allocation
# k=10
traffic_data_lda <- LDA(traffic_data_matrix, 10)

# 텀 확인
terms(traffic_data_lda, 20)

# 토픽 확인
topics(traffic_data_lda)


