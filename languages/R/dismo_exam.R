# dismo를 통한 googlemap
library(dismo)
 
# x <- geocode("Bozner Platz, Innsbruck, Tirol, Austria")
x <- geocode("Bangbae, Seocho, Seoul, South Korea")
x <- geocode("대구시")
x <- geocode("서울특별시 서초구 서초동 1321-6")
e <- extent(unlist(x[4:7]))
#g <- gmap(e, type = "terrain", exp=0.1)
g <- gmap(e, style = "all", exp=0.1)
?gmap
plot(g)

?gmap

# ----- color map
# install.packages("PBSmapping")
data(NYleukemia)
population <- NYleukemia$data$population
cases <- NYleukemia$data$cases
mapNY <- GetMap(center=c(lat=42.67456, lon=-76.00365), destfile = "NYstate.png", maptype = "mobile", zoom=9)
ColorMap(100*cases/population, mapNY, NYleukemia$spatial.polygon, add = FALSE,alpha = 0.35, log = TRUE, location = "topleft")

#----
lat = c(40.702147,40.718217,40.711614);
lon = c(-74.012318,-74.015794,-73.998284);
center = c(lat=mean(lat), lon=mean(lon));
zoom <- min(MaxZoom(range(lat), range(lon)));
#this overhead is taken care of implicitly by GetMap.bbox();              
MyMap <- GetMap(center=center, zoom=zoom,markers = "&markers=color:blue|label:S|40.702147,-74.015794&markers=color:green|label:G|40.711614,-74.012318&markers=color:red|color:red|label:C|40.718217,-73.998284", destfile = "MyTile1.png");
#Note that in the presence of markers one often needs to add some extra padding to the latitude range to accomodate the extent of the top most marker

#add a path, i.e. polyline:
 MyMap <- GetMap(path = "&path=color:0x0000ff|weight:5|40.737102,-73.990318|40.749825,-73.987963|40.752946,-73.987384|40.755823,-73.986397", destfile = "MyTile3.png");
 
 #The example below defines a polygonal area within Manhattan, passed a series of intersections as locations:
  #MyMap <- GetMap(path = "&path=color:0x00000000|weight:5|fillcolor:0xFFFF0033|8th+Avenue+%26+34th+St,New+York,NY|8th+Avenue+%26+42nd+St,New+York,NY|Park+Ave+%26+42nd+St,New+York,NY,NY|Park+Ave+%26+34th+St,New+York,NY,NY", destfile = "MyTile3a.png");

#note that since the path string is just appended to the URL you can "abuse" the path argument to pass anything to the query, e.g. the style parameter:
#The following example displays a map of Brooklyn where local roads have been changed to bright green and the residential areas have been changed to black:
# MyMap <- GetMap(center="Brooklyn", zoom=12, maptype = "roadmap", path = "&style=feature:road.local|element:geometry|hue:0x00ff00|saturation:100&style=feature:landscape|element:geometry|lightness:-100", sensor='false', destfile = "MyTile4.png",  RETURNIMAGE = FALSE);
 
 #In the last example we set RETURNIMAGE to FALSE which is a useful feature in general if png is not installed. In that cases, the images can still be fetched and saved but not read into R.

#In the following example we let the Static Maps API determine the correct center and zoom level implicitly, based on evaluation of the position of the markers. However, to be of use within R we do need to know the values for zoom and center explicitly, so it is better practice to compute them ourselves and pass them as arguments, in which case meta information on the map tile can be saved as well.

#MyMap <- GetMap(markers = "&markers=color:blue|label:S|40.702147,-74.015794&markers=color:green|label:G|40.711614,-74.012318&markers=color:red|color:red|label:C|40.718217,-73.998284", destfile = "MyTile1.png",  RETURNIMAGE = FALSE);
 	
