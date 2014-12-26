
if (!require(ggplot2)) install.packages("ggplot2")

p <- ggplot(data=iris, aes(x=Sepal.Length, fill=..count..))
p <- p + geom_histogram(binwidth=0.1)
p <- p + scale_x_continuous(breaks=seq(0.1, 10, by=0.1))
p

