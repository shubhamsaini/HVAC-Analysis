### This file fetches data from
### 1) File
### type="file"
### 2) Smap archiver (all data at once)
### type="smap"
### 3) Smap archiver (data for each day incrementally) 
### type="smapInc"


### Other Parameters:
### name: file name or smap archiver UUID
### gran: granularity of the data in minutes
### start: start date/time
### end: end date/time
### smapURL: URL of archiver - incase of type="smap" or type="smapINC"


### Example Usage:
### chiller1power <- fetchData("f6a7779b-1f11-5e27-9a8c-86f2a43b3916",type="smapInc",gran="30 sec","2014-03-01","2015-06-18",smapURL="http://energy.iiitd.edu.in:9106")

### floor2phdtemp <- fetchData("ab22036d-6329-5cae-bbbf-4995f5ecc8c0",type="smap",gran="15 min","2014-07-01 00:00:00","2015-05-20 23:59:59",smapURL="http://energy.iiitd.edu.in:9206")

fetchData <- function(name,type="file",gran="15 min",start,end,smapURL=NULL){
  
  source("fetchDataFile.R")
  source("fetchDataSmap.R")
  source("fetchSmapInc.R")
  
  if(type=="file"){
    data <- fetchDataFile(name,gran,start,end)
  } else if(type=="smap"){
      data <- fetchDataSmap(name,smapURL,gran,start,end)
  } else if(type=="smapInc"){
    data <- fetchSmapInc(name,smapURL,gran,start,end)
  } else (paste("Invalid Type"))
  
  return(data)
}