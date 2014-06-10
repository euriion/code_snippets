hall <- read.csv(file="hallhitters2.csv", h=T)
head(hall)

fit.ols <- lm(BBWAA ~ H + HR + RBI + SB + R + BA, data=hall)
summary(fit.ols) 

fit.logit <- glm(BBWAA ~ H + HR + RBI + SB + R + BA, data=hall, family=binomial(link="logit")) 
summary(fit.logit)

# InverseLogit(x) = e^x/(1+e^x)
# Logit(y) = BXi
exp(coef(fit.logit)) 
exp(cbind(coef(fit.logit), confint(fit.logit)))  
# install.packages('epicalc') 
require(epicalc) 
logistic.display(fit.logit) 


