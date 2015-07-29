fetchSmapInc <- function(name,smapURL,gran,start,end){

final <- data.frame()

curDate <- as.Date(start)

numDays <- (as.Date(end) - as.Date(start)) + 1

for(i in 1:numDays){
startFetch <- paste(curDate,"00:00:00")
endFetch <- paste(curDate,"23:59:59")

data <- try({fetchData(name,type="smap",gran=gran,startFetch,endFetch,smapURL=smapURL)})
if(class(data) == "try-error") {
  curDate <- curDate+1
  next
}
final <- rbind(final,data)

curDate <- curDate+1
}

return(final)
}