library(ggplot2)

# 포인트 그리기
p <- ggplot(data=mtcars, aes(x=wt, y=mpg))
p + geom_point(aes(colour="white"), size=8) + geom_point(pch=21, colour="black", size=9) 

# 포인프 색 바꾸기
p <- ggplot(data=mtcars, aes(x=wt, y=mpg))
p + geom_point(colour="orange")


# mtcars 회귀선 geom_abline 예제
mtcars_coefs <- coef(lm(mpg ~ wt, mtcars))
mtcars_coefs
i <- mtcars_coefs[["(Intercept)"]]
s <- mtcars_coefs[["wt"]]
p <- ggplot(data=mtcars, aes(x=wt, y=mpg))
p + geom_point() + geom_abline(intercept=i, slope=s, colour="red")

# stat_smooth를 이용한 회귀선
p <- ggplot(data=mtcars, aes(x=wt, y=mpg))
p + geom_point() + stat_smooth(method="lm", se=FALSE, colour="red")

# -- geom_bar
p <- ggplot(data=mtcars, aes(factor(cyl)))
p + geom_bar()


p <- ggplot(data=mtcars, aes(cyl))
p + geom_bar()


p <- ggplot(data=mtcars, aes(cyl))
p + geom_bar(binwidth=1)

qplot(factor(cyl), data=mtcars, geom="bar", fill=factor(cyl))


p <- ggplot(data=mtcars, aes(factor(cyl)))
p + geom_bar(aes(fill=cyl), colour="black")


p <- ggplot(data=mtcars, aes(factor(cyl)))
p + geom_bar(aes(fill=factor(gear)), colour="black")


p <- ggplot(data=mtcars, aes(factor(cyl)))
p + geom_bar(aes(fill=factor(gear)), colour="black") + coord_flip()

p <- ggplot(data=mtcars, aes(factor(cyl)))
p + geom_bar(aes(fill=factor(carb)), colour="black") + facet_wrap(~ gear)

colnames(mtcars)

?LakeHuron
is(LakeHuron)
colnames(as.data.frame(LakeHuron))
huron <- data.frame(year = 1875:1972, level = as.vector(LakeHuron))
ggplot(data=huron, aes(x=year)) + geom_area(aes(y=level)) + coord_cartesian(ylim = c(570, 590))

?geom_area
geom_ribbon

ggplot(data=huron, aes(x=year)) + geom_area(aes(y=level)) + coord_cartesian(ylim = c(min(huron$level)-2, max(huron$level)+2))

p <- ggplot(huron, aes(x=year))
p + geom_ribbon()


library(ggplot2)
huron <- data.frame(year = 1875:1972, level = as.vector(LakeHuron))
p <- ggplot(huron, aes(x=year))
p <- p + geom_ribbon(aes(ymin=level-2, ymax=level+2), fill="blue", colour="black")
p <- p + geom_point(aes(y=level), colour="black")
p <- p + geom_line(aes(y=level), colour="lightgray")
p

?bsts
library(bsts)
data(goog)
attributes(goog)
goog_stock <- as.data.frame(goog)
colnames(goog_stock)
data.frame(price=)

install.packages("quantmod")
library(quantmod)
getSymbols("AAPL")
getSymbols("AAPL", from=as.Date("2014-05-01"),to=as.Date("2014-05-31"))


colnames(AAPL)
rownames(AAPL)
index(AAPL)
?index
p <- ggplot(AAPL, aes(x=index(AAPL), y=AAPL.Close))
p <- p + geom_ribbon(aes(min=AAPL.Low, max=AAPL.High), fill="blue", colour="black")
p <- p + geom_point(aes(y=AAPL.Close), colour="black")
p <- p + geom_line(aes(y=AAPL.Close), colour="green")
# p <- p + geom_smooth(aes(y=AAPL.Close), colour="red")
p <- p + stat_smooth(method="lm", se=FALSE, colour="red")
p

# -- geom_boxplot 예제 코드
p <- ggplot(mtcars, aes(factor(cyl), mpg))
p + geom_boxplot(aes(fill=factor(am)))

# fill brewer

p <- ggplot(mtcars, aes(factor(cyl), mpg, fill=carb))
p + geom_boxplot(fil) + facet_grid(~am)
p + geom_boxplot(fill=factor(carb))


p <- ggplot(mtcars, aes(factor(cyl), mpg))
p + geom_boxplot() + scale_fill_brewer(palette="Blues")
p + geom_boxplot() + facet_grid(~am) + scale_fill_brewer(aes(fill=factor(carb)))

p <- ggplot(mtcars, aes(factor(cyl), mpg))
p + geom_boxplot(aes(fill=factor(carb))) + facet_grid(~am) + scale_fill_brewer()

ggplot(diamonds, aes(x=price, fill=cut)) +
  geom_histogram(position="dodge", binwidth=1000) +
  scale_fill_brewer(palette="Blues")


?scale_fill_brewer
# -- reference
require(graphics)
pairs(mtcars, main = "mtcars data")
coplot(mpg ~ disp | as.factor(cyl), data = mtcars,
       panel = panel.smooth, rows = 1)


# -- geom_hisogram
dim(islands)
is(islands)
islands
islands.df <- as.data.frame(islands)
colnames(islands.df)
p <- ggplot(data=islands.df, aes(x=islands))
p + geom_histogram(binwidth=2500)
data()

?hist

custom_data <- rnorm(n=1000, m=24.2, sd=2.2)


colnames(islands.df)
p <- ggplot(data=islands.df, aes(x=islands))
p + geom_histogram(breaks=cumsum(c(180,100,110,160,200,250,1000,3000)))

colnames(rotifer)
head(rotifer)
p <- ggplot(data=rotifer, aes(x=density))
p + geom_histogram(binwidth=0.02)


movies
?movies
set.seed(5689)
movies <- movies[sample(nrow(movies), 1000), ]
colnames(movies)
ggplot(data=movies, aes(x=rating)) + geom_histogram()


set.seed(5689)
movies <- movies[sample(nrow(movies), 1000), ]
p <- ggplot(data=movies, aes(x=rating))
p + geom_histogram()

set.seed(5689)
movies <- movies[sample(nrow(movies), 1000), ]
p <- ggplot(data=movies, aes(x=rating))
p + geom_histogram(binwidth=1)


set.seed(5689)
movies <- movies[sample(nrow(movies), 1000), ]
p <- ggplot(data=movies, aes(x=rating))
p <- p + geom_histogram(binwidth=1, aes(y = ..density.., fill=..count..), colour="black")
p <- p + geom_density(colour="red") 
p + scale_fill_gradient(low="white", high="#496ff5")


# ==========================
?movies
colnames(movies)
library(plyr)
movies$decade <- round_any(movies$year, 10)
p <- ggplot(movies, aes(x = rating))
p + geom_density()

# ==========================
p <- ggplot(movies, aes(x = rating))
p + geom_density(aes(fill=factor(mpaa)), alpha=0.25)

# ==========================
p <- ggplot(movies, aes(x = rating))
p + geom_density(kernel="rectangular")
# biweight
# epanechnikov
# adjust=1/5
# adjust=5

p + geom_density(aes(fill=factor(mpaa)), alpha=0.2)
# ==========================




p <- ggplot(geyser, aes(x = duration, y = waiting))
p <- p + geom_point() + xlim(0.5, 6) + ylim(40, 110)
p + geom_density2d()

p <- ggplot(geyser, aes(x=duration, y=waiting))
p <- p + geom_point() + xlim(min(geyser$duration)-0.5, max(geyser$duration)+0.5) + ylim(min(geyser$waiting)-5, max(geyser$waiting)+5)
p + geom_density2d()

ggplot2:::ylim


library(reshape2) # for melt
volcano3d <- melt(volcano)
names(volcano3d) <- c("x", "y", "z")

# Basic plot
p <- ggplot(volcano3d, aes(x, y, z = z))
p <- p + geom_contour(binwidth = 2, size = 0.5, aes(colour= ..level..))
v

p <- ggplot(volcano3d, aes(x, y, z = z))
p + geom_contour()

p + geom_contour(binwidth = 3, size = 0.5, aes(colour= ..level..))
p

?volcano
index(volcano)
head(volcano)
dim(volcano)
?geom_contour

melt(volcano)[[1,1,]]
?volcano
names(volcano)
is(volcano)
attributes(volcano)
colnames(volcano)
rownames(volcano)
index(volcano)
names(volcano)


melt(volcano)[2,]
volcano[2]
dim(volcano)


p <- ggplot(mtcars, aes(x=wt, y=mpg, label=rownames(mtcars)))
p + geom_text(aes(colour=factor(cyl)))

p <- ggplot(mtcars, aes(x=wt, y=mpg, label=rownames(mtcars)))
p <- p + geom_point()
p + geom_text(aes(x=wt+0.05, colour=factor(cyl)), size=5, hjust=0)



crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)
library(reshape2) # for melt
library(maps)
crimesm <- melt(crimes, id = 1)
states_map <- map_data("state")
p <- ggplot(crimes, aes(map_id = state))
p <- p + geom_map(aes(fill = Murder), map=states_map)
p <- p + expand_limits(x = states_map$long, y = states_map$lat)
p <- p + coord_map()
p + facet_wrap( ~ variable)
p
ggplot(crimesm, aes(map_id = state)) + geom_map(aes(fill = value), map = states_map) + expand_limits(x = states_map$long, y = states_map$lat) + facet_wrap( ~ variable)

p <- ggplot(crimes, aes(x = states_map$long, y = states_map$lat, map_id = state))
p <- p + geom_map(aes(fill = Murder), map=states_map)
p <- p + expand_limits()
p <- p + coord_map()
p + facet_wrap( ~ variable)
p


simple <- data.frame(x = rep(1:10, each = 2))
base <- ggplot(simple, aes(x))
# By default, right = TRUE, and intervals are of the form (a, b]
base + stat_bin(binwidth = 1, drop = FALSE, right = TRUE, col = "black") + geom_bar()

m <- ggplot(movies, aes(x=rating))
m <- m + stat_bin(binwidth=0.1, aes(fill=..count..), colour="black", geom="point")
m <- m + stat_bin(binwidth=0.1, aes(fill=..count..), colour="black", geom="contour")
m <- m + stat_bin(binwidth=0.1, aes(fill=..count..), colour="black", geom="line")
m <- m + stat_bin(binwidth=0.1, aes(fill=..count..), colour="black", geom="bar")

m <- ggplot(movies, aes(x=rating))
m <- m + geom_line()
m + stat_bin(binwidth=0.1)

m <- ggplot(movies, aes(x=mpaa, y=rating, fun.y = "mean"))
m + stat_summary(geom="point")

p <- qplot(cyl, mpg, data=mtcars)
p <- p + stat_summary(fun.data = "mean_cl_boot", colour = "red")
p <- p + stat_summary(fun.data = "mean", colour = "blue")
p

colnames(movies)
p <- ggplot(movies, aes(x = rating))
p + geom_density(aes(fill="0.25"), alpha=0.25, colour="black") 

colnames(movies)

ggplot(diamonds, aes(x = price)) +
  stat_density(aes(ymax =..density..,  ymin=-..density..),
               fill = "blue", colour = "black", alpha=0.50,
               geom = "area", position = "identity") +
  facet_grid(. ~ cut) 
+
  coord_flip()


ggplot(diamonds, aes(x = price)) +
  stat_density(aes(ymax = ..density..,  ymin = -..density..),
               fill = "blue", colour = "black", alpha = 0.50,
               geom = "area", position = "identity") +
  facet_grid(. ~ cut) 



  ggplot(diamonds, aes(x = price, fill=cut)) +
  stat_density(aes(ymax = ..density..,  ymin = -..density..),
               colour = "black", alpha = 0.15,
               geom = "area", position = "identity")








install.packages("hexbin")
library(hexbin)
g <- ggplot(diamonds, aes(carat, price))
g + stat_binhex(binwidth=c(20,10))
g
?stat_binhex


# =========================================================
# (120000000 + 80000000*1.3) / 270000000
# (120000000 + 90000000*1.3) / 270000000
# 270000000 * 0.6
# 160000000
# =========================================================
df <- data.frame(x = c(rnorm(100, 0, 3), rnorm(100, 0, 10)),
                 g = gl(2, 100))
p <- ggplot(df, aes(x, colour = g))
p + stat_ecdf(geom="line", size=1)

df <- data.frame(x = c(rnorm(100, 0, 3), rnorm(100, 0, 10)),
                 g = gl(2, 100))
p <- ggplot(df, aes(x, colour = g))
p + stat_ecdf(geom="line")
?gol
rnorm(100,0,10)
??scales
c(rnorm(100, 0, 3), rnorm(100, 0, 10))

gl(2, 10)
ggplot2:::stat_ecdf

ggplot2:::proto


library(proto)
??proto

x <- rnorm(100)
base <- qplot(x, geom = "density")
base + stat_function(fun = dnorm, colour = "red")
base + stat_function(fun = dnorm, colour = "red", arg = list(mean = 3))


x <- rnorm(100)
p <- qplot(x, geom = "density")
p + stat_function(fun = dnorm, colour = "red", alpha=0.25)


d <- data.frame(x=rnorm(100))
p <- ggplot(d, aes(x=x))
p <- p + geom_density(fill="green", alpha=0.15)
p + stat_function(fun = dnorm, colour = "red", fill="red",alpha=0.15, geom="area")


?dnorm
