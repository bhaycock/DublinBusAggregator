# DublinBusAggregator
Dublin Bus Data Aggregator. Visualisations are available at: http://tabsoft.co/1zNJhF3

This submission represents an example of a "Big Data"-like pipeline. In some ways it's a lottle (more than a little, but not really a lot!) convuluted.
GPS Data collected from the Dublin Bus transit network cataloguing the position of busses throughout the city of Dublin for the month of January is analysed using a variety of data mining techniques. This data represents the geographic position of every bus in Dublin for the entire operating period and therefore constitutes a massive data set, comprising 44M observations and totalling 4.5Gb in size.

MapReduce design patterns are applied to the raw data to aggregate the average time spent by busses at each stop per route number. The time at the stop is aggregated by averages to hourly granularity for an average day of the week. This kind of aggregation allows for ease of addressing specific time periods and days of the week.
Results are presented by data mining output and as an interactive dashboard.

For this project BASH scripting is used extensively, this was chosen as oppose to python because the BASH scripts can be run on virtually any Linux or Unix based computer, whereas python may not be installed or may not have the required libraries or access. For data storage, wget is used to gather data from original sources (a mirror is set up for this project), mySQL is used for data storage, for small-scale SQL-like queries and filtering, mySQL is also used over Hive. This is because HQL and SQL are very similar and SQL is faster for smaller queries especially when Hadoop is configured in a pseudo-distributed mode. Apaché Sqoop is used routinely to move data to the HDFS from mySQL and to return it to mySQL, finally both R and Tableau are used for final analysis. R is used because it can download required libraries from a script, including the one required for accessing a mySQL database, RmySQL. Tableau is used because it can directly access mySQL databases, once the MySQL Connector ODBC 5.3.pkg drivers are installed, and is an ideal platform to deliver a dashboard.

The pipeline, including downloading of the data files from dublinked.ie, is invoked by calling the runall.sh script in BASH. I *strongly* recommend that you consider that file a description of usage of the various functions in this set and not as a quick-start. 

The pipeline for data processing is as follows, in bullet-point pseudo-code form, all text in the square brackets represent the names of files containing code to carry out the function, the runall.script file carries out this pipeline in order on some setups and systems:



1. Programmatically download and prepare files for database [runall.script]
1.1. Use wget to download the dataset from dublinked.ie, the google transit data and the
screen-scraped bus routes file. These are currently hosted online.
1.2. Unzip the Dublin Bus GPS files
1.3. Vertically join all csv files from Dublinked.ie
2. Read the Dublin Bus GPS data into mySQL via command line. [readInBusses.sql]
2.1. 2.2.
Using a mySQL script to read in the csv file from 1.3:
Convert the timestamp in the data into a useable format
2.2.1. Dublinked supply the timestamp as Linux Time in microseconds (number of
microseconds since 01/01/1970 00:00).
2.2.2. Add a DayOfWeek column, representing what date the row corresponds
represents.
2.2.3. Add an HourOfDay column, representing the hour in 24 hour clock format, to assist
in aggregation later in the pipeline.
2.2.3.1. This is temporary table ReadyForHive.
2.2.4. ReadyForHive needs to be aggregated in one of two ways:
2.2.4.1.1. Upload to HIVE with: [createEnRouteTemp.hive]
2.2.4.1.2. Using mySQL [in readInBusses.sql, comment in runall.script]
2.2.4.2. Either way, table enRouteTemp is now in mySQL enRouteTemp contains:
(Timestamp, WeekDay, HourOfDay, StopID, BlockID, JourneyPatternID, LineID, Direction, TimeFrame, VehicleJourneyID, Operator, Congestion, VehicleID, MIN(timestamp) AS ArriveStamp, MAX(timestamp) - MIN(timestamp) AS TimeAtStop)
The Arrivestamp is the time the bus in this row arrives at a stop, the timeAtStop aggregation is only possible by aggregating over stopID, Group by Journey and Stop unique identifiers ( which is WeekDay, HourOfDay, StopID, BlockID, JourneyPatternID, LineID, Direction, TimeFrame, VehicleJourneyID, Operator, Congestion and VehicleID)
3. sqoop enRouteTemp to HDFS (not hive)
4. Perform MapReduce [AggregateTimeAtStop.jar or the source code] on enRouteTemp
4.1.1. Map Key: String of (LineID, StopID, DayOfWeek, HourOfDay) 4.1.2. Map Value: (TimeAtStop)
4.1.3. Reduce Key: String of (LineID, StopID, DayOfWeek, HourOfDay) 4.1.4. Reduce Value: Average(TimeAtStop) for the key combination
5. sqoop new table back to mySQL
6. Add in the data downloaded- location of stops and the order of bus stops.
6.1. [createReadyToPlot.sql] This isn’t used in calculations, as days and locations are added
programmatically, but it is included for completeness.
7. Carry out R-based predictive analytics [analyseAggregatedData.R]
7.1. Carry out a decision tree plot on the data targeted on the aggregated bus wait time
7.2. Carry out association rule mining targeted on the wait time
8. Plot the general results:
8.1. Two Methods:
8.1.1. Run Tableau, connect to mySQL (installation requires) database and create a plot.
[Tableau.twb]
8.1.1.1. This is available at: www. http://tabsoft.co/1zNJhF3
8.1.2. Call R script for basic plots.[Rscript plotDayAndTime.R X X X X]
Both Tableau and R can be called from command line at any tie to carry out further study of new data.
