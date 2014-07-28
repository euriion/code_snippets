calif = read.table("~/teaching/350/hw/06/cadata.dat",header=TRUE)
require(tree)
treefit = tree(log(MedianHouseValue) ~ Longitude+Latitude,data=calif)