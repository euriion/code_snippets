
# --------------------------------------------------
# Derivative
# 미분
# --------------------------------------------------

f <- function(x) x ^ 2 + 1
Df <- f
body(Df) <- deriv(body(f), "x")
Df
Df(2)
f(2)

# --------------------------------------------------
# Integral
# 적분
# --------------------------------------------------
f <- function(x) x
sum(f(1:3))
sum(1:10)
integrate(f, 1, 4, stop.on.error = FALSE)
integrate(Df,1,10)
sum(Df(1:10))

plot(f,from=1,to=10)
10 * 10 / 2
integrate(f,1,10)
?integrate

sum(1:3)
