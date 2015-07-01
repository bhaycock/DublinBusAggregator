# Reads in the "JanData.csv" file produced by concatenation of all the files from 
# the dublin bus January 2013 daily files to mySQL. Generates a "readyForHive" table which could be used as the staging area to pass the tables into HIVE for aggregation, but this sql script instead concatenates on the local system in MySQL, producing the "enRouteTemp" table.

#Barry Haycock
# 2015_05_05

USE Test;
SHOW TABLES;
CREATE TEMPORARY TABLE IF NOT EXISTS testJanData ( Timestamp BIGINT, LineID INT, Direction INT, JourneyPatternID INT, TimeFrame VARCHAR(200), VehicleJourneyID INT, Operator VARCHAR(200), Congestion INT, Longditude FLOAT, Lat FLOAT, Delay INT, BlockID INT, VehicleID INT, StopID INT, AtStop INT);

LOAD DATA LOCAL INFILE "./JanData.csv" INTO TABLE testJanData COLUMNS TERMINATED BY ',' LINES TERMINATED BY '\n';

CREATE TEMPORARY TABLE IF NOT EXISTS readyForHIVE AS SELECT Timestamp, DATE_ADD('1970-01-01 12:00:00', INTERVAL (TimeStamp/1000000) SECOND) AS Date_Time, DayOfWeek(DATE_ADD('1970-01-01 12:00:00', INTERVAL (TimeStamp/1000000) SECOND)) As WeekDay, HOUR(DATE_ADD('1970-01-01 12:00:00', INTERVAL (TimeStamp/1000000) SECOND)) AS HourOfDay, LineID, Direction, journeyPatternID, TimeFrame, VehicleJourneyID, Operator, Congestion, Delay, BlockID, VehicleID, StopID, AtStop FROM testJanData;

SHOW COLUMNS FROM readyForHIVE;

CREATE TABLE enRouteTemp AS SELECT Timestamp, WeekDay, HourOfDay, StopID, BlockID, JourneyPatternID, LineID, Direction, TimeFrame, VehicleJourneyID, Operator, Congestion, VehicleID, MIN(timestamp) AS ArriveStamp, MAX(timestamp) - MIN(timestamp) AS TimeAtStop FROM readyForHIVE GROUP BY LineID, VehicleID, VehicleJourneyID, StopID, JourneyPatternID, TimeFrame, Direction ORDER BY timestamp; # This can't be a temprorary table if I wanna double-ref.






