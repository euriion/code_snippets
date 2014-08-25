# http://www.datasciencetoolkit.org/
# Jira: http://confluence.atlassian.com/display/JIRA043/JIRA+REST+API+(Alpha)+Tutorial
# http://www.datasciencetoolkit.org/
# Jira: http://confluence.atlassian.com/display/JIRA043/JIRA+REST+API+(Alpha)+Tutorial

library(bitops)
library(rjson)
library(RCurl)

apiURLPrefix <- "http://jira.nexrcorp.com/rest/api/latest"
authURLPrefix <- "http://jira.nexrcorp.com/rest/auth/latest"
wwwURLPrefix <- "http://jira.nexrcorp.com"

ip2coordinates <- function(ip) {
  api <- "http://www.datasciencetoolkit.org/ip2coordinates/"
  result <- getURL(paste(api, URLencode(ip), sep=""))
  names(result) <- "ip"
  return(result)
}
# ip2coordinates('67.169.73.113')

getAPIResult <- function(url) {
  headerGatherer <- basicHeaderGatherer()
  contentGatherer <- basicTextGatherer()
  
  curlPerform(url=url,
      httpheader=c(Cookie=sessionInfo$cookie, Accept="application/json", Accept="text/xml", Accept="multipart/*", 'Content-Type' = "application/json; charset=utf-8"),
      headerfunction=headerGatherer$update,
      writefunction=contentGatherer$update,
      verbose = F
  )
  
  # header <- headerGatherer$value()
  body <- contentGatherer$value()
  return(fromJSON(body))
}

getIssue <- function(issueKey) {
  getAPIResult(sprintf("%s/issue/%s", apiURLPrefix, issueKey))
}

makeLinkUserProfile <- function(userName) {
  sprintf("%s/secure/ViewProfile.jspa?name=%s", wwwURLPrefix, userName)
}

makeLinkIssue <- function(issueKey) {
  sprintf("<a class='issuelink' href='%s/browse/%s' target='_blank'>%s</a>", wwwURLPrefix, issueKey, issueKey)
}

makeAvatarImage <- function(userName) {
  urlAvatar <- sprintf("%s/secure/useravatar?size=small&ownerId=%s", wwwURLPrefix, userName)
  sprintf("<a href='%s' target='_blank'><img border='0' src='%s' /></a>", makeLinkUserProfile(userName), urlAvatar)
}

loginAsAUser <- function(userName, password) {
  apiURL <- sprintf("%s/%s", authURLPrefix, "session")
  jsonContent <- toJSON(list("username"=userName, "password"=password))
  
  headerGatherer <- basicHeaderGatherer()
  contentGatherer <- basicTextGatherer()
  
  curlPerform(url=apiURL,
      httpheader=c(Accept="application/json", Accept="text/xml", Accept="multipart/*", 'Content-Type' = "application/json; charset=utf-8"),
      postfields=jsonContent,
      headerfunction=headerGatherer$update,
      writefunction=contentGatherer$update,
      verbose = F
  )
  
  header = headerGatherer$value()
  
  cookieList <- header[names(header) == "Set-Cookie"]
  cookieValues <- as.vector(as.matrix(as.data.frame(cookieList)))
  newCookieValues <- c()
  for (cookieItem in cookieValues) {
    newCookieValues <- c(newCookieValues, gsub(";(.*)","", cookieItem))
  }
  
  cookie <- paste(newCookieValues, sep="", collapse="; ")
  body <- contentGatherer$value()
  
  return(list(header=header, body=body, cookie=cookie))
}

getJQLSearchResult <- function(jql, startAt=0, maxResults=500) {
  startAt <- format(startAt, scientific = F)
  maxResults <- format(maxResults, scientific = F)
  
  jqlEscaped <- curlEscape(jql)
  urlJqlSearch <- sprintf("http://jira.nexrcorp.com/rest/api/latest/search?jql=%s&startAt=%s&maxResults=%s", jqlEscaped, startAt, maxResults)
  headerGatherer <- basicHeaderGatherer()
  contentGatherer <- basicTextGatherer()
  
  curlPerform(url=urlJqlSearch,
      httpheader=c(Cookie=sessionInfo$cookie, Accept="application/json", Accept="text/xml", Accept="multipart/*", 'Content-Type' = "application/json; charset=utf-8"),
      #postfields=jsonContent,
      headerfunction=headerGatherer$update,
      writefunction=contentGatherer$update,
      verbose = F
  )
  
  # header <- headerGatherer$value()
  body <- contentGatherer$value()
  return(body)
}

getOpenedIssuesByUser <- function(userName) {
  jql <- sprintf("assignee = '%s' and status in ('Open', 'In Progress', 'Reopened', 'Start')",userName)
  jqlResult <- getJQLSearchResult(jql)
  return(fromJSON(jqlResult))
}

getRecentIssuesByUser <- function(userName) {
  #assignee = 'aiden.hong' and (updated >= '-7d' or status in ('Open', 'Start'))
  jql <- sprintf("assignee = '%s' and (updated >= '-7d' or status in ('Open', 'In Progress', 'Reopened', 'Start'))",userName)
  jqlResult <- getJQLSearchResult(jql)
  #print(jqlResult)
  return(fromJSON(jqlResult))
}

sessionInfo <- loginAsAUser("aiden.hong", "Surd2duress!")

users <- c(
    "aiden.hong", 
    "haven.jeon", 
    "eugene.hwang", 
    "irene.kwon", 
    "antony.ryu", 
    "eric.kim"
    )
    
extrausers <- c()

#extrausers <- c(
#    "joe.lim",
#    "jun.cho",
#    "ash.ahn",
#    "bella.yun",
#    "erica.park",
#    "peter.chae",
#    "ryan.han")

