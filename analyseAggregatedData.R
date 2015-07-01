# analyseAggregatedDataR
# reads the Aggregated table from the mySQL database that represents the results of
# the MapReduce job and returns a decision tree to a file called DecisionTree.ps
# and outputs the results of Association Rule Mining to the terminal

# Barry Haycock
# 2015_05_08

# Uncomment line below if there's an issue getting mySQL to work
#install.packages("RMySQL", repos = "http://cran.us.r-project.org")
library(RMySQL)
library(arules)
library(rpart)

if (mysqlHasDefault()) {
  con <- dbConnect(RMySQL::MySQL(), dbname = "test")
  summary(con)
  dbGetInfo(con)
  dbListResults(con)
  dbListTables(con)
  #dbDisconnect(con)
}


Test <- dbSendQuery(con, "SELECT * FROM Aggregated")
dbGetRowCount(Test)
check <- dbFetch(Test, n= dbGetRowCount(Test)))
df <- data.frame(check)

# Convert the StopID to a string for processing.
df$StopIDString<- as.character(df$StopID)

NameThatDay <- function(daynum){
  # Function that returns the name of the day of the week, given the daynum
  # this is in lieu of joining with a table containing the same data.
  
  dayName <- ""
  if (daynum == 1){
    dayName = "Sunday"}
  else if (daynum == 2){
    dayName = "Monday"}
  else if (daynum == 3){
    dayName = "Tuesday"}
  else if (daynum == 4){
    dayName = "Wednesday"} 
  else if (daynum == 5){
    dayName = "Thursday"}
  else if (daynum == 6){
    dayName = "Friday"}
  else if (daynum == 7){
    dayName = "Saturday"}
  else{ return (NULL)}
  return(dayName)
} 

# Get dayname from daynum for all fields
df$dayname <- sapply(df$DayOfWeek, NameThatDay)

#Print out summary statistics of all data:
summary(df)

# Fit a decision Tree targetted on the average time at stops and using DayOf Week and hour of Day as the IVs
fit <- rpart(AvgTimeAtStopBins~ DayOfWeek + HourOfDay, method="class", data=df)
printcp(fit)
plotcp(fit)
summary(fit)

post(fit, file = "./DecisionTree.ps", title = "Classification Tree for BusTime")



# Association rules:
  # Choose the nominal variables in the data (includeing the binned waitTimes)
associateThis <- df[,c("AvgTimeAtStopBins", "LineID", "StopIDString", "dayname", "HourOfDay")
  # convert variables to factors for apriori
associateThis$LineID <- as.factor(associateThis$LineID)                     
associateThis$StopIDString <- as.factor(associateThis$StopIDString)
associateThis$HourOfDay <- as.factor(associateThis$HourOfDay)
associateThis$dayname <- as.factor(associateThis$dayname)                     

#Run the job
rules <- apriori(associateThis, parameter = list(minlen=2, supp=0.005, conf=0.25))
# PRint the rules to the STD Output.
inspect(rules) # 54 rules, some insight

#rules <- apriori(associateThis, parameter = list(minlen=2, supp=0.005, conf=0.3))
#inspect(rules) # 4 rules, just nothing in there
dbDisconnect(con)
                     
                     
                     ]
