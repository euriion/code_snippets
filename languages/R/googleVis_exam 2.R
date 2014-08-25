library(googleVis)
filename <- "/Users/aiden.hong/my_work/r_codes/UNdata_Export_20120910_225738026.csv"
#input<- read.csv("data.csv")
input<- read.csv(filename)

select<- input[which(input$Subgroup=="Total 5-14"),]

select<- input[which(input$Subgroup=="Total 5-14 yr"),]

Map<- data.frame(select$Country.or.Area, select$Value)

names(Map)<- c("Country", "Percentage")

Geo=gvisGeoMap(Map, locationvar="Country", numvar="Percentage",
options=list(height=350, dataMode='regions'))

plot(Geo)