install.packages("data.table")
install.packages("ff")
library(data.table)
library(ff)

# source file size
-rw-rw-r--. 1 aiden.hong aiden.hong  28G 2013-05-10 15:08 vrm.merged.16x.csv
-rw-rw-r--. 1 aiden.hong aiden.hong 3.5G 2013-05-10 15:06 vrm.merged.2x.csv
-rw-rw-r--. 1 aiden.hong aiden.hong  56G 2013-05-10 15:12 vrm.merged.32x.csv
-rw-rw-r--. 1 aiden.hong aiden.hong 7.0G 2013-05-10 15:06 vrm.merged.4x.csv
-rw-rw-r--. 1 aiden.hong aiden.hong 112G 2013-05-10 15:50 vrm.merged.64x.csv
-rw-rw-r--. 1 aiden.hong aiden.hong  14G 2013-05-10 15:07 vrm.merged.8x.csv
-rwxrwxr-x. 1 aiden.hong aiden.hong 1.8G 2013-05-10 14:05 vrm.merged.csv


filename<-"/home/aiden.hong/HKMC_VRM/converted/csv/vrm.merged.csv"
system.time(dt <- fread(filename, sep=";")) 
#사용자  시스템 elapsed 
#32.120   0.601  32.763 
ls()
rm(dt)
gc()

# ---------------------------------------------------------------------------------------

filename<-"/home/aiden.hong/HKMC_VRM/converted/csv/vrm.merged.32x.csv"
system.time(dt <- fread(filename, sep=";")) 
#사용자   시스템  elapsed 
#1056.637   44.294 1104.756 
ls()
rm(dt)
gc()

system.time(ffdf <- read.csv.ffdf(file=filename, sep=";"))
# 안끝남
ls()
rm(ffdf)
gc()

require(sqldf)
#install.packages("sqldf")
library(sqldf)
# ---------------------------------------------------------------------------------------
# -rw-rw-r--. 1 aiden.hong aiden.hong 112G 2013-05-10 15:50 vrm.merged.64x.csv
filename<-"/home/aiden.hong/HKMC_VRM/converted/csv/vrm.merged.64x.csv"
system.time(d <- read.table(file=filename, sep=";", header=F))  # error
#다음에 오류가 있습니다scan(file, what, nmax, sep, dec, quote, skip, nlines, na.strings,  : 
#                   could not allocate memory (2048 Mb) in C function 'R_AllocStringBuffer'

system.time(ffdf <- read.csv.ffdf(file=filename, sep=";"))
# Never ending...

system.time(dt <- fread(filename, sep=";")) 
#사용자   시스템  elapsed 
#2027.036  196.983 2358.724 
df <- as.data.frame(dt)
#에러: 크기가 3.6 Gb인 벡터를 할당할 수 없습니다.
# 에러

f <- file("/home/aiden.hong/HKMC_VRM/converted/csv/vrm.merged.64x.csv")
system.time(bigdf <- sqldf("select * from f", dbname = tempfile(), file.format=list(header = F, row.names = F, sep=";")))


