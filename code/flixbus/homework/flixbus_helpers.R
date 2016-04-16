
library(data.table)
library(rgdal)
library(sp)
library(raster)
getFile <- function(redo=FALSE, subset=FALSE, n=1e6) {
  file <- "yellow_tripdata_2015-06.csv"
  if(subset) file <- paste0("yellow_tripdata_2015-06_", n, ".csv")
  
  if(file.exists(file) && !redo)
    return(data.table(read.csv(file)))
  
  cab_dat <- data.table(read.csv("yellow_tripdata_2015-06.csv"))
  if(subset) {
    cab_dat <- cab_dat[sample(1:nrow(cab_dat), n)]
    write.csv(cab_dat, file)
  }
  cab_dat
}


prepData <- function(points) {
  # filter out bad data
  points[, tip_pct := tip_amount/(total_amount-tip_amount)]
  points <- points[pickup_longitude > -75]
  points <- points[pickup_longitude < -73]
  points <- points[pickup_latitude > 40]
  points <- points[pickup_latitude < 41]
  points <- points[fare_amount > 1]
  points <- points[tip_pct <= 1]
}


addGroup <- function(points) {
  points[, tip_pct := round(tip_amount/(total_amount-tip_amount), 2)]
  points[, zero_tip := tip_amount==0]
  points[, card_preset := tip_pct %in% c(0.20, 0.25, 0.30)]
  points
}


getShapes <- function() {
  shapes<-readOGR("nynta_15c/", "nynta")
  spTransform(shapes,CRS("+proj=longlat +datum=WGS84")) 
}

joinPointsToShapes <- function(shapes=getShapes(), points) {
  points_orig <- copy(points)
  coordinates(points) <- ~ pickup_longitude + pickup_latitude
  projection(points) <- CRS("+proj=longlat +datum=WGS84")
  shapes <- spTransform(shapes, CRS(proj4string(points)))
  x<-over(points, shapes)
  data.table(cbind(points_orig,x))
}

