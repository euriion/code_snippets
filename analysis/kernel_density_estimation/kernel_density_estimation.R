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
