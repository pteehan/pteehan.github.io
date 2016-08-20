

plotAllRoutes <- function(code="LHR") {
  segments <- summarizeSegments()
  segments <- segments[to==code]
  plotSegments(segments) + ggtitle(paste0("Flights from ", code))
}

plotSegments <- function(segments, ...) {
  airport_data <- data.table(read.csv("/host/files/airports.csv", header = FALSE))[, list(code=V5, name=V3, country=V4, lat=V7, lng=V8)]
  g <- graph.data.frame(segments)
  library(intergraph)
  n<-asNetwork(g)
  setkey(airport_data, code)
  n %v% "lat" <- airport_data[network.vertex.names(n)]$lat
  n %v% "lon" <- airport_data[network.vertex.names(n)]$lng
  library(maps)
  world <- fortify(map("world", plot = FALSE, fill = TRUE))
  world <- ggplot(world, aes(x = long, y = lat)) +
    geom_polygon(aes(group = group), color = "grey65",
                 fill = "#f9f9f9", size = 0.2)
  ggnetworkmap(world, n, size=1, great.circles=TRUE, segment.color="steelblue", ...) 
}