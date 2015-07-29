fetchDataFile <- function(name,gran,start,end){
  fileLoc <- paste0("../data/",name)
  data <- read.csv(fileLoc)
  
  names(data)[1] <- "time"
  names(data)[2] <- "value"
  
  data$time <- as.POSIXct(data$time,origin="1970-01-01 0:0:0")
  arrHour <- aggregate(. ~ cut(data$time,gran),data[setdiff(names(data), "time")],mean)
  
  data <- arrHour
  names(data)[1] <- "time"
  names(data)[2] <- "value"
  
  data$time <- as.POSIXct(data$time,origin="1970-01-01 0:0:0")
  data <- data[data$time>=start,]
  data <- data[data$time<=end,]
  
  write.csv(data,file="fetchedData.csv",row.names=FALSE)
  return(data)
}