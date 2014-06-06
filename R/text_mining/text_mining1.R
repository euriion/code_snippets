install.packages("twitteR")
library(twitteR)

# Twitter에 Sign-in
# 아래 URL로 이동해서 애플리케이션을 등록하고 키를 받음
# https://apps.twitter.com/app/new

reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- "ANPrgnMiHNj0z7Q04heV5AIgR"
consumerSecret <- "GxOHj6L1HOku2j5Ws75O1dePx3YUtxvhCZyoRWL3GtXq9vzrb7"
twitCred <- OAuthFactory$new(consumerKey=consumerKey, consumerSecret=consumerSecret, requestURL=reqURL,
                             accessURL=accessURL, authURL=authURL)
# options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package =  "RCurl")))
#twitCred$handshake(cainfo="cacert.pem")
twitCred$handshake()

registerTwitterOAuth(twitCred)
# save(list="twitCred", file="twitteR_credentials")
# load("twitteR_credentials")
twitter_data <- searchTwitter(searchString="세월호",n=9999)
# save(file="twitter_data.Rdata", twitter_data)
text_list <- sapply(twitter_data, FUN=function(x) {x$getText()})
head(text_list)

# install.packages("KoNLP")
library(KoNLP)
useSejongDic(backup = T)
mergeUserDic(data.frame("세월호", "ncn"))
mergeUserDic(data.frame("대한민국", "ncn"))
extraced <- sapply(text_list, function(x) {extractNoun(x)}, USE.NAMES=F)
nouns <- unlist(extraced[1:length(extraced)])
nouns.table <- table(nouns)
nouns.df <- as.data.frame(nouns.table)
blacklist <- c("세월호", "RT", "http", "t", "한", "들", "것", "해", "말", "수", "호", "…")
nouns.df <- nouns.df[!(nouns.df$nouns %in% blacklist),]
nouns.df <- nouns.df[str_length(nouns.df$nouns) > 1,]
colnames(nouns.df) <- c("term", "freq")
head(nouns.df[order(nouns.df$freq, decreasing=T),], 50)
# -----------------------------------------------------
boxplot(nouns.df$freq)
hist(nouns.df$freq)
nouns.df <- nouns.df[str_length(nouns.df$Freq) > 1,]
dim(nouns.df)


# install.packages("wordcloud")
library(wordcloud)
par(family="NanumGothic")
wordcloud(nouns.df$term, nouns.df$freq, colors=brewer.pal(length(nouns.df$term),"Dark2"))
# -----------------------------------------------------
# 
# -----------------------------------------------------
# install.packages("tm")
# install.packages("proxy")
library(tm)

doc_list <- vapply(extraced, function(x){
  paste(x, sep=" ", collapse=" ")
}, FUN.VALUE="")

tw_src <- DataframeSource(data.frame(doc_list), encoding="UTF8")
tw_corpus <- Corpus(tw_src)
tw_corpus <- tm_map(tw_corpus, removeNumbers)
tw_corpus <- tm_map(tw_corpus, removePunctuation)
tw_corpus <- tm_map(tw_corpus, stripWhitespace)
tw_corpus <- tm_map(tw_corpus, removeWords, sw)
twitter_dtm <- TermDocumentMatrix(tw_corpus, control=list(
  weighting=weightTfIdf,
  tolower=F,
  removeNumbers=F,
  minWordLength=2,
  removePunctuation=TRUE,
  wordLengths=c(2,50),
  stopwords=c("coGsZYdgAX", "codViUaDtA", "RT", "co", "httpt", "seojuho", "mettayoon")
))
head(inspect(twitter_dtm))  # TF-IDF확인
findFreqTerms(twitter_dtm, 2, 3)  # Freq 레인지에 포함된 단어
dissimilarity(twitter_dtm, method="cosine")  # 코사인유사도
findAssocs(twitter_dtm, c("침몰"), 0.3) # 연관단어
