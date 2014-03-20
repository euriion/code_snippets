set.seed(20121108)
x = seq(1, 10, 0.1)
r = function() runif(length(x), -0.05, 0.05)
y1 = sin(x) + r()
y2 = cos(x) + r()
# draw the lines and texts
par(mar = c(2, 0.1, 0.1, 0.1))
plot.new()
plot.window(range(x), c(-1.5, 1))
grid()
matplot(x, cbind(y1, y2, y2), type = "l", lty = 1, col = c("black", 
                                                           "white", "red"), lwd = c(3, 15, 3), add = TRUE)
axis(1, c(2, 5, 6, 9), c("YARD", "STEPS", "DOOR", "INSIDE"), lwd = 0, 
     line = -1)
text(7, -1.25, "A SIN AND COS CURVE", cex = 1.5)
lines(x, -1.5 + runif(length(x), -0.005, 0.005), xpd = NA, lwd = 2)


