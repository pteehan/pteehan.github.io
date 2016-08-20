library(plyr)
library(data.table)
convertRoute <- function(r, max_hops=7) {
  r <- trimws(r)
  # first convert to a matrix of strings
  strings <- sapply(seq(from=1, to=max_hops*3, by=3), function(i) substr(r, i, i+2))
  
  # then rearrange the columns into rows
  # label as a connecting flight if the next column to the right is not empty
  out<-ldply(1:(max_hops-2), function(i) {
    data.frame(from=strings[,i], to=strings[,i+1], isConnection=strings[,i+2]!="", route=r)
  })
  out <- out[out$from !="",]
  out <- out[out$to !="",]
  data.table(out)
}

# summarize segments by number of passengers and conencting passengers
summarizeSegments <- function(reload=FALSE) {
  cached_file <- "/host/files/segments_summary.RDS"
  if(reload || !file.exists(cached_file)) {
    segments <- getSegments(reload)
    out<-segments[, list(passengers=nrow(.SD), connecting_passengers=sum(isConnection)), by=list(from, to)]
    saveRDS(out, cached_file)
    out
  } else {
    readRDS(cached_file)
  }
}