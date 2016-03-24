

# scrape list of bus stops from the flixbus website

library(rvest)
library(magrittr)
library(plyr)
library(data.table)
library(geosphere)

setwd("/Users/paul.teehan/pteehan.github.io/code/flixbus/")

# pull out the address from the bus stop page
getAddress <- function(url)  {
  tryCatch({
  read_html(url) %>% 
    html_nodes(".even p") %>% 
    gsub("<.*?>", "", .) %>% 
    gsub("\n", ", ", .) }, 
  error=function(e) {
    warning(paste(e))
    url
  })
}

# get addresses for all the bus stops 
writeAddresses <- function(reload=FALSE)  {
  if(file.exists("addresses.txt") && !reload)
    return(readLines("addresses.txt"))
  flixbus_home <- read_html("https://www.flixbus.com/bus-schedule-bus-stop")
  flixbus_home %>% 
    html_nodes(".busCityHub") %>% 
    html_nodes("a")  %>% 
    html_attr("href") %>%
    llply(getAddress, .progress="text") %>%
    unlist %>%
    writeLines("addresses.txt")
}

loadCities <- function(reload=FALSE) {
  if(!file.exists("world_cities.csv") && !reload)
    return(data.table(read.csv("world_cities.csv")))
  write.csv(content(GET("http://simplemaps.com/resources/files/world/world_cities.csv")), "world_cities.csv")
}

# get latitude and longitude of each bus stop using google maps geocoding
mapBusStops <- function(reload=FALSE) {
  if(file.exists("busstops.csv") && !reload)
    return(read.csv("busstops.csv"))
  addresses <- writeAddresses(reload)
  # correct addresses - remove extra lines about platform etc.
  addresses <- laply(addresses, function(i) {
    a <- strsplit(i, ",")[[1]]
    paste((a[c(1,2,length(a))]), collapse=", ")
  })
  busStops <- ldply(addresses, .progress="text", .fun=function(i) {
    x<-as.data.frame(getLatLong(i))
    x$address <- i
    x
    })
  write.csv(busStops, "busstops.csv")
}

# call google maps API to get lat long for one address
getLatLong <- function(address) {
  Sys.sleep(0.1) # rate limited to 10 / second
  api_key<-readLines("google_maps_api_key.txt")
  address <- gsub(" ", "+", address)
  url<-paste0("https://maps.googleapis.com/maps/api/geocode/json?address=", address, "&key=", api_key)
  geocode <- GET(url)
  geocode<-content(geocode)
  if(length(geocode$results)==0) return(list(lat=NA, lng=NA))
  geocode$results[[1]]$geometry$location
}

# find the minimum distance from each city to a flixbus stop
getDistances <- function(reload=FALSE) {
  if(file.exists("cities_with_distance.csv") && !reload)
    return(read.csv("cities_with_distance.csv"))
  bus_stops <- na.omit(mapBusStops(reload))
  
  cities <- na.omit(loadCities(reload))
  
  getDistance <-function(city, bus_stop) {
    tryCatch(distm(c(city$lat, city$lng), c(bus_stop$lat, bus_stop$lng)), error=function(e) NA)
  }
  city <- cities[100]
  getMinDistance <- function(city) 
    min(laply(1:nrow(bus_stops), function(i) getDistance(city, bus_stops[i,])), na.rm=TRUE)
  cities$min_distance <- laply(1:nrow(cities), .progress="text", .fun=function(i) {
    tryCatch(getMinDistance(cities[i,]), 
             error=function(e) {
               warning(e)
               NA
             })})
  write.csv(cities, "cities_with_distance.csv")
}

# find cities that are between 50km and 300km from a bus stop and rank by distance 
scoreCities <- function(n, reload=FALSE) {
  cities <- data.table(getDistances(reload))
  result <- cities[min_distance > 50000 & min_distance < 300000][order(-pop)][1:n]
  result[, distance_to_flixbus_km := ceiling(min_distance/1000)]
  result[, population := ceiling(pop/1000) * 1000]
  result <- result[,list(city, country, population, distance_to_flixbus_km, lat, lng)]
  result
}

makeMap <- function(reload=FALSE) {
  bus_stops <- na.omit(mapBusStops(reload))
  result <- scoreCities(n=30)
  
  library(rworldmap)
  newmap <- getMap(resolution = "low")
  plot(newmap, xlim = c(-10, 40), ylim = c(40, 60), asp = 1)
  points(bus_stops$lng, bus_stops$lat, col="black", bg="green", pch=21)
  points(result$lng, result$lat, col="black",  bg="purple", pch=21)
}


