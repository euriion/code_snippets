# reference: http://www.teamquest.com/pdfs/whitepaper/ldavg1.pdf
# load average: n e(-5/60) + load(t-1) (1 - e-5/60) 
# 이전까지 값은 exp(-1/n) 새 관측값은 (1 - exp(-1/window))
# exp(-1/n) < 0 :: decay
# value: initial value?
# growth: y = a(1 + r)^x
# decay: y = a(1 - r)^x
# a: initial amount before measuring decay
# r: growth/decay (often percent)
# x: number of time intervals that have passed
# a = initial amount before measuring growth/decay
# r = growth/decay rate (often a percent)
# x = number of time intervals that have passed
# http://math.usask.ca/emr/examples/expdeceg.html


expdecay <- function(stored_value, new_value, window) {
	new_value * exp(-1/window) + stored_value * (1 - exp(-1/window))
}
samples <- sample(9999)
window <- 50
curr <- 0;
for (nv in samples) { 
	curr <- expdecay(curr, nv, window); 
	print(paste(nv, curr))
}
mean(tail(samples, window))
ma <- function(x, n=5){
	filter(x, rep(1/n, n), sides=2)
}