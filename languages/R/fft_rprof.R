foo <- function(){	for(k in 1:10)		fft(rnorm(1e5))}

Rprof() # start recording a log for profilingfoo() # an exampleRprof(NULL) # stop recording

## exercise
var1 <- function(x) {
  s <- 0
	for (i in seq_along(x)) {
  	s <- s + (x[i] - mean(x))^2
  }
  s/(length(x) - 1)
}


Rprof()
var1(1:100000)
Rprof(NULL)
summaryRprof()

var2 <- function(x) {
  s <- 0
  m <- mean(x)
	for (i in seq_along(x)) {
  	s <- s + (x[i] - m)^2
  }
  s/(length(x) - 1)
}

Rprof()
var2(1:100000)
Rprof(NULL)
summaryRprof()

var3 <- function(x) {
  sum((x-mean(x))^2/(length(x)-1))
}

Rprof()
var3(1:100000)
Rprof(NULL)
summaryRprof()

------------------
# compile
library(compiler)
compile(var)
-------------------

sapply(1:100, function(k) {
	k <- 50
	mean(replicate(1000, any(duplicated(sample(1:365, k, replace=TRUE)))))}
)
# ----

var100 <- function() {
	var(1:100000)
}

system.time(var100())

> var(1:100000)
[1] 833341667
> system.time(var(1:100000))
   user  system elapsed 
  0.001   0.000   0.001 
> Rprof()
> system.time(var(1:100000))
   user  system elapsed 
  0.001   0.000   0.001 
> Rprof()
> Rprof()
> system.time(var(1:100000))
   user  system elapsed 
  0.001   0.000   0.001 
> Rprof(NULL)
> summaryRprof()
$by.self
     self.time self.pct total.time total.pct
"gc"      0.02      100       0.02       100

$by.total
              total.time total.pct self.time self.pct
"gc"                0.02       100      0.02      100
"system.time"       0.02       100      0.00        0

$sample.interval
[1] 0.02

Rprof()
system.time(var100())
Rprof(NULL)
summaryRprof()
$sampling.time
[1] 0.02

> 