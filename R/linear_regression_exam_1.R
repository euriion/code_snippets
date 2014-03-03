lsm.data <- as.data.frame(rbind(
  c(1, 2.1),
  c(3, 3.7),
  c(2.5, 3.4),
  c(3.9, 3.1)
))
colnames(lsm.data) <- c("xvalues", "yvalues")
m <- lm(yvalues ~ xvalues, data=lsm.data)
m
plot(lsm.data)
abline(m)

