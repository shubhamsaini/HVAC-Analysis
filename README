# HVAC Data Analysis

Data used:

1. Chiller Power Information

2. Indoor Temperature Data

3. Outside weather information

4. Chiller Leaving Water Temperature

5. Occupancy Data (if available)

The following files are used for analysis primarily. Other files are helper files and need not be changed.

- fetchData.R

- find-optimal-ON-time-EMPIRICAL.R

- find-optimal-ON-time-MODELING.R

- LWT-analysis.R

### fetchData.R

Fetch data between the specified time values. Return type is a data.frame with first column as time-stamps and second column as observed values. This file fetches data from:

1. file stored locally

2. sMap archiver

3. sMap archiver (data for each day incrementally)

Example usage:

`chiller1power <- fetchData(filename,type="file","2014-03-01","2015-06-20",gran="15 min")`

Refer to the file for parameter information and usage.

### find-optimal-ON-time-EMPIRICAL.R

This file finds optimal chiller ON time based on historical indoor temperature data and outside weather. Final result is a look up table each row tells the duration for which chiller must be switched on to achieve desired **setTemp** for some outdoor temperature.

Overview of the process:

- Load all relevant data into a data frame

- Infer chiller ON/Off from power values

- Add a column for Time of the Day value

- Filter out rows when chillers were off and non-working hours

- Split data into days

- For each day, for each row, find the duration for which chiller has been running

- For each day, find the time taken to reach **setTemp** degrees indoor temp

- Construct look-up table: outside temperature vs. time taken to reach setTemp

### find-optimal-ON-time-MODELING.R

This R Code finds optimal ON time based on historical indoor temperature data and outside weather. It models the data using linear regression and support vector regression. It also calculates potential savings in the historical data based on the generated models.

Overview of the process:

- Load all relevant data into a data frame

- Infer chiller ON/Off from power values

- Add a column for Time of the Day value

- Filter out rows when chillers were off and non-working hours

- Split data into days

- For each day, for each row, find the duration for which chiller has been running

- Train the relevant model on the resultant data.frame

- For time X (eg. 9:00 AM), for all days find the time duration to reach 25C based on the model. Compare this time with actual time the chiller has been running for and the differnce is potential savings.

### LWT-analysis.R

This R code models chiller leaving water temperature LWT based on outside temperature, indoor temperature and time of the day using linear regression and support vector regression.

### weather-interpolate.R

Data from weather underground is half-hourly. This code interpolates the values and increases the resolution of weather data by 2x.

For eg: if time values are 01:00:00, 02:00:00 The new data frame will have time values 01:00:00, 01:30:00, 02:00:00

