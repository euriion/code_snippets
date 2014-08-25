#function to extract coordinates from shapefile (by Paul Hiemstra)
allcoordinates_lapply = function(x) { 
  polys = x@polygons 
  return(do.call("rbind", lapply(polys, function(pp) { 
    do.call("rbind", lapply(pp@Polygons, coordinates)) 
  }))) 
} 
q = allcoordinates_lapply(shapefile)

#extract subset of coordinates, otherwise strange line connections occur...
lat = q[110:600,1]
long = q[110:600,2]

#define ranges for polypath
xrange <- range(lat, na.rm=TRUE)
yrange <- range(long, na.rm=TRUE)
xbox <- xrange + c(-20000, 20000)
ybox <- yrange + c(-20000, 20000)

#plot your stuff
plot(shapefile, lwd=2)
image(fld, axes=F, add=T)
contour(fld, add=T)
#and here is the magic 
polypath(c(lat, NA, c(xbox, rev(xbox))),
         c(long, NA, rep(ybox, each=2)),
         col="white", rule="evenodd")