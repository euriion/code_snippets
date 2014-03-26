# exponent function plotting
# 
library(ggplot2)
df1 <- function(x) {exp(x)}
df2 <- function(x) {exp(1/x)}
df3 <- function(x) {exp(-x)}
df4 <- function(x) {exp(-1/x)}
df5 <- function(x) {1-exp(-1/x)}

# http://kohske.wordpress.com/2010/12/25/draw-function-without-data-in-ggplot2/
# qplot(c(0, 2), stat="function", fun=exp, geom="line")
ggplot(data.frame(x=c(0, 2)), aes(x)) + stat_function(fun=ed1)
ggplot(data.frame(x=c(0, 2)), aes(x)) + stat_function(aes(x), fun=c(ed1))  + stat_function(aes(x), fun=c(ed2))

ggplot(data.frame(x=c(0, 1000)), aes(x)) +
#  stat_function(fun=df1, geom="line", aes(colour="df1")) +
#  stat_function(fun=df2, geom="line", aes(colour="df2")) +
#  stat_function(fun=df3, geom="line", aes(colour="df3")) +
  stat_function(fun=df4, geom="line", aes(colour="df4")) +
  scale_colour_manual("Function", values=c("blue","red","green","purple"), breaks=c("df1","df2","df3","df4"))

numbers <- c(0, 50)
ggplot(data.frame(x=numbers), aes(x)) +
  stat_function(fun=df4, geom="line", aes(colour="Exp decay")) +
  scale_colour_manual("Function", values=c("blue")) +
  ylab("Damping factor")
