library(CausalImpact)
?CausalImpact


set.seed(1)
x1 <- 100 + arima.sim(model = list(ar = 0.999), n = 100)
y <- 1.2 * x1 + rnorm(100)
y[71:100] <- y[71:100] + 10
data <- cbind(y, x1)
pre.period <- c(1, 70)
post.period <- c(71, 100)
impact <- CausalImpact(data, pre.period, post.period)

# Print and plot results
summary(impact)
summary(impact, "report")
plot(impact)
plot(impact, "original")
plot(impact$model$bsts.model, "coefficients")

# For further output, type:
names(impact)


# Example 2
#
# For full flexibility, specify a custom model and pass the
# fitted model to CausalImpact(). To run this example, run
# the code for Example 1 first.

post.period.response <- y[post.period[1] : post.period[2]]
y[post.period[1] : post.period[2]] <- NA
ss <- AddLocalLevel(list(), y)
bsts.model <- bsts(y ~ x1, ss, niter = 1000)
impact <- CausalImpact(bsts.model = bsts.model, post.period.response = post.period.response)
plot(impact)


CausalImpact
CausalImpact:::RunWithBstsModel
CausalImpact:::CompilePosteriorInferences
CausalImpact:::ComputeResponseTrajectories
CausalImpact:::GetPosteriorStateSamples
CausalImpact:::SuggestBurn
bsts