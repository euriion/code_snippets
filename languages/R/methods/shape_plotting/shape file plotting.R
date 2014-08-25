#==================================================================================================#
#									Discription: shape file plotting 		                       #
#									Namde: andrew           	                                   #
#									Date: 2013.06.16    	                                       #
#									Packages: rgdal    	                    	                   #
#==================================================================================================#



# package setting
install.packages(rgdal)
library(rgdal)

# diretory setting
setwd("C:/Users/Andrew/Desktop/read-write-shapefiles")
getwd()

# read shape file
# data_name <- readOGR("directory_name", "shape_file_name")
counties.rg  <- readOGR(".", "nw-counties")
centroids.rg <- readOGR(".", "nw-centroids")
rivers.rg    <- readOGR(".", "nw-rivers")

# show shape file
head(counties.rg)
head(centroids.rg)
head(rivers.rg)

# shape file plotting
plot(counties.rg, axes = TRUE, border = "black", col = heat.colors(208)) # file type: SpatialPolygonsDataFrame
points(centroids.rg, pch = 20, col = "darkgreen", cex = 0.7, add = T) # file type: SpatialPointsDataFrame
lines(rivers.rg, col = "blue", lwd = 2.0, add = T) # file type: SpatialLinesDataFrame

# print shape file information
# ogriInfo("directory_name", "shape_file_name")
ogrInfo(".", "nw-counties")
ogrInfo(".", "nw-centroids")
ogrInfo(".", "nw-rivers")

# shape file class
class(counties.rg) # SpatialDataFrame
class(centroids.rg) # SpatialPointsDataFrame
class(rivers.rg) # SpatialLinesDataFrame