####################################
### This R code models
### chiller leaving water temperature LWT
### based on outside temperature, indoor temperature
### and time of the day
### using linear regression and support vector regression
####################################

library("zoo")
library(e1071)

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

data$ch1power <- na.approx(data$ch1power)
data$ch2power <- na.approx(data$ch2power)

### Set LWT 0 for the time when chiller is OFF

for(i in 1:nrow(data)){
  if(data$ch1power[i]<1){
    data$ch1lwt[i]=0
  }
  if(data$ch2power[i]<1){
    data$ch2lwt[i]=0
  }
}


### Find the CH-LWT of the chiller that is currently running
chlwt <- array()
for(i in 1:nrow(data)){
  chlwt[i] <- max(data$ch1lwt[i],data$ch2lwt[i])
}

chON <- bitwOr(data$ch1power,data$ch2power)
data <- cbind(data,chON)
data <- cbind(data,chlwt)


### Keep only required columns
data <- data[,c("time","indoorTemp","tempC","chON","chlwt")]


### Find TOD value
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

finalData <- dailyData[[1]]
for(i in 2:length(dailyData)){
  finalData <- rbind(finalData,dailyData[[i]])
}


### Divide the data into Train/Test Set
### Training data - 75%
### Test Data - 25%
smp_size <- floor(0.75 * nrow(finalData))

## set the seed to make your partition reproductible
set.seed(123)
train_ind <- sample(seq_len(nrow(finalData)), size = smp_size)

train <- finalData[train_ind, ]
test <- finalData[-train_ind, ]


### Remove time stamps
train <- train[,-c(1)]
test <- test[,-c(1)]

train <- na.omit(train)
test <- na.omit(test)


### Remove chlwt from test data for prediction
chlwt <- test$chlwt
test <- test[,c("indoorTemp","tempC","chON","TOD","onDur")]



### Model using linear regression
lin <- lm(chlwt~indoorTemp+tempC+TOD+onDur,train)
predicted <- predict(lin,test)
SMAPEper(chlwt,predicted)

plot(chlwt, main=paste("Linear Model"),sub=paste("SMAPE=",SMAPEper(chlwt,predicted)),xlab = "Observation")
points(predicted,col="red")


### Model using Support Vector Regression
svmodel <- svm(chlwt~indoorTemp+tempC+TOD+onDur,train)
predictedSVM <- predict(svmodel, test)
SMAPEper(chlwt,predictedSVM)


plot(chlwt, main=paste("SVR Model"),sub=paste("SMAPE=",SMAPEper(chlwt,predictedSVM)),xlab = "Observation")
points(predictedSVM,col="red")


#######################################
### Find the optimal parameters for SVR
### Attention !!!
### Very time consuming
#######################################

# tuneResult <- tune(svm, onDur~fl2mtech+tempC+TOD, data=train,
#                    ranges = list(epsilon = seq(0,1,0.25), cost = 2^(seq(2,8,2)))
# )
# 
# tunedModel <- tuneResult$best.model
# tunedModelY <- predict(tunedModel, test)
# SMAPEper(onDur,tunedModelY)
# rmse(onDur-tunedModelY)