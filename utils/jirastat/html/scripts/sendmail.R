library(base64)
library(sendmailR)

now <- Sys.time()
today <- format(as.POSIXlt(now, tz="GMT-9"), format="%Y-%m-%d")
weekday <- format(as.POSIXlt(now, tz="GMT-9"), format="%u")
ampm <- format(as.POSIXlt(now, tz="GMT-9"), format="%p")

special_message <- ""

if (weekday == 5) {
  special_message <- "\n즐거운 주말을 위해서 꼭 이슈들을 정리하세요."
}

body <- sprintf("
지라봇 v0.1이 알려드립니다.
소유한 이슈들에 각각 작업내역과 소모시간을 기재하세요.
여러분의 노력이 각자에게 소중한 자산이 됩니다.
아래의 페이지에 섭족하시면 여러분의 이슈를 쉽게 확인하실 수 있습니다. 
http://143.248.161.124/jirastat/dashboard.rhtml

감사합니다.
", today, special_message
)

title <- sprintf("[JIRA bot] %s - please update your status", today)

fromAddr <- "datascience@nexr.com"

toAddrs <- c(
    "antony.ryu@nexr.com",
    "eugene.hwang@nexr.com",
    "haven.jeong@nexr.com",
    "irene.kwon@nexr.com",
    "aiden.hong@nexr.com"
)

for (toAddr in toAddrs) {
  sendmail(
      from = fromAddr, 
      to = toAddr, 
      subject = title, 
      msg = body, 
      headers = list("Content-Type"="text/html; charset=UTF-8; format=flowed")
  )
}
