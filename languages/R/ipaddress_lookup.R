# install.packages("XML")
library(RCurl)
library(XML)
# exam: http://whois.kisa.or.kr/openapi/whois.jsp?query=[도메인이름, IP주소, AS번호]&key=2012101113592433005256
# NexR IP address: 183.98.30.10
# sample url: http://whois.kisa.or.kr/openapi/whois.jsp?query=183.98.30.10&key=2012101113592433005256
#ipaddress <- '183.98.30.10'
#ipaddress <- '210.118.193.165'
# 오수지
# 10000

#url <- sprintf("http://whois.kisa.or.kr/openapi/whois.jsp?query=%s&key=2012101113592433005256", ipaddress)


ndat.ipaddresslookup <- function(ipaddress) {
  extract.entity <- function(xml.string) {
    xml.doc <- xmlParse(xml.string)
#     country <- getNodeSet(xml.doc, "//whois/countryCode/text()")[[1]]
#     korean.ISP.orgName <- getNodeSet(xml.doc, "//whois/korean/ISP/netInfo/orgName/text()")[[1]]
#     korean.ISP.servName <- getNodeSet(xml.doc, "//whois/korean/ISP/netInfo/servName/text()")[[1]]
#     korean.user.orgName <- getNodeSet(xml.doc, "//whois/korean/user/netInfo/orgName/text()")[[1]]
#     korean.user.addr <- getNodeSet(xml.doc, "//whois/korean/user/netInfo/addr/text()")[[1]]
#     
#     english.ISP.orgName <- getNodeSet(xml.doc, "//whois/english/ISP/netInfo/orgName/text()")[[1]]
#     english.ISP.servName <- getNodeSet(xml.doc, "//whois/english/ISP/netInfo/servName/text()")[[1]]
#     english.user.orgName <- getNodeSet(xml.doc, "//whois/english/user/netInfo/orgName/text()")[[1]]
#     english.user.addr <- getNodeSet(xml.doc, "//whois/english/user/netInfo/addr/text()")[[1]]
  xqueries <- c(
    "//whois/countryCode/text()",
    "//whois/korean/ISP/netInfo/orgName/text()",
    "//whois/korean/ISP/netInfo/servName/text()",
    "//whois/korean/user/netInfo/orgName/text()",
    "//whois/korean/user/netInfo/addr/text()",
    "//whois/english/ISP/netInfo/orgName/text()",
    "//whois/english/ISP/netInfo/servName/text()",
    "//whois/english/user/netInfo/orgName/text()",
    "//whois/english/user/netInfo/addr/text()"
  )


    
#   result <- c(
#       country,
#       korean.ISP.orgName,
#       korean.ISP.servName,
#       korean.user.orgName,
#       korean.user.addr,
#       english.ISP.orgName,
#       english.ISP.servName,
#       english.user.orgName,
#       english.user.addr
#     )
#     
 #    country <- getNodeSet(xml.doc, "//whois/countryCode/text()")[[1]]
#     korean.ISP.orgName <- getNodeSet(xml.doc, "//whois/korean/ISP/netInfo/orgName/text()")[[1]]
#     korean.ISP.servName <- getNodeSet(xml.doc, "//whois/korean/ISP/netInfo/servName/text()")[[1]]
#     korean.user.orgName <- getNodeSet(xml.doc, "//whois/korean/user/netInfo/orgName/text()")[[1]]
#     korean.user.addr <- getNodeSet(xml.doc, "//whois/korean/user/netInfo/addr/text()")[[1]]
#     
#     english.ISP.orgName <- getNodeSet(xml.doc, "//whois/english/ISP/netInfo/orgName/text()")[[1]]
#     english.ISP.servName <- getNodeSet(xml.doc, "//whois/english/ISP/netInfo/servName/text()")[[1]]
#     english.user.orgName <- getNodeSet(xml.doc, "//whois/english/user/netInfo/orgName/text()")[[1]]
#     english.user.addr <- getNodeSet(xml.doc, "//whois/english/user/netInfo/addr/text()")[[1]]
#       
    result <- sapply(xqueries, 
      function(x){
        v <- xmlValue(getNodeSet(xml.doc, "//whois/korean/ISP/netInfo/orgName/text()")[[1]])
        if (is.na(v) || is.null(v)) {
          return("")
        }
        return(v)
      },
      USE.NAMES=FALSE
    )
 
    return(result)
  }

  url <- sprintf("http://whois.kisa.or.kr/openapi/whois.jsp?query=%s&key=2012101113592433005256", ipaddress)
  xml.content <- getURL(url)

  result <- sapply(xml.content, extract.entity)
  result <- cbind(ipaddress, t(result))
  row.names(result) <- NULL
  colnames(result) <- c(
    "ipaddress", 
    "country", 
    "korean_ISP_orgName",
    "korean_ISP_servName",
    "korean_user_orgName",
    "korean_user_addr",
    "english_ISP_orgName",
    "english_ISP_servName",
    "english_user_orgName",
    "english_user_addr"
  )
  return(as.data.frame(result))
}

# -- example
ipaddress <- c(
  '183.98.30.10',
  '210.118.193.165'
)
ipaddress <- "123.123.213.123"
url <- sprintf("http://whois.kisa.or.kr/openapi/whois.jsp?query=%s&key=2012101113592433005256", ipaddress)
  xml.content <- getURL(url)
  xml.string <- xml.content
  xml.doc <- xmlParse(xml.string)

d <- ndat.ipaddresslookup(ipaddress)
d[,'korean_user_orgName']

