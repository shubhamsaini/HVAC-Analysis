#####
# Code to increase the resolution of
# weather data by 2
# 
# For eg: if time values are 01:00:00, 02:00:00
# The new data frame will have time values 01:00:00, 01:30:00, 02:00:00
###

library(zoo)


### Read weather data from file
weather <- read.csv("data/weather.csv")

### Some pre-processing
names(weather) <- c("Time","TemperatureC")
weather$Time <- as.POSIXct(weather$Time)


### Create a temperory data frame to hold new averaged values
temp <- data.frame(Time1=weather$Time[1:(nrow(weather)-1)],Time2=weather$Time[2:nrow(weather)],Temp1=weather$TemperatureC[1:(nrow(weather)-1)],Temp2=weather$TemperatureC[2:nrow(weather)])

timeVal <- temp$Time1 + ((temp$Time2-temp$Time1)/2)
tempVal <- (temp$Temp1 + temp$Temp2)/2

temp <- data.frame(Time=timeVal,TemperatureC=tempVal)


### Combine the new values into weather data frame and remove any unused variables
names(temp) <- names(weather)
temp$Time <- strptime(temp$Time,"%Y-%m-%d %H:%M:%S")
weather <- rbind(weather,temp)
rm(temp,timeVal,tempVal)


### Sort the weather data frame by time values
weather <- weather[order(weather$Time),]
row.names(weather) <- 1:nrow(weather)


### Approximate any NA values
weather$TemperatureC <- na.approx(weather$TemperatureC)
