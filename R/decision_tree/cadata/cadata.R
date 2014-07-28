# http://www.stat.cmu.edu/~cshalizi/350/lectures/22/lecture-22.pdf
# http://gosset.wharton.upenn.edu/~foster/teaching/471/
calif <- read.table("./cadata.dat",header=TRUE)
plot(calif)

require(tree)
treefit = tree(log(MedianHouseValue) ~ Longitude+Latitude,data=calif)
plot(treefit)
text(treefit,cex=0.75)
price.deciles = quantile(calif$MedianHouseValue,0:10/10)
cut.prices = cut(calif$MedianHouseValue,price.deciles,include.lowest=TRUE)
plot(calif$Longitude,
     calif$Latitude,
     col=grey(10:2/11)[cut.prices],
     pch=20, 
     xlab="Longitude", 
     ylab="Latitude")
partition.tree(treefit,ordvars=c("Longitude","Latitude"),add=TRUE)
summary(treefit)
dim(calif)

# Here “deviance” is just mean squared error
# this gives us an RMS error of 0.41

treefit3 <- tree(log(MedianHouseValue) ~., data=calif)
plot(calif$Longitude,
     calif$Latitude,
     col=grey(10:2/11)[cut.prices],
     pch=20,
     xlab="Longitude",
     ylab="Latitude")
partition.tree(treefit2,ordvars=c("Longitude","Latitude"),add=TRUE,cex=0.3)
plot(treefit3)
text(treefit3,cex=0.5,digits=3)

cut.predictions = cut(predict(treefit3),log(price.deciles),include.lowest=TRUE)
plot(calif$Longitude,calif$Latitude,col=grey(10:2/11)[cut.predictions],pch=20,
     xlab="Longitude",ylab="Latitude")

my.tree = tree(y ~ x1 + x2, data=my.data) # Fits tree
prune.tree(my.tree,best=5) # Returns best pruned tree with 5 leaves, evaluating
# error on training data
prune.tree(my.tree,best=5,newdata=test.set) # Ditto, but evaluates on test.set
my.tree.seq = prune.tree(my.tree) # Sequence of pruned tree sizes/errors
plot(my.tree.seq) # Plots size vs. error
my.tree.seq$dev # Vector of error rates for prunings, in order
opt.trees = which(my.tree.seq$dev == min(my.tree.seq$dev)) # Positions of
# optimal (with respect to error) trees
min(my.tree.seq$size[opt.trees]) # Size of smallest optimal tree
my.tree.cv = cv.tree(my.tree)


treefit2.cv <- cv.tree(treefit)
plot(treefit2.cv)
