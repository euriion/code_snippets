fd <- file("/mnt/aidenhong/big_r/example/server_status.csv", open="rt") 
#fd <- file("/mnt/aidenhong/big_r/example/2008.nohead.fixed.csv", open="rt")
on.exit(close(fd))

total_sum <- 0
total_count <- 0
result_mean <- 0

total_count <- 0
while(length(raw_line <- readLines(fd, 1)) > 0) {
    record <- unlist(strsplit(raw_line, ","))
    total_sum <- total_sum + as.numeric(record[4])
    total_count <- total_count + 1
}

result_mean <- total_sum / total_count

print(sprintf("sum = %s", total_sum))
print(sprintf("count = %s", total_count))
print(sprintf("mean = %s", result_mean))

close(fd)

# First results
# [1] "sum = 19996.9"
# [1] "count = 2372"
# [1] "mean = 8.4303962900506"
# 
# real    0m1.714s
# user    0m1.628s
# sys     0m0.048s

