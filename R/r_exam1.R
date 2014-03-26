
# data <- read.table("/Users/aidenhong/Documents/workspace/big_r/example/server_status.csv", sep=",", header=TRUE)
data <- read.table("/mnt/aidenhong/big_r/example/server_status.csv.withheader", sep=",", header=TRUE)
#data <- read.table("/mnt/aidenhong/big_r/example/2008.fixed.csv", sep=",", header=TRUE)

values <- as.numeric(data$processes_proc)
#values <- as.numeric(data$Distance)
proc_qaurtiles <- quantile(values, c(0.25,0.50,0.75))
proc_sum <- sum(values)
proc_count <- length(values)
proc_mean <- mean(values)

for (percent in names(proc_qaurtiles)) {
  print(sprintf("%s = %s", percent, proc_qaurtiles[percent]))
}

print(sprintf("sum = %s", proc_sum))
print(sprintf("count = %s", proc_count))
print(sprintf("mean = %s", proc_mean))

# The results of 1st data are as below
# [1] "25% = 7.3575"
# [1] "50% = 8.71"
# [1] "75% = 9.33"
# [1] "sum = 19996.9"
# [1] "count = 2372"
# [1] "mean = 8.43039629005059"
# 
# real    0m1.300s
# user    0m1.188s
# sys     0m0.080s

# The results of 2nd data are as below
# [1] "25% = 325"
# [1] "50% = 581"
# [1] "75% = 954"
# [1] "sum = 5091775499"
# [1] "count = 7009728"
# [1] "mean = 726.387029425393"
# 
# real    2m15.949s
# user    2m6.352s
# sys     0m9.465s
