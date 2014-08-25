#http://wiki.nexrcorp.com/rest/prototype/1/content/2588817

filename <- "/Users/aidenhong/Documents/workspace/jirastat/html/scripts/userdata.txt"

fd <- file(filename, "r", blocking = FALSE)
content <- readLines(filename, encoding="UTF-8", warn=F)
content <- content[c(-1:-5)]
pattern <- "[|] (.*) [|] (.*)[(](.*)[)] [|] aiden.hong [|] Aiden [|] aiden.hong@nexr.com [|] 010-6390-3838 [|] 서울시 서초구 방배동 463-10 [|] euriion [|] [|] euriion [|] euriion@gmail.com [|] [|] 03.08(양) [|]"
pattern <- paste(rep("[|]([^|]*?)", 14), sep="", collapse="")
userlist <- str_match(content, pattern)
class(userlist)
userlist <- as.data.frame(userlist)
userlist <- sapply(userlist, str_trim)
row.names(userlist) <- userlist[,5]
#userlist <- userlist[,-1]
userlist <- as.data.frame(userlist)

replace <- "\\2"
gsub(pattern, replace, content, perl=T)
str_replace_all(content, "\\\\", "")
content_m <- paste(content ,sep="", collapse="")
content_m <- str_replace_all(content_m, "[|][|]", "|\n|")


str_replace_all(content, pattern, replace)
m <- gregexpr(pattern, content, perl=T)
regmatches(content, m)
sub(pattern, replace, content, perl=T)
close(fd)