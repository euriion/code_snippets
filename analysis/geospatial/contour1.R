
# =============================================================================
if (!require(rgeos)) {
  install.packages("rgeos")
}
require(rgeos)

if (!require(rgdal)) {
  install.packages("rgdal")
}
require(rgdal)

if (!require(sm)) {
  install.packages("sm")
}
require(sm)

if (!require(akima)) {
  install.packages("akima")
}
require(akima)

if (!require(spplot)) {
  install.packages("spplot")
}
require(spplot)

if (!require(raster)) {
  install.packages("raster")
}
require(raster)

if (!require(marelac)) {
  install.packages("marelac")
}
require(marelac)

# =============================================================================

library(maptools) 
library(rgdal) 
library(sp) 
library(sm) 
require(akima)
require(spplot) 
library(raster) 
library(rgeos)
library(maptools) # Contour tools
library(marelac) # bathymetry data
library(raster) # only used for displaying Bathymetry here
library(rgeos) # for intersections

# =============================================================================

