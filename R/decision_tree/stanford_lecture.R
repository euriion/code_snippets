# starnford CART lecture
# http://statweb.stanford.edu/~lpekelis/talks/13_datafest_cart_talk.pdf
# http://statweb.stanford.edu/~lpekelis/13_datafest_cart/

# install the package to R
install.packages("rpart", repos = "http://cran.nexr.com")

# load the library
library(rpart)
# load the dataset
load("spac.Rdata")
head(spac.data)
spac.tree = rpart(Donation ~ ., data = spac.data, cp = 10^(-6))


#### the function arguments:
# 1) formula, of the form: outcome ~ predictors
# note: outcome ~ . is 'use all other variables in data'
# 2) data: a data.frame object, or any matrix which has variables as
# columns and observations as rows
# 3) cp: used to choose depth of the tree, we'll manually prune the tree
# later and hence set the threshold very low (more on this later)
# The commands, print() and summary() will be useful to look at the tree.
# But first, lets see how big the created tree was
# The object spac.tree is a list with a number of entires that can be
# accessed via the $ symbol. A list is like a hash table.
# To see the entries in a list, use names()
names(spac.tree)

# Within spac.tree the cptable will tell us a little about the size of the
# tree
spac.tree$cptable[1:10, ]

spac.tree$cptable[dim(spac.tree$cptable)[1] - 9:0, ]

# that's a lot of splits! I'm going to prune the tree to 9 splits
cp9 = which(spac.tree$cptable[, 2] == 9)
spac.tree9 = prune(spac.tree, spac.tree$cptable[cp9, 1])
# now lets look at the tree with print() and summary()
print(spac.tree9)
library(rpart.plot)
prp(spac.tree9)

library(party)
library(partykit)

plot(spac.tree9)
text(spac.tree9)
boxplot(spac.tree9)


# will use a combination of list entries: frame, splits, and csplit
spac.tree9$frame[1:5, ]

# frame is a matrix with 1 row per node of the tree
# row name corresponds to a unique node index
# var - name of the variable used in the split, or <leaf>
# n - number of observations reaching the node
# yval - the fitted outcome value at the node
####


spac.tree9$splits[1:5, ]
## count ncat improve index adj
## NV 3668 2 0.017664 1.0 0
## FID 3668 5 0.012395 2.0 0
## Month 3668 1 0.005567 5.5 0
## smbiz 3668 2 0.004716 3.0 0
## retired 3668 2 0.003653 4.0 0
# splits characterizes the splits making the regions Rm
# row name is the variable being split
# count - the number of observations coming into the split
# ncat - number of categories of categorical variable, or 1 if the
# variable is numeric
# improve - the improvement in the objective using the split
# index - either the row number of the csplit matrix (for categorical
# variables), or the value of the optimal split (for numeric variables)

spac.tree9$csplit[1:5, ]
## [,1] [,2] [,3] [,4] [,5]
## [1,] 1 3 2 2 2
## [2,] 1 3 1 1 1
## [3,] 1 3 2 2 2
## [4,] 3 1 2 2 2
## [5,] 1 3 1 1 1

# has 1 row for each split on a categorical variable
# the row number corresponds to index in spac.tree11$split above
# each column is an ordered level of a categorical variable, up to the max
# levels of any categorical var
# an entry of 1 - that level goes left in the split
# 3 - that level goes right in the split
# 2 - that level is not included in the split


rownames(spac.tree9$splits)
spac.tree9$splits[,"count"]
spac.tree9$splits[,"index"]
spac.tree9$splits[,"ncat"]

spac.tree9$frame[,"var"]
spac.tree9$[,"n"]
spac.tree9$frame[,"yval"]
spac.tree9$csplit corresponding to the rows given by "index" where "ncat" > 2
in "splits"

# Automatic Way to Select Tree Size
which.min(spac.tree$cptable[, 4])
# gives a value of 1, meaning none of the splits are 'pervasize'
# but using the criteria above, penalizing large trees
cpstat = dim(spac.data)[1] * spac.tree$cptable[, 3] + 2 * (spac.tree$cptable[,                                                                          2] + 1)
round(spac.tree$cptable[which.min(cpstat), ], 3)
## CP nsplit rel error xerror xstd 
## 0.001 39.000 0.808 1.064 0.313 
# suggests a tree size with 39 splits


Advantages of Trees
1. Fast computations
2. Invariant under monotone transformations of variables
Scaling doesn’t matter!
  Immune to outliers in x
3. Resistence to irrelevant variables, so can throw lots of variables into it
4. One tuning parameter (tree size, or cp)
5. Interpretable model representation
6. Handles missing data by keeping track of surrogate, or highly correlated,
backup splits at every node
7. Extends to categorical outcomes easily

Disadvantages of Trees
1. Accuracy
may not be piecewise constant (but decent overall approximation)
Data Fragmentation (ok, if you have lots of data)
must involve high order interactions
2. Variance
Each subsequent split depends on the previous ones, so an error in a higher split is propogated
down.
Small change in dataset can cause big change in tree
If you only have a random sample of a population, this can be a problem.
Not as much of an issue if you’re describing a dataset


# Elements of Statistical Learning. 2009. New York. Springer. xxii, 745 p. : ill. ; 24 cm.
# Jerome Friedman
# http://www-stat.stanford.edu/~owen/courses/321/readings/CV-SVD-JSM.pdf


Two solutions to Disadvantages (extra slides)
1. Boosted Trees, aka Forests, MART
Now each is a tree, and is a linear combination of trees
Each tree can model an additive effect, or many low order interactions
Variance of a combination of identically distributed objects is lower than any individual
Disadvantage: loses decision tree interpretability unless K is small
2. Random Forests
Similar to boosted trees, but now random subsets of the data are used for each tree
Simpler to fit than boosted trees
Accuracy is usually somewhere in between a single tree and boosted trees

How are Boosted Trees Interpreted? (extra slides)
Relative Importance
Average overall improvement of objective by variable 
Partial Dependence
Predicted outcome using , after averaging out the others