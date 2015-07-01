# Creates tables which include all joins required for user to analyse data. Reads
# in the stops data from google, and the screen scraped data.
# in the project write-up, the joins are carried out programatically in R and in 
# Tableau with all data being read directly from mySQL, however, joins are also
# carried out in mySQL for completeness and to aid an interested user to create their
# own analyses.

# Barry Haycock
# 2015_05_04


CREATE TABLE stopsTxt (stopID INT, stopName VARCHAR(200), stopCode INT, stopLat FLOAT, stopLong FLOAT);

LOAD DATA LOCAL INFILE "/Users/hduser/Documents/PGDA/stops.txt" INTO TABLE stopsTxt FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

CREATE TABLE busRoutes (stopOrderNumber INT, stopID INT, address VARCHAR(200), location VARCHAR(200), routeNumber INT, direction VARCHAR(200));

LOAD DATA LOCAL INFILE "/Users/hduser/Documents/PGDA/screenScrapedBusRoutes.csv" INTO TABLE busRoutes FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

SHOW COLUMNS FROM Aggregated;
SHOW COLUMNS FROM stopsTxt;
SHOW COLUMNS FROM busRoutes;

CREATE TABLE readyToPlot AS SELECT Aggregated.LineID AS LineID, busRoutes.stopOrderNumber AS StopOrderNumber, Aggregated.StopID AS StopID, busRoutes.address AS Address, busRoutes.location AS Location, busRoutes.direction AS Direction, stopsTxt.stopLong AS StopLong, stopsTxt.stopLat AS StopLat, Aggregated.DayOfWeek AS DayOfWeek, Aggregated.HourOfDay AS HourOfDay, Aggregated.AvgTimeAtStop AS AvgTimeAtStop FROM Aggregated, stopsTxt, busRoutes WHERE Aggregated.StopID = stopsTxt.stopCode AND Aggregated.StopID = busRoutes.stopID AND Aggregated.LineID = busRoutes.routeNumber;

CREATE TABLE Days (dayNum INT, dayName VARCHAR(200)); #Handy to have on call
INSERT INTO Days VALUES (7, "Saturday");
INSERT INTO Days VALUES (6, "Friday");
INSERT INTO Days VALUES (5, "Thursday");
INSERT INTO Days VALUES (4, "Wednesday");
INSERT INTO Days VALUES (3, "Tuesday");
INSERT INTO Days VALUES (2, "Monday");
INSERT INTO Days VALUES (1, "Sunday");

