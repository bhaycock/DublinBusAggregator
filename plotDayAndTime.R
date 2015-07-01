# Plot Bus Stops
# allows user to confirm that their copy of R can read their mySQL database and
# carries out stop-centric basic statistics: it returns the average time a bus on a particular 
# route is at the selected stop for the time period and date period selected.

# Usage: Rscript plotDayAndTime.r [StopID] [dayrangeStart] [dayRangeEnd] [HourStart] [HourEnd]

# Barry Haycock
# 2015_05_08


# Plot Bus Stops
# Uncomment line below if there's an issue getting mySQL to work
#install.packages("RMySQL", repos = "http://cran.us.r-project.org")
library(RMySQL)

if (mysqlHasDefault()) {
  con <- dbConnect(RMySQL::MySQL(), dbname = "test")
  summary(con)
#  dbGetInfo(con)
#  dbListResults(con)
#  dbListTables(con)
  #dbDisconnect(con)
}
arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) != 5) {
  print("")
  print("")
  print("Usage is Rscript plotDayAndTime.r [StopID] [dayrangeStart] [dayRangeEnd] [HourStart] [HourEnd]")
  quit()
}
stopID <- as.character(arguments[1])
firstday <- arguments[2]
lastday <- arguments[3]
firsthour <- arguments[4]
lasthour <- arguments[5]
# Construct an SQL query based on the input arguments
query <- paste("SELECT LineID, AVG(AvgTimeAtStop) FROM Aggregated WHERE StopID = ", stopID, " AND DayOfWeek >=",  firstday, " AND DayOfWeek <=", lastday, "  AND HourOfDay >=", firsthour, " AND HourOfDay <=", lasthour , " GROUP BY LineID")

print(query)
Test <- dbSendQuery(con, query)
check <- dbFetch(Test, n = dbGetRowCount(Test))
#print(check)
df <-data.frame(check)
print(df)
barplot(df$LineID, df$AVG.AvgTimeAtStop)

plottitle <-  paste("Averaged time of bus at stop # ", stopID)
png('./plot.png')
barplot(names.arg = as.character(df$LineID), df$AVG.AvgTimeAtStop, xlab = "Route Number", ylab = "Average wait time for period", main = plottitle)
dev.off()
dbDisconnect(con)
