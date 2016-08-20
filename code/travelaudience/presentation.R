
#Flight connections @ travel audience
#Paul Teehan, Aug 21 2016


#Given a bookings dataset, find:

#- Flight segments with highest and lowest share of connecting passengers
#- Airports with highest and lowest share of connecting passengers

#Region        |  % connecting
#-----------------------------
#Latin America |     7.9    
#Asia          |     9.5
#Europe        |     32.8
#US/Canada     |     23.4

# Airport Economics in Latin America and the Carribean, T. Serebisky, 2006 (found via Google)
 

#SELECT rloc, brd_port, off_port, route FROM bookings_sub WHERE rloc='03439e5224f877372fd338fa425b8102';

#WITH x AS (SELECT char_length(trim(route)) AS route_length FROM bookings_sub) SELECT route_length, count(route_length), round(COUNT(route_length)/(SELECT COUNT(*) from bookings_sub)::numeric,3) AS pct FROM x GROUP BY route_length ORDER BY route_length;

source('convertRoute.R')
convertRoute(c("AAABBBCCC", "DDDEEE", "FFFGGGHHHIII"))

segments <- summarizeSegments()
airports <- segments[, list(passengers=sum(passengers), connecting_passengers=sum(connecting_passengers)), by="to"]


# Visualization 
# convert to graph
library(igraph)
g <- graph.data.frame(segments[to=="TXL"])
g
plot(g, edge.arrow.size=0)

# Merge in lat/long and plot on a map

airport_data <- data.table(read.csv("/host/files/airport_data.csv"))
setkey(airport_data, code)
library(intergraph)
library(network)
n<-asNetwork(g)
n %v% "lat" <- airport_data[network.vertex.names(n)]$lat
n %v% "lon" <- airport_data[network.vertex.names(n)]$lng

library(maps) 
library(ggmap) 
library(GGally)
world <- fortify(map("world", plot = FALSE, fill = TRUE))
world <- ggplot(world, aes(x = long, y = lat)) + geom_polygon(aes(group = group), color = "grey65",fill = "#f9f9f9", size = 0.2)
ggnetworkmap(world, n, size=1, great.circles=TRUE, segment.color="steelblue") 

source("plotting.R")
plotAllRoutes("TXL")
plotAllRoutes("SXF")
plotAllRoutes("FRA")



# Analysis of connections

# Airports first 
airports <- segments[, list(passengers=sum(passengers), connecting_passengers=sum(connecting_passengers)), by="to"]
airports[, pct_connecting := connecting_passengers/passengers]

# top 20 by pct connecting
airports[passengers>1000][order(-pct_connecting)][1:20]
# these seem to be primarily transit hubs, rather than destinations
plotAllRoutes("CLT") # Charlotte
plotAllRoutes("DOH") # Doha
plotAllRoutes("BWN") # Brunei
plotAllRoutes("ATL") # Atlanta
plotAllRoutes("PTY") # Panama City
plotAllRoutes("AUH") # Abu Dhabi
plotAirports(airports[passengers>1000][order(-pct_connecting)][1:20]) + ggtitle("Top 20 airports by pct connecting")
# Note many of these are very close geographically
plotAirports(c("BAH", "DOH", "DXB", "AUH"))


# Largest 'low connection' airports
airports[pct_connecting < 0.05][order(-passengers)][1:10]
plotAllRoutes("TLV") # tel aviv
plotAllRoutes("MCO") # orlando
plotAllRoutes("LAS") # Las Vegas
plotAllRoutes("BEY") # Beirut
plotAllRoutes("HAM") # Hamberg
plotAllRoutes("DMM") # Dammam, Saudi Arabia
plotAirports(c("DMM", "DOH", "DXB", "BAH", "AUH"))

# largest 'zero connection' airports
airports[pct_connecting == 0][order(-passengers)][1:4]
plotAllRoutes("KTM") # Kathmandu,Nepal
plotAllRoutes("KRT") # Khartoum, Sudan
plotAllRoutes("ORF") # Norfolk, Virginia (?)
plotAllRoutes("ORN") # Oran, Algeria

ggplot(airports[order(-connecting_passengers)][1:20], aes(x=passengers, y=connecting_passengers)) + geom_point() +
  geom_text(aes(label=to), nudge_x=-1.2e4) + theme_bw() + coord_equal() + expand_limits(x=0,y=0) + ggtitle("Top 20 airports by total connecting passengers")
ggplot(airports[order(-passengers)][1:20], aes(x=passengers, y=pct_connecting)) + geom_point() +
  geom_text(aes(label=to), nudge_x=-1.2e4) + theme_bw() + expand_limits(x=0,y=0)

ggplot(airports[order(-connecting_passengers)][1:20], aes(x=passengers, y=pct_connecting)) + geom_point() +
  geom_text(aes(label=to), nudge_x=-1.2e4) + theme_bw() + expand_limits(x=0,y=0)





ggplot(airports, aes(x=passengers, y=pct_connecting)) + geom_point() +
  theme_bw() + expand_limits(x=0,y=0)


plotAirports(airports[passengers>1000][order(-pct_connecting)][1:20])+ggtitle("Top 20 airports by % connecting")

plotAirports(airports[passengers>1000][order(pct_connecting)][1:20])+ggtitle("Bottom 20 airports by % connecting")


#Highest-connecting segments
segments[, pct_connect := connecting_passengers/passengers]
segments[order(-pct_connect)][1:20]


```


Model as a Binomial random variable
========================================================
class: small-code
```{r echo=TRUE}
library(Hmisc)
intervals <- binconf(segments$connecting_passengers, segments$passengers)
segments[, lower := round(intervals[,2],4)]
segments[, upper := round(intervals[,3],4)]
segments[order(-lower)][1:20]
```

Lowest-connecting segments
========================================================
class: small-code
```{r echo=TRUE}
segments[passengers>1000][order(pct_connecting)][1:20]
```


plotSegments(segments[passengers>1000][order(upper)][1:50], arrow.size=0.2)+ggtitle("50 lowest-connecting segments")

plotSegments(segments[passengers>1000][order(-lower)][1:50], arrow.size=0.2)+ggtitle("50 highest-connecting segments")





