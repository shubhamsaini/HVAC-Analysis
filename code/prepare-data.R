#######################################
### R code to fetch HVAC data
### and combine them into a data frame
#######################################

source("fetchData.R")

### Chiller Power consumption
chiller1power <- fetchData("chiller1power.csv",type="file","2014-03-01","2015-06-20",gran="15 min")
names(chiller1power)[2] <- "ch1power"
chiller2power <- fetchData("chiller2power.csv",type="file","2014-03-01","2015-06-20",gran="15 min")
names(chiller2power)[2] <- "ch2power"

### Chiller Leaving Water Temperature LWT
chiller1lwt <- fetchData("chiller1lwt.csv",type="file","2014-03-01","2015-06-20",gran="15 min")
names(chiller1lwt)[2] <- "ch1lwt"
chiller2lwt <- fetchData("chiller2lwt.csv",type="file","2014-03-01","2015-06-20",gran="15 min")
names(chiller2lwt)[2] <- "ch2lwt"

### Indoor Room Temperature
indoorTemp <- fetchData("fl2mtech.csv",type="file","2014-03-01","2015-06-20",gran="15 min")
names(indoorTemp)[2] <- "indoorTemp"

### Occupancy Data
### Commented out - may not always be available
#occ <- read.csv("data/occ.csv")

### Outside weather temperature
weather <- read.csv("../data/weather.csv")
weather$time <- as.POSIXct(weather$time)

data <- merge(indoorTemp,chiller1power)
data <- merge(data,chiller2power,all.x = TRUE)
data <- merge(data,chiller1lwt,all.x = TRUE)
data <- merge(data,chiller2lwt,all.x = TRUE)
#data <- merge(data,occ,all.x = TRUE) #uncomment if occupancy data available
data <- merge(data,weather,all.x = TRUE)
