library(ggplot2)
library(reshape2)
cohort.clients <- read.delim("./cohort.tsv")

cohort.chart.cl <- melt(cohort.clients, id.vars = 'cohort')
colnames(cohort.chart.cl) <- c('cohort', 'month', 'clients')
reds <- colorRampPalette(c('pink', 'dark red'))
p <- ggplot(cohort.chart.cl, aes(x=month, y=clients, group=cohort))
p + geom_area(aes(fill = cohort)) +
  scale_fill_manual(values = reds(nrow(cohort.clients))) +
  ggtitle('Active clients by Cohort')

# It seems like a lot of customers purchased once and gone. It can be a reason why total revenue is mainly provided by new customers.

# And finally we can calculate and visualize the average revenue per client. The R code can be the next:

cohort.sum <- read.delim("./cohort.sum.tsv")
#we need to divide the data frames (excluding cohort name)
rev.per.client <- cohort.sum[,c(2:13)]/cohort.clients[,c(2:13)]
rev.per.client[is.na(rev.per.client)] <- 0
rev.per.client <- cbind(cohort.sum[,1], rev.per.client)

#define palette
greens <- colorRampPalette(c('light green', 'dark green'))

#melt and plot data
cohort.chart.per.cl <- melt(rev.per.client, id.vars = 'cohort.sum[, 1]')
colnames(cohort.chart.per.cl) <- c('cohort', 'month', 'average_revenue')
p <- ggplot(cohort.chart.per.cl, aes(x=month, y=average_revenue, group=cohort))
p + geom_area(aes(fill = cohort)) +
 scale_fill_manual(values = greens(nrow(cohort.clients))) +
 ggtitle('Average revenue per client by Cohort')
