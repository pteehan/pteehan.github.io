
source("convertRoute.R")
plotAllRoutes <- function(code="LHR") {
  segments <- summarizeSegments()
  segments <- segments[to==code]
  plotSegments(segments) + ggtitle(paste0("Flights from ", code))
}

plotSegments <- function(segments, ...) {
  airport_data <- data.table(read.csv("/host/files/airports.csv", header = FALSE))[, list(code=V5, name=V3, country=V4, lat=V7, lng=V8)]
  g <- graph.data.frame(segments)
  library(intergraph)
  library(network)
  n<-asNetwork(g)
  setkey(airport_data, code)
  n %v% "lat" <- airport_data[network.vertex.names(n)]$lat
  n %v% "lon" <- airport_data[network.vertex.names(n)]$lng
  latmin <-  min(n %v% "lat", na.rm=TRUE) - 10
  latmax <- max(n %v% "lat", na.rm=TRUE) + 10
  lonmin <- min(n %v% "lon", na.rm=TRUE) - 10
  lonmax <- max(n %v% "lon", na.rm=TRUE) + 10
  library(maps)
  library(ggmap)
  library(GGally)
  world <- fortify(map("world", plot = FALSE, fill = TRUE))
  world <- ggplot(world, aes(x = long, y = lat)) +
    geom_polygon(aes(group = group), color = "grey65",
                 fill = "#f9f9f9", size = 0.2) +
    coord_quickmap(xlim = c(lonmin, lonmax),ylim = c(latmin, latmax))
  ggnetworkmap(world, n, size=1, great.circles=TRUE, segment.color="steelblue", ...) 
}


plotAirports <- function(codes=c("FRA", "LHR"), labels=TRUE) {
  if(is.data.table(codes)) codes <- codes$to
  airport_data <- data.table(read.csv("/host/files/airports.csv", header = FALSE))[, list(code=V5, name=V3, country=V4, lat=V7, lng=V8)]
  setkey(airport_data, code)
  codes <- codes[codes %in% airport_data$code]
  airports <- airport_data[as.character(codes)]
  latmin <-  min(airports$lat)- 10
  latmax <- max(airports$lat) + 10
  lonmin <- min(airports$lng) - 10
  lonmax <- max(airports$lng) + 10
  world <- fortify(map("world", plot = FALSE, fill = TRUE))
  world <- ggplot(world, aes(x = long, y = lat)) + 
    geom_polygon(aes(group = group), color = "grey65",
                 fill = "#f9f9f9", size = 0.2) +
    coord_quickmap(xlim = c(lonmin, lonmax),ylim = c(latmin, latmax))
  plot <- world + geom_point(data=airports, aes(x=lng, y=lat)) 
  if(labels) plot <- plot +  geom_text(data=airports, aes(label=code, x=lng, y=lat), nudge_y=2, size=3)
  plot
}