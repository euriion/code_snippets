# ====================================================
# Feature Selection Example
# Aiden Seonghak Hong
# ====================================================
# install.packages("caret")
# install.packages("ggplot2")
# install.packages("reshape2")

library(caret)
library(ggplot2)
library(reshape2)

data(tecator)
# ?tecator
dim(endpoints)
head(endpoints, 20)
summary(endpoints)
ggplot(data=melt(as.data.frame(endpoints)), aes(variable, value)) + geom_boxplot()
dev.new()
ggplot(data=melt(as.data.frame(endpoints)), aes(x=value, stat="bin", group=variable)) + geom_histogram() + facet_grid(~variable)
splom(~endpoints)

set.seed(1)
inSubset <- sample(1:dim(endpoints)[1], 10)
absorpSubset <- absorp[inSubset,]
endpointSubset <- endpoints[inSubset, 3]
newOrder <- order(absorpSubset[,1])
absorpSubset <- absorpSubset[newOrder,]
endpointSubset <- endpointSubset[newOrder]
plotColors <- rainbow(10)
plot(absorpSubset[1,], type = "n", ylim = range(absorpSubset), xlim = c(0, 105), xlab = "Wavelength Index", ylab = "Absorption") 
for (i in 1:10) {
  points(absorpSubset[i,], type = "l", col = plotColors[i], lwd = 2)
  text(105, absorpSubset[i,100], endpointSubset[i], col = plotColors[i])
}

title("Predictor Profiles for 10 Random Samples")
