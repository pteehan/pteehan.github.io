
#Flight connections @ [company]
#Paul Teehan, Aug 21 2016


# Airport Economics in Latin America and the Carribean, T. Serebisky, 2006 (found via Google)
#Region        |  % connecting
#-----------------------------
#Latin America |     7.9    
#Asia          |     9.5
#Europe        |     32.8
#US/Canada     |     23.4

 
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

plotAirports(airports, labels=FALSE) # all the world's airports

# Analysis of connections

# Airports first 
airports <- segments[, list(passengers=sum(passengers), connecting_passengers=sum(connecting_passengers)), by="to"]
airports[, pct_connecting := connecting_passengers/passengers]

# most airports carry few passengers with few connections
ggplot(airports, aes(x=passengers)) + geom_histogram(binwidth=5000) + theme_bw()
ggplot(airports, aes(x=pct_connecting)) + geom_histogram() + theme_bw()
ggplot(airports, aes(x=passengers, y=pct_connecting)) + geom_point(alpha=0.1) + theme_bw()
ggplot(airports, aes(x=passengers, y=pct_connecting)) + geom_point(alpha=0.3) + theme_bw()+ scale_x_log10()

# top 10 by pct connecting
airports[passengers>1000][order(-pct_connecting)][1:10]
# these seem to be primarily transit hubs, rather than destinations
plotAllRoutes("CLT") # Charlotte
plotAllRoutes("DOH") # Doha
plotAllRoutes("BWN") # Brunei
plotAllRoutes("ATL") # Atlanta
plotAllRoutes("PTY") # Panama City
plotAllRoutes("AUH") # Abu Dhabi
plotAllRoutes("ADD") # Addis Ababa (Ethiopia)
plotAirports(airports[passengers>1000][order(-pct_connecting)][1:20]) + ggtitle("Top 20 airports by pct connecting")
# Note many of these are very close geographically
plotAirports(c("BAH", "DOH", "DXB", "AUH"))
# why are these airports hubs? what do they have in common?
# economically developed; geographically central; what else?

# Largest 'low connection' airports
airports[pct_connecting < 0.05][order(-passengers)][1:10]
plotAllRoutes("TLV") # tel aviv
plotAllRoutes("MCO") # orlando
plotAllRoutes("LAS") # Las Vegas
plotAllRoutes("BEY") # Beirut
plotAllRoutes("HAM") # Hamberg
plotAllRoutes("DMM") # Dammam, Saudi Arabia
plotAirports(c("DMM", "DOH", "DXB", "BAH", "AUH"))

# many of these have little obvious differences from hubs

# largest 'zero connection' airports
airports[pct_connecting == 0][order(-passengers)][1:10]
plotAllRoutes("KTM") # Kathmandu,Nepal
plotAllRoutes("KRT") # Khartoum, Sudan
plotAllRoutes("ORF") # Norfolk, Virginia (?)
plotAllRoutes("ORN") # Oran, Algeria

# 'end of the line' = no connections


# conclusions:
# Major hubs seem to be present in economically developed areas
# Major hubs can be very close to one another geographically
# Isolation seems to imply low-connectivity (but not the converse)
# Hypothesis: economic conditions detemine connectivity of an airport

###
# Now let's look at flight segments
segments[, pct_connecting := connecting_passengers / passengers]
segments[passengers>0][order(-pct_connecting)][1:20]

# most segments have few passengers 
ggplot(segments, aes(x=passengers)) + geom_histogram(binwidth=200) + theme_bw()

ggplot(segments, aes(x=passengers, y=pct_connecting)) + geom_point()
# most segments have no connections, some have 100%
ggplot(segments, aes(x=pct_connecting)) + geom_histogram() + theme_bw()
ggplot(segments, aes(x=passengers, y=pct_connecting)) + geom_point(alpha=0.01) + theme_bw()

# if you throw away zero and 100% connections what's left? 
ggplot(segments[pct_connecting > 0 & pct_connecting < 1], aes(x=pct_connecting)) + geom_histogram()

# Largest 'high connection' segments
segments[pct_connecting>0.90][order(-passengers)][1:10]
plotSegments(segments[pct_connecting>0.90][order(-passengers)][1:100], arrow.size=0.2)+ggtitle("50 largest high-connecting segments")
# Traffic travelling into hubs
# Seems to be either short or long haul, not mid-range

# Largest 'zero connection' segments
segments[pct_connecting==0][order(-passengers)][1:10]
plotSegments(segments[pct_connecting==0][order(-passengers)][1:50], arrow.size=0.2)+ggtitle("50 largest zero-connecting segments")
# Traffic travelling outward from hubs

# Conclusions
# - Connectivity strongly influenced by whether destination is a 'hub'
# - Connections more common for short and long flights, not mid-length


