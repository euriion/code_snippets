install.packages("SpherWave")
library("SpherWave")
### Temperature data from year 1961 to 1990
### list of year, grid, observation
data("temperature")
dim(temperature)
is(temperature)
attributes(temperature)
head(temperature)
temp67 <- temperature$obs[temperature$year==1967]
latlon <- temperature$latlon[temperature$year==1967, ]
sw.plot(z=temp67, latlon=latlon, type="obs", xlab="", ylab="")


# ==================================================

netlab <- network.design(latlon=latlon, method="ModifyGottlemann", type="regular", x=5)
eta <- eta.comp(netlab)$eta
out.pls <- sbf(obs=temp67, latlon=latlon, netlab=netlab, eta=eta, method="pls", grid.size=c(100, 200), lambda=0.8)
sw.plot(out.pls, type="field", xlab="Longitude", ylab="Latitude")
