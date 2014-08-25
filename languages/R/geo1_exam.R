install.packages("gstat")

library(gstat)
data(meuse)
coordinates(meuse) <- c("x", "y")
data(meuse.grid)
coordinates(meuse.grid) <- c("x", "y")
gridded(meuse.grid) <- TRUE
idw.out <- idw(zinc ~ 1, meuse, meuse.grid, idp = 2.0)