library(Amelia)
library(ggplot2)
library(MASS)
library(randomForest)
library(ROCR)
library(party)
library(mboost)

#########################################################
# data loading
#########################################################
load(url('http://biostat.mc.vanderbilt.edu/wiki/pub/Main/DataSets/titanic3.sav')) 

#########################################################
# data preparation
#########################################################
vars <- c("survived", "age", "sibsp", "parch", "fare", "pclass", "sex", "embarked")
titanic <- titanic3[, vars]
titanic <- subset(titanic, !is.na(fare) & !is.na(embarked))

a.out <- amelia(titanic[, !names(titanic) %in% c("pclass", "sex", "embarked")])
summary(a.out)
plot(a.out)

titanic$age[is.na(titanic$age)] <- 0
titanic$age <- a.out$imputations[[3]]$age

#########################################################
# split of train & test 
#########################################################
idx <- sample(2, size=NROW(titanic), replace=TRUE, prob=c(0.7, 0.3))
titanic.train <- titanic[idx==1, ]
titanic.test <- titanic[idx==2, ]

#########################################################
# logistic regrssion
#########################################################
titanic.train.glm <- glm(survived ~ pclass + sex + pclass:sex + age + sibsp, 
                              family = binomial(logit), data = titanic.train)

titanic.train.glm <- glm(survived ~ . + pclass:sex, 
                         family = binomial(logit), data = titanic.train)

summary(titanic.train.glm)

predicted <- predict(titanic.train.glm, titanic.train, type="response")
actually <- factor(titanic.train$survived)

predicted <- predict(titanic.train.glm, titanic.test, type="response")
actually <- factor(titanic.test$survived)

dframe <- data.frame(actually, predicted)
ggplot(dframe, aes(x=predicted, colour=actually)) + geom_density()

confusion.matrix <- ftable(actually, predicted=predicted > 0.5)
confusion.matrix <- ftable(actually, predicted=predicted > 0.445)
confusion.matrix <- ftable(actually, predicted=predicted > 0.375)
confusion.matrix

accurancy <- sum(diag(confusion.matrix)) / sum(confusion.matrix) * 100
accurancy

# dframe <- data.frame(actually, predicted=round(predicted))
# ftable(dframe)

titanic.train.glm <- stepAIC(titanic.train.glm, direction="backward")
titanic.train.glm <- stepAIC(titanic.train.glm, direction="both")
titanic.train.glm <- stepAIC(titanic.train.glm, direction="forward")

#########################################################
# random forest
#########################################################
titanic.train.rf <- randomForest(as.factor(survived) ~ pclass + sex + age + sibsp, 
                                 data=titanic.train, ntree=5000, importance=TRUE)

titanic.train.rf <- randomForest(as.factor(survived) ~ ., 
                                 data=titanic.train, ntree=5000, importance=TRUE)
titanic.train.rf
round(importance(titanic.train.rf), 2)
plot(titanic.train.rf)

predicted <- predict(titanic.train.rf, titanic.test)
actually <- factor(titanic.test$survived)

confusion.matrix <- ftable(actually, predicted)
confusion.matrix

accurancy <- sum(diag(confusion.matrix)) / sum(confusion.matrix) * 100
accurancy

#########################################################
# ctree
#########################################################
titanic.train.ctree <- ctree(as.factor(survived) ~ pclass + sex + age + sibsp, 
                             data=titanic.train)

titanic.train.ctree <- ctree(as.factor(survived) ~ ., 
                             data=titanic.train)

titanic.train.ctree
plot(titanic.train.ctree)

predicted <- predict(titanic.train.ctree, titanic.test)
actually <- factor(titanic.test$survived)

confusion.matrix <- ftable(actually, predicted)
confusion.matrix

accurancy <- sum(diag(confusion.matrix)) / sum(confusion.matrix) * 100
accurancy


#########################################################
# Generalized Linear Models Fitted via Gradient Boosting
#########################################################
ctrl <- boost_control(mstop = 500)
titanic_glm <- glmboost(factor(survived) ~ ., data = titanic.train, family = Binomial(),
                        center = TRUE, control = ctrl)
predicted <- predict(titanic_glm, titanic.test, type="response")
actually <- factor(titanic.test$survived)


#########################################################
# prepare model for ROC Curve
#########################################################
test.logit <- predict(titanic.train.glm, titanic.test, type="response")
test.logit <- cbind(1-test.logit, test.logit)
logit.pred <- prediction(test.logit[,2], titanic.test$survived)
logit.perf <- performance(logit.pred, "tpr", "fpr")

test.ct <- predict(titanic.train.ctree, type = "prob", newdata = titanic.test)
test.ct <- t(sapply(test.ct, "rbind"))
ct.pred <- prediction(test.ct[,2], titanic.test$survived)
ct.perf <- performance(ct.pred, "tpr", "fpr")

test.forest <- predict(titanic.train.rf, type = "prob", newdata = titanic.test)
forest.pred <- prediction(test.forest[,2], titanic.test$survived)
forest.perf <- performance(forest.pred, "tpr", "fpr")

plot(ct.perf, main="ROC")
plot(logit.perf, col=2, add=TRUE)
plot(ct.perf, col=1, add=TRUE)
plot(forest.perf, col=3, add=TRUE)
abline(a=0, b=1)
legend("topleft", c('ctree', 'logist', 'rforest'), fill=1:3)
