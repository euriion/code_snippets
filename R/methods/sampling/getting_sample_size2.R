sampsize <- function(alpha, beta, side, q1, p1, p2){
q2 <- 1-q1
PP <-(q1*p1)
z.beta <- qnorm(1-beta)

if(side=="one-sided") z.alpha <- qnorm (1-alpha)
if(side=="two-sided") z.alpha <- qnorm (1-(alpha/2))
datmat <- matrix(0,length(p2),length(beta))
for(ii in 1:length(beta)){
z.beta <- qnorm(1-beta)

NN <- ((z.alpha*sqrt(PP*(1- PP)*((1/q1)+(1/q2))))+(z.beta[ii]*sqrt((P1*(1-P1)*(1/q1))+(P2*(1-P2)*(1/q2)))))^2/((P1-P2)^2)
pergrp <- round((NN*q1),2)
datmat[,ii] <- pergrp
}

colnames(datmat) <- beta
print(cbind(P1,P2,datmat))
diffP <- P2-P1
matplot(diffP, 
datmat, 
type="1",
lty=1:length(beta),
lwd=3,
col=1:length(beta),
main="Estimated Sample Size per Group \n for Comparing Two Proportions", 
xlab="Difference in Proportions (P2-P1)",ylab"Sample Size per Group"), legend(0.30,1500,
legend=c("Power = (1-beta)",as.character(“beta”)),
lty=0:length(beta),
lwd=3,
col=c(NA,1:length(beta)))
}

Here’s that  N = [ za√P(1-P)(1/q1+1/q2) + za√P1(1-P1(1/q1)+P2(1-P2)(1/q2) ]2
(P1-P2)2
