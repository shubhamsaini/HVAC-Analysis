###################################
### This R Code finds optimal ON time
### based on historical indoor temperature
### data and outside weather
###
### Final result is a look up table
### each row tells the duration for which chiller
### must be switched on to achieve desired 'setTemp'
### for some outdoor temperature
####################################


source("metrics.R") #Some accuracy metrics


### standard template to load the relevant data
### change as per requirement
source("prepare-data.R")

### Infer Chiller ON/OFF based on power consumption
### 0=Off, 1=On
threshold <- 50000
data$ch1power[data$ch1power<threshold] <- 0
data$ch1power[data$ch1power>threshold] <- 1
data$ch2power[data$ch2power<threshold] <- 0
data$ch2power[data$ch2power>threshold] <- 1


### Incase of multiple chillers,
### do OR operation to find if EITHER chiller is ON
chON <- bitwOr(data$ch1power,data$ch2power)
data <- cbind(data,chON)
data <- data[,-c(3,4)]

### Time of the Day (TOD)
### For Eg: 6:45 PM = 18.75
### Useful for regression
data$time <- as.POSIXct(data$time)
hour <- format(data$time,"%H")
min <- as.integer(format(data$time,"%M"))
min <- (min/60)*100
TOD <- paste(hour,min,sep = ".")
TOD <- as.numeric(TOD)
data <- cbind(data,TOD)



### Filter out data where Chiller is OFF
onData <- data[data$chON==1,]
onData$time <- as.character(onData$time)
onData$time <- as.POSIXct(onData$time,tz="UTC")

### Keep data for working hours only
onData <- onData[format(onData$time,"%H:%M:%S")<"19:00:00",]
onData <- onData[format(onData$time,"%H:%M:%S")>"04:00:00",]

### ###Keep only time, indoor temp, outdoor temp, and TOD
onData <- onData[,c("time","indoorTemp","tempC","TOD")]

### Keep only rows with valid indoor Temp value
onData <- onData[!is.na(onData$indoorTemp),]

onData$tempC <- na.approx(onData$tempC)

### Split data into list of individual days
dailyData <- split(onData,as.Date(onData$time))

### For each day, find the time for which Chiller has been running

for(ind in 1:length(dailyData)){
  
  temp <- dailyData[[ind]]
  
  onDur <- array()
  startTime <- temp$time[1]
  for(i in 1:nrow(temp)){
    onDur[i] <- as.numeric(temp$time[i] - startTime)
    if(onDur[i]<15){
      onDur[i] <- onDur[i]*60
    }
  }
  
  dailyData[[ind]] <- cbind(dailyData[[ind]],onDur)
  
}


### For each day, find the time taken to reach X deg indoor temp
#############
setTemp <- 25
#############

lookUp <- data.frame()

for(ind in 1:length(dailyData)){
  for(timeLoop in 1:nrow(dailyData[[ind]])){
    if(dailyData[[ind]]$indoorTemp[timeLoop] <= setTemp){
      lookUp[ind,1] <- dailyData[[ind]]$TOD[timeLoop]
      lookUp[ind,2] <- dailyData[[ind]]$tempC[timeLoop]
      lookUp[ind,3] <- dailyData[[ind]]$onDur[timeLoop]
      break;
    }
  }  
}

lookUp <- na.omit(lookUp)
lookUp$V2 <- round(lookUp$V2,0)

result <- aggregate(V3~V2,lookUp,mean)
plot(result,type='l',xlab = "Outdoor Temp","Time taken to achieve Setpoint (min)")
