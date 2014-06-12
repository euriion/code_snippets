# f(x)=x4−3x3+2 함수의 극값을 미분값인 f'(x)=4x3−9x2
# From calculation, we expect that the local minimum occurs at x=9/4
cat("Expected local minimum: ", 9.0/4.0)

x_old <- 0
x_new <- 6
eps <- 0.01 # step size
precision <- 0.00001

f_origin <- function(x) x^4 - 3*x^3 + 2
#f_prime <- f_origin
#body(f_prime) <- deriv(body(f_origin), "x")
f_prime2 <- function(x) {
  return (4 * x^3 - 9 * x^2)
}

plot(f_origin, 0, 5)
plot(f_prime2, 0, 5)

step = 1
repeat {
  if (!(abs(x_new - x_old) > precision)) {
    break
  }
  # 차가 precision 만큼이 될 때까지 피팅
  #cat("step[%s] x_new = %s , x_old = %s, eps = %s" % (step, x_new, x_old, eps))
  x_old <- x_new
  x_new <- x_old - eps * f_prime2(x_old)
  #print "f_prime: %s" % f_prime(x_old), "eps * f_prime: %s" % (eps * f_prime(x_old)), " = new x: %s" % x_new
  step <- step + 1 
}


cat("Local minimum occurs at ", x_new)
