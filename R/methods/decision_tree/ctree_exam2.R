# http://scg.sdsu.edu/ctrees_r/

# source("http://scg.sdsu.edu/wp-content/uploads/2013/09/dataprep.r")
setwd("C:\\Users\\aiden.hong\\Documents\\workspace\\code_snippets\\R\\decision_tree")
source("./dataprep.r")
library(rpart)

mycontrol = rpart.control(cp = 0, xval = 10)
fittree = rpart(income~., method = "class",
                data = data$train, control = mycontrol)
fittree$cptable