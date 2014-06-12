install.packages("rpart")
install.packages("tree")
install.packages("cvTools")
install.packages("caret")

library(caret)

# -- caret cv
data(iris)
tc <- trainControl("cv",10)
rpart.grid <- expand.grid(.cp=0.2)
(train.rpart <- train(Species ~., data=iris, method="rpart",trControl=tc,tuneGrid=rpart.grid))

# cvtools
library(rpart)
library(cvTools)
data(iris)
cvFit(rpart, formula=Species~., data=iris,
      cost=function(y, yHat) (y != yHat) + 0, predictArgs=c(type='class'))

# tree summary
library(tree)
summary(tree(Kyphosis ~ Age + Number + Start, data=kyphosis))


# rpart prediction
pred = predict(mod, type="class")
table(pred)
