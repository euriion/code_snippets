# =================================================================
# R tree example original model
# Reference: 
#   http://www.r-bloggers.com/a-brief-tour-of-the-trees-and-forests/
#   http://plantecology.syr.edu/fridley/bio793/cart.html
# =================================================================
library(tree)
# cpus: performance of computer cpus
# head(cpus
# name syct mmin  mmax cach chmin chmax perf estperf
# 1  ADVISOR 32/60  125  256  6000  256    16   128  198     199
# 2  AMDAHL 470V/7   29 8000 32000   32     8    32  269     253
# 3  AMDAHL 470/7A   29 8000 32000   32     8    32  220     253
# 4 AMDAHL 470V/7B   29 8000 32000   32     8    32  172     253
# 5 AMDAHL 470V/7C   29 8000 16000   32     8    16  132     132
# 6  AMDAHL 470V/8   26 8000 32000   64     8    32  318     290
# dim(cpus)
# [1] 209   9

data(cpus, package="MASS")
# log scale
# cpus.ltr <- tree(log10(perf) ~ syct+mmin+mmax+cach+chmin+chmax, cpus)
# raw scale
cpus.ltr <- tree(perf ~ syct+mmin+mmax+cach+chmin+chmax, cpus)
cpus.ltr
?tree
summary(cpus.ltr)
plot(cpus.ltr)
text(cpus.ltr)


ir.tr <- tree(Species ~., iris)
ir.tr
summary(ir.tr)
plot(ir.tr)
text(ir.tr)
ir.tr.cv <- cv.tree(ir.tr,, prune.tree)
for(i in 2:5) ir.tr.cv$dev <- ir.tr.cv$dev + cv.tree(ir.tr,, prune.tree)$dev
ir.tr.cv$dev <- ir.tr.cv$dev/5
plot(ir.tr.cv)


###################
## 2 class example

lvs <- c("normal", "abnormal")
truth <- factor(rep(lvs, times = c(86, 258)),
                levels = rev(lvs))
pred <- factor(
  c(
    rep(lvs, times = c(54, 32)),
    rep(lvs, times = c(27, 231))),               
  levels = rev(lvs))

xtab <- table(pred, truth)

confusionMatrix(xtab)
confusionMatrix(pred, truth)
confusionMatrix(xtab, prevalence = 0.25) 

