sample.size.table = function(c.lev, margin=.5,
                             c.interval=.05, population) {
  z.val = qnorm(.5+c.lev/200)
  ss = (z.val^2 * margin * (1-margin))/(c.interval^2)
  p.ss = ss/(1 + ((ss-1)/population))
  c.level = c(paste(c.lev, "%", sep = ""))
  results = data.frame(c.level, round(p.ss, digits = 0))
  names(results) = c("Confidence Level", "Sample Size")
  METHOD = c("Suggested sample sizes at different confidence levels")
  moe = paste((c.interval*100), "%", sep="")
  resp.dist = paste((margin*100),"%", sep="")
  pre = structure(list(Population=population,
                       "Margin of error" = moe,
                       "Response distribution" = resp.dist,
                       method = METHOD),
                  class = "power.htest")
  print(pre)
  print(results)
}

sample.size = function(c.lev, margin=.5,
                       c.interval=.05, population) {
  z.val = qnorm(.5+c.lev/200)
  ss = (z.val^2 * margin * (1-margin))/c.interval^2
  p.ss = round((ss/(1 + ((ss-1)/population))), digits=0)
  METHOD = paste("Recommended sample size for a population of ",
                 population, " at a ", c.lev,
                 "% confidence level", sep = "")
  structure(list(Population = population,
                 "Confidence level" = c.lev,
                 "Margin of error" = c.interval,
                 "Response distribution" = margin,
                 "Recommended sample size" = p.ss,
                 method = METHOD),
            class = "power.htest")
}

sample.size(c.lev = 95, population = 50000000*0.4)
sample.size.table(c.lev = 99.9, population = 50000000*0.4)
# ----- # -----
sample.size(c.lev = 95, population = c(100000,2000000,3000000))


