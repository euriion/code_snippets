library(Rhipe)  # importing Rhipe library

rhinit(TRUE, TRUE) # the TRUEs are optional, use them for debugging

# rhput("/mnt/aidenhong/big_r/example/server_status.csv", "/aidenhong/in")  # upload file to HDFS
# rhls("/aidenhong/in") 
# data <- rhread("/tmp/server_status.csv", type="text", max=-1, mc=FALSE, buffsize=2*1024*1024)  # 에러가 발생함

map_task <- expression({
    map_sum <- 0
    map_count <-0 
    for(raw_line in map.values) {
        fields <- strsplit(raw_line, ",")
        map_sum <- map_sum + as.numeric(fields[[1]][4])  # fields[[1]][4] == processes_proc 
        map_count <- map_count + 1
    }
    rhcollect("result", c(map_sum, map_count))
})

reduce_task <- expression(
    pre={
        total_sum <- 0
        total_count <- 0
    },
    reduce={
        values = unlist(reduce.values)
        total_sum <- total_sum + values[1]
        total_count <- total_count + values[2]
    },
    post={
        rhcollect(reduce.key, c(total_sum, total_count, total_sum / total_count))
    }
)

mr_job <- rhmr(map=map_task, reduce=reduce_task,
    ifolder="/aidenhong/in/server_status.csv",
    #ifolder="/rhipe/airline/in/hl_airline.csv",
    ofolder="/aidenhong/out",
    inout = c("text", "sequence")
)

mr_job_id <- rhex(mr_job, async=FALSE)

result <- rhread("/aidenhong/out/part-r-00000")
print(result)

# 1st results
# [[1]]
# [[1]][[1]]
# [1] "result"
# 
# [[1]][[2]]
# [1] 19996.900000  2372.000000     8.430396
# 
# 
# 
# real    0m30.541s
# user    0m1.288s
# sys     0m0.096s

# 2nd results
# [[1]]
# [[1]][[1]]
# [1] "result"
# 
# [[1]][[2]]
# [1] 1.369858e+07 2.100000e+04 6.523135e+02
# 
# 
# 
# real    28m8.050s
# user    0m1.188s
# sys     0m0.068s
