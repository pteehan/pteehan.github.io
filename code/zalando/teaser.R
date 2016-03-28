

setwd("/Users/paul.teehan/pteehan.github.io/code/zalndo/")
library(dismo)
library(reshape2)
library(ggplot2)
library(geosphere)
library(plyr)
library(viridis)

makeGrid <- function(x_min, x_max, y_min, y_max, resolution=0.01) {
  x_range <- seq(x_min, x_max, by=resolution)
  y_range <- seq(y_min, y_max, by=resolution)
  points <- expand.grid(x_range, y_range)
  names(points) <- c("lng", "lat")
  points
}

# make grid for the region we're interested in
getFullGrid <- function(resolution=0.01) {
  x_min<-13.2
  x_max <- 13.6
  y_min <- 52.44
  y_max <- 52.56
  makeGrid(x_min, x_max, y_min, y_max, resolution)
}


getDistToSpree <- function(points) {
  # data provided online was saved in spree.csv
  spree <- read.csv('spree.csv', header=T)
  # use dist2Line to calculate distance to a piecewise line
  # the output of this seems to have a bug so we have to split/apply manually with laply
  points$spree_dist <- laply(1:nrow(points), function(i) {
    lat=points[i, 'lat']
    lng=points[i, 'lng']
    dist2Line(c(points[i, 'lng'], points[i, 'lat']), data.frame(spree$lng, spree$lat))[, 'distance']
  })
  points
}

getSpreeProbability <- function(points) {
  # convert distance to probability given normal distribution, assuming 95% = 2 stdev
  if(!"spree_dist" %in% names(points))
    points <- getDistToSpree(points)
  points$spree_prob <- dnorm(points$spree_dist, mean = 0, sd = 2730/2)
  points$spree_prob <- points$spree_prob / sum(points$spree_prob)  # scale so it sums to one
  points 
}

getDistToGate <- function(points) {
  # use distHaversine to calculate distance to great a point
  gate <-c(13.377689,52.516288)
  points$gate_dist <- distHaversine(points, gate)
  points
}

getGateParams <- function() {
  # we need to do some algebra here to get the distribution parameters
  mean <- 4700  # this is exp (mu + sigma^2/2)
  mode <- 3877 # this is exp (mu - sigma^2)
  # therefore sigma^2 = mu - ln(mode)
  # ln(mean) = mu + (mu - ln(mode))/2
  # ln(mean) = 3/2(mu) - ln(mode)/2
  # mu = (ln(mean) + ln(mode)/2)*2/3
  mu <- (log(mean) + log(mode)/2)*2/3
  sigma <- sqrt(mu - log(mode))
  # sanity check mode
  which.max(dlnorm(seq(0,10000,by=1), mu, sigma))
  # sanity check mean
  mean(rlnorm(100000, mu, sigma))
  c(mu=mu, sigma=sigma)
}

getGateProbability <- function(points){
  if(!"gate_dist" %in% names(points))
    points <- getDistToGate(points)
  params <- getGateParams()
  points$gate_prob <- dlnorm(points$gate_dist, params['mu'], params['sigma'])
  points$gate_prob <- points$gate_prob / sum(points$gate_prob)  # scale so it sums to one
  points
}

getSatelliteDist <- function(points) {
  # use dist2gc to calculate distance to great circle
  #52.590117,13.39915
  #52.437385,13.553989
  points$sat_dist <- abs(dist2gc(p1=c(13.39915, 52.590117), p2=c(13.553989, 52.437385), points,r = 6371000))
  points
}
getSatelliteProbability <- function(points) {
  if(!"sat_dist" %in% names(points))
    points <- getSatelliteDist(points)
  points$sat_prob <- dnorm(points$sat_dist, mean = 0, sd = 2400/2)
  points$sat_prob <- points$sat_prob / sum(points$sat_prob) # scale so it sums to one
  points
}

# build a grid and calculate probabilities for each point and geographic feature
# cache to a .csv file since this can take a while
# use lower-resolution for quicker results
getPoints <- function(resolution=0.01, reload=FALSE) {
  filename <- paste0("points_", resolution, ".csv")
  if(file.exists(filename) && !reload)
    return(read.csv(filename))
  points <- getFullGrid(resolution)
  points <- getGateProbability(points)
  points <- getSpreeProbability(points)
  points <- getSatelliteProbability(points)
  points$prob_overall <- points$gate_prob* points$spree_prob * points$sat_prob
  points$prob_overall <- points$prob_overall / sum(points$prob_overall)  # scale so it sums to one
  write.csv(points, filename)
  points
}

# convert a lat/long/data set to a raster image
toRaster <- function(points, col, scale=TRUE) {
  pts <- points[, c("lng", "lat", col)]
  if(scale) pts[[col]] <- pts[[col]]/max(pts[[col]]) * 0.8
  coordinates(pts) <- ~ lng + lat
  gridded(pts) <- TRUE
  new_raster <- raster(pts)
  # must set projection to match google map
  projection(new_raster) <- CRS("+proj=longlat +datum=WGS84")
  new_raster
}

# load a map of berlin and crop it to the region of interest
getBigBerlinMap <- function() {
  raster_spree <- toRaster(points, "spree_prob")
  n_map <- gmap(x=raster_spree, type = "terrain", lonlat=TRUE)
  crop(n_map, raster_spree)
}

# plot a raster layer against a map of berlin
# 'col' should be a column name in 'points' that has data
plotLayer <- function(bigBerlinMap, col, points) {
  layer <- toRaster(points, col)
  plot(bigBerlinMap)
  plot(layer, add=T, legend=F, alpha=layer, col=rev(viridis(100)))
  # alpha varies with data so the map is not obscured
  # viridis colour scheem works well for this
}

# plot a contour layer against a zoomed map of berlin
plotContours <- function(points) {
  # extent chosen from manual clicking
  e <-   extent(c(13.43666, 13.48904, 52.49128, 52.52658))
  n_map <- gmap(x=e, type = "terrain", lonlat=TRUE,zoom=14)
  crop(n_map, e)
  raster_all <- crop(toRaster(points, "prob_overall", scale=FALSE), e)
  plot(n_map)
  contour(raster_all, add=T, legend=F, drawlabels=FALSE, nlevels=25, lwd=1)
  points(13.456,52.511, pch=19) # max of points$prob_overall 
}

