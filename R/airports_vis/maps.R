install.packages("geosphere")
require(geosphere)
require(maps)
#setting up data, summary stats
data(us.cities)
summary(us.cities)

#setting up Los Angeles USA, as point of origin, and all the US cities as
#a destination
LA<-c(-118.41, 34.11)
all<-matrix(data=c(us.cities$long, us.cities$lat), ncol=2)

#Top 5 Cities, in this case all cities are represented once, change n=""
#to change the number, and use tail, instead of head, to find the bottom.
top.5<-barplot(table(head(us.cities$name, n=5)), col='blue', main="Top 5 Cities")

#Getting the distance and histograms, the default is meters, so it is 
#converted to miles, the Vincenty Ellipsoid function takes into account
#that the earth is not perfectly round

dist<-distm(LA, all, fun=distVincentyEllipsoid)*0.000621371192
par(las=0)
hist(dist, main='Histogram of the Distances: Using Vincenty Ellipsoid Function',
     col='blue')

#mapping it out
#US
map("world", col="#f2f2f2", fill=TRUE, bg="white", lwd=0.15, 
    xlim=c(-170, -65), ylim=c(15, 60))


map("world", col="#f2f2f2", fill=TRUE, bg="white", lwd=0.15)
#title(main='US Cities')

for(i in 1:dim(all)[1]){
  inter <- gcIntermediate(LA, all[i, 1:2], n=1005, addStartEnd=TRUE)
  lines(inter, col="blue")
}


