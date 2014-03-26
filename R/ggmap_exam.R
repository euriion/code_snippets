# ----- GGmap display
library(ggmap)
# maptype = c("terrain", "satellite", "roadmap", "hybrid", "toner", "watercolor"),
# source = c("google", "osm", "stamen", "cloudmade"),

# base.address <- "서울특별시 서초구 서초동 1321-6 동아타워"
base.address <- "서울특별시 서초구 방배동 463-10"
base.location <- geocode(base.address)
base.map <- get_map(location=base.address, zoom=12, maptype="terrain", source="google")

# test용 주소
addresses <- c(
"서울특별시 서초구 서초동 1321-6", 
"대한민국 서울특별시 서초구 서초2동 1332-3",
"대한민국 서울특별시 서초구 서초2동 1378",
"대한민국 서울특별시 서초구 서초2동 1376-14",
"서울특별시 서초구 양재동 산27-2",
"대한민국 서울특별시 서초구 양재1동 20-1",
"대한민국 서울특별시 서초구 양재2동 237-2",
"대한민국 서울특별시 서초구 양재2동 230-4",
"서울특별시 서초구 양재동 231"
)

#     lon    lat
# 1 127.03 37.496
# 2 127.03 37.492
# 3 127.03 37.488
# 4 127.03 37.484
# 5 127.03 37.485
# 6 127.04 37.480
# 7 127.04 37.470
# 8 127.04 37.464
# 9 127.04 37.464

addresses.point <- geocode(addresses)
print(addresses.point)


apply(addresses.point, 1, function(x) {paste(x[1], x[2], sep=",")})

http://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034
127.03 37.496

#"대한민국 서울특별시 서초구 서초2동 1332-3", 37.491996,127.026553

# unit: meter
distances <- c(
0,
3000,
6000
)

total_moving <- sum(distances)

# unit: minutes
timetaken <- c(
0,
23,
42
)

total_timetake <- sum(timetaken)

base.map <- get_map(location=addresses[1], zoom=12, maptype="terrain", source="google", language="ko-KR")


checkpoints <- cbind(geocode(addresses), class=c(10,21,31,31))
checkpoints <- geocode(addresses)

png("./map1.png",width=1000, height=1000)
ggmap(base.map, extent = 'device') +
  geom_point(aes(x = lon, y = lat), data = checkpoints, alpha = 1, colour = "#180cdc") +
  geom_path(aes(x=lon, y=lat), data=checkpoints, colour="#0c70dc")
dev.off()
  

  geom_smooth(aes(x = x, y = y), fill = I('gray60'), data = checkpoints,
colour = I('green'), size = I(1)) +
  

  
?geom_line

ggmap(base.map, extent='device')

chkpts <- data.frame(chkpts)
names(chkpts) <- c('lon', 'lat','class')
chkpts$class <- factor(chkpts$class)
# qplot(lon, lat, data = chkpts, colour = class)


# ---------------------------------------------------------------
# loading default map
hdf <- get_map()
ggmap(hdf, extent = 'normal')
ggmap(hdf) # extent = 'panel', note qmap defaults to extent = 'device'
ggmap(hdf, extent = 'device')

require(MASS)
mu <- c(-95.3632715, 29.7632836)
nDataSets <- sample(4:10,1)
chkpts <- NULL
for (k in 1:nDataSets) {
  a <- rnorm(2) 
  b <- rnorm(2)
  si <- 1/3000 * (outer(a,a) + outer(b,b))
  chkpts <- rbind(chkpts, cbind(mvrnorm(rpois(1,50), jitter(mu, .01), si), k))
}

chkpts <- data.frame(chkpts)
names(chkpts) <- c('lon', 'lat','class')
chkpts$class <- factor(chkpts$class)
qplot(lon, lat, data = chkpts, colour = class)

ggmap(hdf, extent = 'normal') + 
	geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)

ggmap(hdf) +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)

ggmap(hdf, extent = 'device') +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)

theme_set(theme_bw())
ggmap(hdf, extent = 'device') +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)

ggmap(hdf, extent = 'device', legend = 'topleft') +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)


## maprange
##################################################

hdf <- get_map()
mu <- c(-95.3632715, 29.7632836)
points <- data.frame(mvrnorm(1000, mu = mu, diag(c(.1, .1))))
names(points) <- c('lon', 'lat')
points$class <- sample(c('a','b'), 1000, replace = TRUE)

ggmap(hdf) + geom_point(data = points) # maprange built into extent = panel, device
ggmap(hdf) + geom_point(aes(colour = class), data = points)

ggmap(hdf, extent = 'normal') + geom_point(data = points)
# note that the following is not the same as extent = panel
ggmap(hdf, extent = 'normal', maprange = TRUE) + geom_point(data = points)

# and if you need your data to run off on a extent = device (legend included)
ggmap(hdf, extent = 'normal', maprange = TRUE) +
  geom_point(aes(colour = class), data = points) +
  theme_nothing() + theme(legend.position = 'right')




## cool examples
##################################################

# contour overlay
ggmap(get_map(maptype = 'satellite'), extent = 'device') +
  stat_density2d(aes(x = lon, y = lat, colour = class), data = chkpts, bins = 5)


# adding additional content
library(grid)
baylor <- get_map('baylor university', zoom = 15, maptype = 'satellite')
ggmap(baylor)

# use gglocator to find lon/lat's of interest
(clicks <- clicks <- gglocator(2) )
expand.grid(lon = clicks$lon, lat = clicks$lat)

ggmap(baylor) + theme_bw() +
  annotate('rect', xmin=-97.11920, ymin=31.5439, xmax=-97.101, ymax=31.5452,
    fill = I('black'), alpha = I(3/4)) +
  annotate('segment', x=-97.110, xend=-97.11920, y=31.5450, yend=31.5482,
    colour=I('red'), arrow = arrow(length=unit(0.3,"cm")), size = 1.5) +
  annotate('text', x=-97.110, y=31.5445, label = 'Department of Statistical Science',
    colour = I('red'), size = 6) +
  labs(x = 'Longitude', y = 'Latitude') + ggtitle('Baylor University')



baylor <- get_map('baylor university', zoom = 16, maptype = 'satellite')

ggmap(baylor, extent = 'device') +
  annotate('rect', xmin=-97.1164, ymin=31.5441, xmax=-97.1087, ymax=31.5449,
    fill = I('black'), alpha = I(3/4)) +
  annotate('segment', x=-97.1125, xend=-97.11920, y=31.5449, yend=31.5482,
    colour=I('red'), arrow = arrow(length=unit(0.4,"cm")), size = 1.5) +
  annotate('text', x=-97.1125, y=31.5445, label = 'Department of Statistical Science',
    colour = I('red'), size = 6)



# a shapefile like layer
data(zips)
ggmap(get_map(maptype = 'satellite', zoom = 8), extent = 'device') +
  geom_polygon(aes(x = lon, y = lat, group = plotOrder),
    data = zips, colour = NA, fill = 'red', alpha = .2) +
  geom_path(aes(x = lon, y = lat, group = plotOrder),
    data = zips, colour = 'white', alpha = .4, size = .4)

library(plyr)
zipsLabels <- ddply(zips, .(zip), function(df){
  df[1,c("area", "perimeter", "zip", "lonCent", "latCent")]
})
ggmap(get_map(maptype = 'satellite', zoom = 9),
    extent = 'device', legend = 'none', darken = .5) +
  geom_text(aes(x = lonCent, y = latCent, label = zip, size = area),
    data = zipsLabels, colour = I('red')) +
  scale_size(range = c(1.5,6))




## crime data example
##################################################

# only violent crimes
violent_crimes <- subset(crime,
  offense != 'auto theft' &
  offense != 'theft' &
  offense != 'burglary'
)

# rank violent crimes
violent_crimes$offense <-
  factor(violent_crimes$offense,
    levels = c('robbery', 'aggravated assault',
      'rape', 'murder')
  )

# restrict to downtown
violent_crimes <- subset(violent_crimes,
  -95.39681 <= lon & lon <= -95.34188 &
   29.73631 <= lat & lat <=  29.78400
)


# get map and bounding box
theme_set(theme_bw(16))
HoustonMap <- qmap('houston', zoom = 14, color = 'bw',
  extent = 'device', legend = 'topleft')

# the bubble chart
library(grid)
HoustonMap +
   geom_point(aes(x = lon, y = lat, colour = offense, size = offense), data = violent_crimes) +
   scale_colour_discrete('Offense', labels = c('Robery','Aggravated Assault','Rape','Murder')) +
   scale_size_discrete('Offense', labels = c('Robery','Aggravated Assault','Rape','Murder'),
     range = c(1.75,6)) +
   guides(size = guide_legend(override.aes = list(size = 6))) +
   theme(
     legend.key.size = unit(1.8,'lines'),
     legend.title = element_text(size = 16, face = 'bold'),
     legend.text = element_text(size = 14)
   ) +
   labs(colour = 'Offense', size = 'Offense')


# a contour plot
HoustonMap +
  stat_density2d(aes(x = lon, y = lat, colour = offense),
    size = 3, bins = 2, alpha = 3/4, data = violent_crimes) +
   scale_colour_discrete('Offense', labels = c('Robery','Aggravated Assault','Rape','Murder')) +
   theme(
     legend.text = element_text(size = 15, vjust = .5),
     legend.title = element_text(size = 15,face='bold'),
     legend.key.size = unit(1.8,'lines')
   )



# a filled contour plot...
HoustonMap +
  stat_bin2d(aes(x = lon, y = lat, colour = offense, fill = offense),
    size = .5, bins = 30, alpha = 2/4, data = violent_crimes) +
   scale_colour_discrete('Offense',
     labels = c('Robery','Aggravated Assault','Rape','Murder'),
     guide = FALSE) +
   scale_fill_discrete('Offense', labels = c('Robery','Aggravated Assault','Rape','Murder')) +
   theme(
     legend.text = element_text(size = 15, vjust = .5),
     legend.title = element_text(size = 15,face='bold'),
     legend.key.size = unit(1.8,'lines')
   )

# ... with hexagonal bins
HoustonMap +
  stat_binhex(aes(x = lon, y = lat, colour = offense, fill = offense),
    size = .5, binwidth = c(.00225,.00225), alpha = 2/4, data = violent_crimes) +
   scale_colour_discrete('Offense',
     labels = c('Robery','Aggravated Assault','Rape','Murder'),
     guide = FALSE) +
   scale_fill_discrete('Offense', labels = c('Robery','Aggravated Assault','Rape','Murder')) +
   theme(
     legend.text = element_text(size = 15, vjust = .5),
     legend.title = element_text(size = 15,face='bold'),
     legend.key.size = unit(1.8,'lines')
   )



# changing gears (get a color map)
houston <- get_map('houston', zoom = 14)
HoustonMap <- ggmap(houston, extent = 'device', legend = 'topleft')

# a filled contour plot...
HoustonMap +
  stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha = ..level..),
    size = 2, bins = 4, data = violent_crimes, geom = 'polygon') +
  scale_fill_gradient('Violent\nCrime\nDensity') +
  scale_alpha(range = c(.4, .75), guide = FALSE) +
  guides(fill = guide_colorbar(barwidth = 1.5, barheight = 10))

# ... with an insert

overlay <- stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha = ..level..),
    bins = 4, geom = 'polygon', data = violent_crimes)


HoustonMap +
  stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha = ..level..),
    bins = 4, geom = 'polygon', data = violent_crimes) +
  scale_fill_gradient('Violent\nCrime\nDensity') +
  scale_alpha(range = c(.4, .75), guide = FALSE) +
  guides(fill = guide_colorbar(barwidth = 1.5, barheight = 10)) +
  inset(
    grob = ggplotGrob(ggplot() + overlay +
      scale_fill_gradient('Violent\nCrime\nDensity') +
      scale_alpha(range = c(.4, .75), guide = FALSE) +
      theme_inset()
    ),
    xmin = attr(houston,'bb')$ll.lon +
      (7/10) * (attr(houston,'bb')$ur.lon - attr(houston,'bb')$ll.lon),
    xmax = Inf,
    ymin = -Inf,
    ymax = attr(houston,'bb')$ll.lat +
      (3/10) * (attr(houston,'bb')$ur.lat - attr(houston,'bb')$ll.lat)
  )









## more examples
##################################################

# you can layer anything on top of the maps (even meaningless stuff)
df <- data.frame(
  lon = rep(seq(-95.39, -95.35, length.out = 8), each = 20),
  lat = sapply(
    rep(seq(29.74, 29.78, length.out = 8), each = 20),
    function(x) rnorm(1, x, .002)
  ),
  class = rep(letters[1:8], each = 20)
)

qplot(lon, lat, data = df, geom = 'boxplot', fill = class)

HoustonMap +
  geom_boxplot(aes(x = lon, y = lat, fill = class), data = df)




## the base_layer argument - faceting
##################################################

df <- data.frame(
  x = rnorm(1000, -95.36258, .2),
  y = rnorm(1000,  29.76196, .2)
)

# no apparent change because ggmap sets maprange = TRUE with extent = 'panel'
ggmap(get_map(), base_layer = ggplot(aes(x = x, y = y), data = df)) +
  geom_point(colour = 'red')

# ... but there is a difference
ggmap(get_map(), base_layer = ggplot(aes(x = x, y = y), data = df), extent = 'normal') +
  geom_point(colour = 'red')

# maprange can fix it (so can extent = 'panel')
ggmap(get_map(), maprange = TRUE, extent = 'normal',
  base_layer = ggplot(aes(x = x, y = y), data = df)) +
  geom_point(colour = 'red')



# base_layer makes faceting possible
df <- data.frame(
  x = rnorm(10*100, -95.36258, .075),
  y = rnorm(10*100,  29.76196, .075),
  year = rep(paste('year',format(1:10)), each = 100)
)
ggmap(get_map(), base_layer = ggplot(aes(x = x, y = y), data = df)) +
  geom_point() +  facet_wrap(~ year)

ggmap(get_map(), base_layer = ggplot(aes(x = x, y = y), data = df), extent = 'device') +
  geom_point() +  facet_wrap(~ year)


## neat faceting examples
##################################################

# simulated example
df <- data.frame(
  x = rnorm(10*100, -95.36258, .05),
  y = rnorm(10*100,  29.76196, .05),
  year = rep(paste('year',format(1:10)), each = 100)
)
for(k in 0:9){
  df$x[1:100 + 100*k] <- df$x[1:100 + 100*k] + sqrt(.05)*cos(2*pi*k/10)
  df$y[1:100 + 100*k] <- df$y[1:100 + 100*k] + sqrt(.05)*sin(2*pi*k/10)
}

options('device')$device(width = 10.93, height = 7.47)
ggmap(get_map(),
  base_layer = ggplot(aes(x = x, y = y), data = df)) +
  stat_density2d(aes(fill = ..level.., alpha = ..level..),
    bins = 4, geom = 'polygon') +
  scale_fill_gradient2(low = 'white', mid = 'orange', high = 'red', midpoint = 10) +
  scale_alpha(range = c(.2, .75), guide = FALSE) +
  facet_wrap(~ year)



# crime example by month
levels(violent_crimes$month) <- paste(
  toupper(substr(levels(violent_crimes$month),1,1)),
  substr(levels(violent_crimes$month),2,20), sep = ''
)
houston <- get_map(location = 'houston', zoom = 14, source = 'osm', color = 'bw')
HoustonMap <- ggmap(houston,
  base_layer = ggplot(aes(x = lon, y = lat), data = violent_crimes)
  )

HoustonMap +
  stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha = ..level..),
    bins = I(5), geom = 'polygon', data = violent_crimes) +
  scale_fill_gradient2('Violent\nCrime\nDensity',
    low = 'white', mid = 'orange', high = 'red', midpoint = 500) +
  labs(x = 'Longitude', y = 'Latitude') + facet_wrap(~ month) +
  scale_alpha(range = c(.2, .55), guide = FALSE) +
  ggtitle('Violent Crime Contour Map of Downtown Houston by Month') +
  guides(fill = guide_colorbar(barwidth = 1.5, barheight = 10))




## distances example
##################################################

origin <- 'marrs mclean science, baylor university'
gc_origin <- geocode(origin)
destinations <- data.frame(
  place = c("Administration", "Baseball Stadium", "Basketball Arena",
    "Salvation Army", "HEB Grocery", "Cafe Cappuccino", "Ninfa's Mexican",
    "Dr Pepper Museum", "Buzzard Billy's", "Mayborn Museum","Flea Market"
  ),
  address = c("pat neff hall, baylor university", "baylor ballpark",
    "ferrell center", "1225 interstate 35 s, waco, tx",
    "1102 speight avenue, waco, tx", "100 n 6th st # 100, waco, tx",
    "220 south 3rd street, waco, tx", "300 south 5th street, waco, tx",
    "100 north jack kultgen expressway, waco, tx",
    "1300 south university parks drive, waco, tx",
    "2112 state loop 491, waco, tx"
  ),
  stringsAsFactors = FALSE
)
gc_dests <- geocode(destinations$address)
(dist <- mapdist(origin, destinations$address, mode = 'bicycling'))

dist <- within(dist, {
  place = destinations$place
  fromlon = gc_origin$lon
  fromlat = gc_origin$lat
  tolon = gc_dests$lon
  tolat = gc_dests$lat
})
dist$minutes <- cut(dist$minutes, c(0,3,5,7,10,Inf),
  labels = c('0-3','3-5', '5-7', '7-10', '10+'))

library(scales)
qmap('baylor university', zoom = 14, legend = 'bottomright',
    base_layer = ggplot(aes(x = lon, y = lat), data = gc_origin)) +
  geom_rect(aes(
    x = tolon, y = tolat,
    xmin = tolon-.00028*nchar(place), xmax = tolon+.00028*nchar(place),
    ymin = tolat-.0005, ymax = tolat+.0005, fill = minutes, colour = 'black'
  ), alpha = .7, data = dist) +
  geom_text(aes(x = tolon, y = tolat, label = place, colour = 'white'), size = 3, data = dist) +
  geom_rect(aes(
    xmin = lon-.004, xmax = lon+.004,
    ymin = lat-.00075, ymax = lat+.00075, colour = 'black'
  ), alpha = .5, fill = I('green'), data = gc_origin) +
  geom_text(aes(x = lon, y = lat, label = 'My Office', colour = 'black'), size = 5) +
  scale_fill_manual('Minutes\nAway\nby Bike',
    values = colorRampPalette(c(muted('green'), 'blue', 'red'))(5)) +
  scale_colour_identity(guide = 'none') +
  theme(
    legend.direction = 'horizontal',
    legend.key.size = unit(2, 'lines')
  ) +
  guides(
    fill = guide_legend(
      title.theme = element_text(size = 16, face = 'bold', colour = 'black'),
      label.theme = element_text(size = 14, colour = 'black'),
      label.position = 'bottom',
      override.aes = list(alpha = 1)
    )
  )









## darken argument
##################################################
ggmap(get_map())
ggmap(get_map(), darken = .5)
ggmap(get_map(), darken = c(.5,'white'))
ggmap(get_map(), darken = c(.5,'red')) # why?



## End(Not run)
