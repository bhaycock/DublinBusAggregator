# Script assumes you have paths set to all programs.
# If you need this its: sudo mount -t vboxsf PGDA ~/PGDA 
# Mounts host shared directory PGDA to ~/PGDA
# This script serves as a step-by-step of implementation and has not been fully
# tested from start to finish, however it represents the steps taken from download
# through loading to procesing to analysis to results and therefore is included as an
# example of programming. Also, there's no reason why it wont work (on my VM anyway)

# Barry Haycock 
# 2015_05_09

read -p "Press enter to download files"
wget http://www.dublinked.ie/datastore/server/FileServerWeb/FileChecker?metadataUUID=4bd905ab2fce451ca4f97220dc78e745&filename=siri.zip
wget http://www.dublinked.ie/datastore/server/FileServerWeb/FileChecker?metadataUUID=6ac092f3e34c4764b78ecfaf8198f482&filename=google_transit_dublinbus_P20130315-1546.zip
wget www.barryhaycock.com/screenScrapedBusRoutes.csv

#Alternate Download links below, uncomment to use:
#wget www.barryhaycock.com/siri.zip
#wget www.barryhaycock.com/google_transit_dublinbus_P20130315-1546.zip


read -p "Press enter to unzip files" 
unzip google_transit_dublinbus_P20130315-1546.zip
cp google_transit_dublinbus_P20130315-1546/stops.txt .

unzip siri.zip -d ./BusData/
cd BusData
for a in `ls` ; do
  gunzip $a 
  done


read -p "Press enter to concatonate GPS .csv files"
for a in `ls *.csv` ; do 
  paste $a >> JanData
  rm $a
  done

mv JanData JanData.csv

read -p "Press enter to Read in to MySQL"
mysql  --local_infile=1 -vvv < readInBusses.sql #test.sql
# Above can be replaced with the HIVE script

#Uncomment following lines below to use HIVE for this step as oppose to mySQL, comment out line above.
#read -p "Press enter to Read in to MySQL"
#mysql  --local_infile=1 -vvv < readInBusses_only_to_ReadyToHive.sql
#read -p "Press enter to read ReadyForHive into hive"
#bin/sqoop import --connect jdbc:mysql://127.0.0.1/Test --username root --password Passw0rd --table ReadyForHive --split-by LineID --hive-table readyforhive
#read -p "Press enter to call hive concatonation"
#hive createEnRouteTemp.hive
#read -p "Press enter to return data to mySQL"
#mysql -vvv < createEnRouteTable.sql #Create Target tables in mySQL
#sqoop export --connect jdbc:mysql://127.0.0.1/Proj --username root --password Passw0rd --table enRouteTemp --staging-table enRouteTemp_stg --clear-staging-table -m 1 --export-dir /user/hduser/enRouteTemp_sample --hive-table readyforhive

bin/sqoop import --connect jdbc:mysql://127.0.0.1/Test --username root --table enRouteTemp --password Passw0rd -m 1

java AggregateTimeAtStop.jar /user/hduser/enRouteTemp/part-m-00000 output

#Prepare for return of data
mysql -vvv < createAggregatedTable.sql
#Sqoop back my data
sqoop export --connect jdbc:mysql://127.0.0.1/Proj --username root --password Passw0rd --table Aggregated --staging-table Aggregated_STG --clear-staging-table -m 1 --export-dir /user/hduser/output
#Add stop location and order of bus stops in each and every route:
mysql --local_infile=1 -vvv < createReadyToPlot.sql


# Final statements:
echo "" ; echo ""
echo "Looks like this demo script ran... which implies your computer is set up exactly as the demo VM"
echo "Open in Tableau and connect to plot, or open the Tableau.twb file in Tableau"
echo "" 
echo "If Tableau is not installed, use R"
echo "Try calling >Rscript [StopID] [startDayNum] [endDayNum] [8] [9]"
echo "and opening the created plot.png and read the output."
echo "" ; echo ""
echo "Press [Enter] key to call Rscript plotDayAndTime.R 1332 2 6 8 9"
echo "    (outputs results and plots the details for Stop # 1332, "
read -p "           from Monday (day2) to Friday beteen 8am and 9am)"

# Plot something 
Rscript plotDayAndTime.R 1332 2 6 8 9

# Tell user about the plots:

# Run some analysis in R:

# Tell user where that is:



