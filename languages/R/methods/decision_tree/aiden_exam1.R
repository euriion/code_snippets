# http://stats.stackexchange.com/questions/49416/decision-tree-model-evaluation-for-training-set-vs-testing-set-in-r
library(rpart)
library(party)
library(partykit)
library(cvTools)
# model build
train.data <- kyphosis[1:71,]
test.data <- kyphosis[72:81,]
model_ctree <- ctree(Kyphosis ~ . , data = train.data) 

# class predicions
pred <- predict(model_ctree, newdata=test.data)

# Confusion matrix
library(caret)
confusionMatrix(pred, test.data$Kyphosis)

# class probabilities
probs <- treeresponse(model_ctree, newdata=test.data)
pred <- do.call(rbind, probs)
summary(pred)

# ROC
library(ROCR)
roc_pred <- prediction(pred[,1], test.data$Kyphosis)
plot(performance(roc_pred, measure="tpr", x.measure="fpr"), colorize=TRUE)

# lift curve
plot(performance(roc_pred, measure="lift", x.measure="rpp"), colorize=TRUE)

# Sensitivity/specificity curve and precision/recall curve

plot(performance(roc_pred, measure="sens", x.measure="spec"), colorize=TRUE)
plot(performance(roc_pred, measure="prec", x.measure="rec"), colorize=TRUE)


??ctree
