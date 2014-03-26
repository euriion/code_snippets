# http://theatavism.blogspot.kr/2009/05/plotting-correlation-matrix-with.html
# http://stackoverflow.com/questions/5453336/r-plot-correlation-matrix-into-a-graph

library(ggplot2)
data(iris)

#make the correlation matrix form the first four columns (5th is species names)
(c <- cor(iris[1:4]))  
#             Sepal.Length Sepal.Width Petal.Length Petal.Width 
#Sepal.Length    1.0000000  -0.1175698    0.8717538   0.8179411 
#Sepal.Width    -0.1175698   1.0000000   -0.4284401  -0.3661259 
# ... 
# ... 

# same with p-values, then use symnum() to represent the values as asterisks 
p <- cor.pval(iris[1:4]
#             Sepal.Length  Sepal.Width Petal.Length  Petal.Width
#Sepal.Length    0.0000000 1.518983e-01 0.000000e+00 0.000000e+00 
#Sepal.Width     0.1518983 #0.000000e+00 4.513314e-08 4.073229e-06  
# ...
# ...
stars <- as.character(symnum(p, cutpoints=c(0,0.001,0.01,0.05,1),   
                      symbols=c('***', '**', '*', '' ),  
                      legend=F)) 

#now put them alltogether (with melt() to reshape the correlation matrix) molten.iris <- cbind(melt(c), stars) 
names(molten.iris) <- c("M1", "M2", "corr", "pvalue")   
molten.iris  
#             M1           M2       corr pvalue 
#1  Sepal.Length Sepal.Length  1.0000000    *** 
#2   Sepal.Width Sepal.Length -0.1175698 
#3  Petal.Length Sepal.Length  0.8717538    *** 
# ... 
# ...

#--------------------
(p <- ggplot(molten.iris, aes(M1, M2, fill=corr)) = theme_bw() + geom_tile()) 

