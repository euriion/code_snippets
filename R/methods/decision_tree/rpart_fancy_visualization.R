# =========================================================
# http://www.r-bloggers.com/draw-nicer-classification-and-regression-trees-with-the-rpart-plot-package/
# =========================================================

library(rpart)          # Popular decision tree algorithm
library(rattle)         # Fancy tree plot
library(rpart.plot)     # Enhanced tree plotsinstall.packages("caret")
library(RColorBrewer)   # Color selection for fancy tree plot
library(party)          # Alternative decision tree algorithm
library(partykit)       # Convert rpart object to BinaryTree
library(caret)          # Just a data source for this script
                        # but probably one of the best R packages ever. 

data(segmentationData)  # Get some data. data from caret
dim(segmentationData)
# should be [1] 2019   61
head(segmentationData)
table(segmentationData$Class)
# PS   WS 
# 1300  719 
table(segmentationData$Case)
# Test Train 
# 1010  1009 
data <- segmentationData[,-c(1,2)]  # remove not necessary columns for making model
data.train <- segmentationData[segmentationData$Case=='Train',][, -c(1,2)]
dim(data.train)
data.test <- segmentationData[segmentationData$Case=='Test',][, -c(1,2)]
dim(data.test)

# Make big tree
form <- as.formula(Class ~ .)
tree.1 <- rpart(form, data=data.train, control=rpart.control(minsplit=20, cp=0))
tree.1$variable.importance
printcp(tree.1) # 
plotcp(tree.1)  # plotting cross-validation
prp(tree.1)
tree.1.cv <- xpred.rpart(tree.1, xval = 10)
# tree.1.cv.xerr <- (tree.1.cv - data.train$Class)^2
# apply(xerr, 2, sum)   # cross-validated error estimate
printcp(tree.1)

pfit <- prune(tree.1, cp=0.10) # from cptable
pfit <- prune(tree.1, cp=fit$cptable[which.min(tree.1$cptable[,"xerror"]),"CP"])
pred1 <- predict(fit, test.data, type="class")
# 
plot(tree.1)          # Will make a mess of the plot
text(tree.1)
fancyRpartPlot(tree.1)
# 
prp(tree.1)           # Will plot the tree
prp(tree.1,varlen=3)  # Shorten variable names

# Interatively prune the tree
new.tree.1 <- prp(tree.1,snip=TRUE)$obj # interactively trim the tree
prp(new.tree.1) # display the new tree
?prp
#
#-------------------------------------------------------------------
tree.2 <- rpart(form, data)			# A more reasonable tree
prp(tree.2)                                     # A fast plot													
fancyRpartPlot(tree.2)				# A fancy plot from rattle

#
#-------------------------------------------------------------------

