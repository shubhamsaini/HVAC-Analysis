fetchDataSmap <- function(name,smapURL,gran,start,end){
  
  require(RSmap)
  as.Date <- base::as.Date
  posTime <- "%Y-%m-%d %H:%M:%S"
  dataframe <- list()
  
  RSmap(smapURL)
  oat <- list(name)
  
  start <- as.numeric(strptime(start, posTime))*1000
  end <- as.numeric(strptime(end, posTime))*1000
  
  data <- RSmap.data_uuid(oat, start, end)
  data <- data.frame(data[[1]]$time/1000,data[[1]]$value)
  data$data..1...time.1000 <- as.POSIXct(data$data..1...time.1000,origin="1970-01-01")
  
  names(data)[1] <- "time"
  names(data)[2] <- "value"
  
  data <- aggregate(. ~ cut(data$time,gran),data[setdiff(names(data), "time")],mean)
  
  names(data)[1] <- "time"
  names(data)[2] <- "value"
  data$time <- as.POSIXct(data$time,origin="1970-01-01 0:0:0")
  
  return(data)
  
}