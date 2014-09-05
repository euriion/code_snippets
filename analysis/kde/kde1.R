
seq(5,15,length=1000)


x   <- seq(5,15,length=1000)
y   <- dnorm(x,mean=10, sd=3)
plot(x,y, type="l", lwd=1)
abline(v=10, lty=1)


x<-rnorm(100000,mean=10, sd=2)
hist(x,breaks=150,xlim=c(0,20),freq=FALSE)
abline(v=10, lwd=5)
abline(v=c(4,6,8,12,14,16), lwd=3,lty=3)


sinf <- function(x) sin(2*pi*x)
plot(sinf)

gaussian_noise <- rnorm(9, mean=0, sd=0.1)
dput(gaussian_noise)

gaussian_noise 
  <- c(0.196760532524989, 0.0805741682327561, 0.0124379363747232, 
           0.0373675258483264, 0.0964953650799077, 0.219646689325869, 0.0993671240315916, 
           -0.217419806061148, -0.0964444809249427)
xvalues <- seq(0, 1, length=9)
origin <- sinf(seq(0, 1, length=9))
observation <- origin + gaussian_noise
plot(observation)
plot(origin)

plot(sinf)
points(x=xvalues, y=observation, pch=19)

sum((origin[1:9] - observation[1:9]) ^ 2) / 2 
