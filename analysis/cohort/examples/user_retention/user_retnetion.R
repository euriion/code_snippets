# measuring-user-retention-using-cohort-analysis-with-r

require(plyr)

# Load SystematicInvestor's plot.table (https://github.com/systematicinvestor/SIT)
#con = gzcon(url('http://www.systematicportfolio.com/sit.gz', 'rb'))
#source(con)
#close(con)
setwd("/Users/euriion/Documents/workspace/TomorrowWorks/analysis/cohort/examples/user_retention")
#source("./sit.R")

require(RCurl)
sit = getURLContent('https://github.com/systematicinvestor/SIT/raw/master/sit.gz', binary=TRUE, followlocation = TRUE, ssl.verifypeer = FALSE)
con = gzcon(rawConnection(sit, 'rb'))
source(con)
close(con)

cohorts <-read.delim("./cohort.clients2.tsv")
# Read the data
df <- cohorts
# Let's convert absolute values to percentages (% of the registered users remaining active) 
cohort_p <-as.data.frame(cbind(
as.numeric(df$active_m0/df$signed_up), 
as.numeric(df$active_m1/df$signed_up), 
as.numeric(df$active_m2/df$signed_up),
as.numeric(df$active_m3/df$signed_up), 
as.numeric(df$active_m4/df$signed_up), 
as.numeric(df$active_m5/df$signed_up),
as.numeric(df$active_m6/df$signed_up),
as.numeric(df$active_m7/df$signed_up), 
as.numeric(df$active_m8/df$signed_up),
as.numeric(df$active_m9/df$signed_up),
as.numeric(df$active_m10/df$signed_up)
))


# Create a matrix
temp <- as.matrix(cohort_p[,1:(length(cohort_p[1,])-1)])
colnames(temp) <- paste('Month', 0:(length(temp[1,])-1), sep=' ')
rownames(temp) <- as.vector(cohort_p$V1)

# Drop 0 values and format data
temp[] <- plota.format(100 * as.numeric(temp), 0, '', '%')
temp[temp == " 0%"] # Plot cohort analysis table
plot.table(temp, smain='Cohort(users)', highlight = TRUE, colorbar = TRUE)


function
(
  temp # matrix to plot
){
  # convert temp to numerical matrix
  temp = matrix(as.double(gsub('[%,$]', '', temp)), nrow(temp), ncol(temp))
  
  highlight = as.vector(temp)
  cols = rep(NA, len(highlight))
  ncols = len(highlight[!is.na(highlight)])
  cols[1:ncols] = rainbow(ncols, start = 0, end = 0.3)
  
  o = sort.list(highlight, na.last = TRUE, decreasing = FALSE)
  o1 = sort.list(o, na.last = TRUE, decreasing = FALSE)
  highlight = matrix(cols[o1], nrow = nrow(temp))
  highlight[is.na(temp)] = NA
  return(highlight)
}


function
(
  plot.matrix # matrix to plot
)
{
  nr = nrow(plot.matrix) + 1
  nc = ncol(plot.matrix) + 1
  
  c = nc
  r1 = 1
  r2 = nr
  
  rect((2*(c - 1) + .5), -(r1 - .5), (2*c + .5), -(r2 + .5), col='white', border='white')
  rect((2*(c - 1) + .5), -(r1 - .5), (2*(c - 1) + .5), -(r2 + .5), col='black', border='black')
  
  y1= c( -(r2) : -(r1) )
  
  graphics::image(x = c( (2*(c - 1) + 1.5) : (2*c + 0.5) ),
                  y = y1,
                  z = t(matrix( y1 , ncol = 1)),
                  col = t(matrix( rainbow(len( y1 ), start = 0.5, end = 0.6) , ncol = 1)),
                  add = T)
}

# make matrix shorter for the graph (limit to 0-6 months)
temp = as.matrix(cohort_p[,1:(length(cohort_p[1,])-1)])
# temp <- temp[temp == "0"]
library(RColorBrewer)
library(paltran)

colnames(temp) <- paste('Month', 0:(length(temp[1,])-1), 'retention', sep=' ')
palplot(temp[,1],pch=19,xaxt="n",col=pal[1],type="o",ylim=c(0,as.numeric(max(temp[,-2],na.rm=T))),xlab="Cohort by Month",ylab="Retention",main="Retention by Cohort")

for(i in 2:length(colnames(temp))) {
  points(temp[,i],pch=19,xaxt="n",col=pal[i])
  lines(temp[,i],pch=19,xaxt="n",col=pal[i])
}

axis(1,at=1:length(cohort_p$cohort),labels=as.vector(cohort_p$cohort),cex.axis=0.75)
legend("bottomleft",legend=colnames(temp),col=pal,lty=1,pch=19,bty="n")
abline(h=(seq(0,1,0.1)), col="lightgray", lty="dotted")

