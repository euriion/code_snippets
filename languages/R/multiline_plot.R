DF <- data.frame(year = 1960:2009,
                 y1 = rnorm(50),
                 y2 = rnorm(50, mean = 2),
                 y3 = rnorm(50, mean = 3, sd = 0.5))

# Melting data essentially stacks y1, y2, y3
library(reshape2)
DFm <- melt(DF, id.vars = "year")
str(DFm)
head(DFm)

library(ggplot2)
# Each variable plotted in a separate facet
ggplot(DFm, aes(x = year, y = value)) +
  geom_line(size = 1) +
  facet_wrap(~ variable, ncol = 1)

# All three variables plotted in one graphics region
ggplot(DFm, aes(x = year, y = value, color = variable)) +
  geom_line(size = 1)

# alternatives: matplot() in base graphics.
