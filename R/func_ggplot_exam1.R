ggplot(data.frame(x=c(0,100)), aes(x)) +
  stat_function(fun=sqrt, geom="line") +
  stat_function(fun=function(x) x, geom="line") +
  stat_function(fun=function(x) 1/x, geom="line") +
  stat_function(fun=function(x) 1/sqrt(x), geom="line")
  