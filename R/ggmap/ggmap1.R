install.packages("ggmap")
library(ggmap)

##################################################
hdf <- get_map()
ggmap(hdf, extent = 'normal')
ggmap(hdf) # extent = 'panel', note qmap defaults to extent = 'device'
ggmap(hdf, extent = 'device')
require(MASS)
mu <- c(-95.3632715, 29.7632836)
nDataSets <- sample(4:10,1)
chkpts <- NULL
for(k in 1:nDataSets){
  a <- rnorm(2); b <- rnorm(2); si <- 1/3000 * (outer(a,a) + outer(b,b))
  chkpts <- rbind(chkpts, cbind(mvrnorm(rpois(1,50), jitter(mu, .01), si), k))
}
chkpts <- data.frame(chkpts)
names(chkpts) <- c('lon', 'lat','class')
#chkpts$class <- factor(chkpts$class)
chkpts$class <- factor(chkpts$class,
  levels = c(1,2,3,4,5,6,7,8,9,10),
  labels = c("일", "이", "삼", "사", "오", "육", "칠", "팔", "구", "십"))

#par(family="나눔고딕")
qplot(lon, lat, data = chkpts, colour = class)

ggmap(hdf, extent = 'normal') +
geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5) +
theme(
  legend.title = element_text(size = 16, face = 'bold', family="나눔고딕"),
  legend.text = element_text(size = 14, family="나눔고딕")
)

ggmap(hdf) +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)
ggmap(hdf, extent = 'device') +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)
theme_set(theme_bw())
ggmap(hdf, extent = 'device') +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)
ggmap(hdf, extent = 'device', legend = 'topleft') +
  geom_point(aes(x = lon, y = lat, colour = class), data = chkpts, alpha = .5)
