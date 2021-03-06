
empText<-"id,ename,position,dep,enterdate,sal,status,age
100,nick,developer,10,20110401,9000,good,20
200,job,developer,20,20110901,1500,bad,32
300,jac,developer,30,20010301,2000,good,41
400,nexr,manager,10,20110801,20000,good,22
500,jun,developer,10,20050701,10000,soso,41
600,hun,developer,30,20030801,5000,good,50
700,julia,officer,20,20110501,7000,good,8
800,kara,song,20,20110201,3000,good,20
900,na,,20,20110201,3000,bad,20"

emp <- read.table(file=textConnection(empText), header=T, sep=",")
rhive.write.table(emp)

coefficient <- 1.1
scoring <- function(sal) {
    coefficient * sal
}
rhive.assign('coefficient',coefficient)
rhive.assign('scoring',scoring)
rhive.exportAll('scoring')
rhive.query("select R('scoring',col_sal,0.0) from emp")
