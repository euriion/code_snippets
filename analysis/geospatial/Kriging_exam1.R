install.packages("kriging")
library(kriging)
library(maps)
usa <- map("usa", "main", plot = FALSE)
plot(usa)
p <- list(data.frame(usa$x, usa$y))
# Create some random data
x <- runif(50, min(p[[1]][,1]), max(p[[1]][,1]))
y <- runif(50, min(p[[1]][,2]), max(p[[1]][,2]))
z <- rnorm(50)
# Krige and create the map
kriged <- kriging(x, y, z, polygons=p, pixels=300)
image(kriged, xlim = extendrange(x), ylim = extendrange(y))
