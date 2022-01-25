SELECT * FROM bike_data;
SELECT * FROM stations ORDER BY ID ASC;
SELECT * FROM trips ORDER BY StationID ASC;
SELECT * FROM UsageByDay ORDER BY StationID ASC;
SELECT * FROM UsageByGender ORDER BY StationID ASC;
SELECT * FROM UsageByAge ORDER BY StationID ASC;
SELECT DayOfWeek, First_Station, Second_Station, MAX(Trips) FROM FrequentTrips WHERE DayOfWeek = 1;
SELECT DayOfWeek, First_Station, Second_Station, MAX(Trips) FROM FrequentTrips WHERE DayOfWeek = 2;
SELECT DayOfWeek, First_Station, Second_Station, MAX(Trips) FROM FrequentTrips WHERE DayOfWeek = 3;
SELECT DayOfWeek, First_Station, Second_Station, MAX(Trips) FROM FrequentTrips WHERE DayOfWeek = 4;
SELECT DayOfWeek, First_Station, Second_Station, MAX(Trips) FROM FrequentTrips WHERE DayOfWeek = 5;
SELECT DayOfWeek, First_Station, Second_Station, MAX(Trips) FROM FrequentTrips WHERE DayOfWeek = 6;
SELECT DayOfWeek, First_Station, Second_Station, MAX(Trips) FROM FrequentTrips WHERE DayOfWeek = 7;
SELECT start_station_name AS Vacant_Station
FROM bike_data
WHERE start_station_name NOT IN (SELECT start_station_name FROM bike_data GROUP BY start_station_name, end_station_name);

-- The imported data from the csv file contained bike_table
CREATE TABLE bike_data ( 
	trip_duraton INT,
    start_time VARCHAR(30),
    start_day DATE DEFAULT "0000-00-00",
    stop_time VARCHAR(30),
    stop_day DATE DEFAULT "0000-00-00",
    start_station_id INT,
    start_station_name VARCHAR(40),
    start_station_lattitude FLOAT,
    start_station_longitude FLOAT,
    end_station_id INT,
    end_station_name VARCHAR(40),
    end_station_lattitude FLOAT,
    end_station_longitude FLOAT,
	bike_id INT,
    usertype VARCHAR(20),
	birth_year VARCHAR(4),
    gender INT
);

-- I have altered parts of the table to make the data easier to use
ALTER TABLE bike_data MODIFY stop_day INTEGER;
UPDATE bike_data SET stop_day = DAYOFWEEK(stop_time);
UPDATE bike_data SET stop_time = STR_TO_DATE(stop_time, '%m/%d/%Y %T');
SELECT * FROM bike_data;

-- Table stations is created  
CREATE TABLE stations (
	ID INT,
    Name VARCHAR(40),
    Lattitude FLOAT,
    Longitude FLOAT,
    FOREIGN KEY (ID) REFERENCES bike_data(start_station_id)
);

INSERT INTO stations(ID, Name, Lattitude, Longitude)
SELECT DISTINCT start_station_id, start_station_name, 
				start_station_lattitude, start_station_longitude 
FROM bike_data;

SELECT * FROM stations ORDER BY ID ASC;
DROP TABLE stations;

-- create the talbe trips 
CREATE TABLE trips (
	StationID INT,
    MinTripDuration INT,
    MaxTripDuration INT,
    AvgTripDuration INT,
    NumberStartUsers INT,
    NumberReturnUsers INT,
    FOREIGN KEY (StationID) REFERENCES stations(ID)
);
-- finding the min, max and avg for each of the stationsID
INSERT INTO trips(StationID, MinTripDuration, MaxTripDuration, 
				  AvgTripDuration, NumberStartUsers, NumberReturnUsers)	
SELECT stations.ID, MIN(trip_duraton), MAX(trip_duraton), AVG(trip_duraton), 
		COUNT(CASE WHEN usertype = 'Customer' THEN 1 END), -- Counting when condition met
        COUNT(CASE WHEN usertype = 'Subscriber' THEN 1 END)
FROM bike_data
JOIN stations ON bike_data.start_station_id = stations.ID OR bike_data.end_station_id = stations.ID
WHERE stations.ID IN (SELECT ID FROM stations) GROUP BY stations.ID;

SELECT * FROM trips ORDER BY StationID ASC;
DROP TABLE trips;


-- The table UsageByDay is created
CREATE TABLE UsageByDay (
	StationID INT,
	NumberWeekdayStartUsers INT,
    NumberWeekdayReturnUsers INT,
    NumberWeekendStartUsers INT,
    NumberWeekendReturnUsers INT,
    FOREIGN KEY (StationID) REFERENCEs stations(ID)
);

-- Counting for the number of users depending on the day and the usertype
INSERT INTO UsageByDay(StationID, NumberWeekdayStartUsers, NumberWeekdayReturnUsers, 
						NumberWeekendStartUsers, NumberWeekendReturnUsers)
SELECT stations.ID, 
	   COUNT(CASE WHEN (start_day >= 2 AND start_day <= 6) AND usertype = 'Customer' THEN 1 END),
	   COUNT(CASE WHEN (start_day >= 2 AND start_day <= 6) AND usertype = 'Subscriber' THEN 1 END),
	   COUNT(CASE WHEN (start_day = 1 OR start_day = 7) AND usertype = 'Customer' THEN 1 END),
       COUNT(CASE WHEN (start_day = 1 OR start_day = 7) AND usertype = 'Subscriber' THEN 1 END)
FROM bike_data
JOIN stations ON bike_data.start_station_id = stations.ID OR bike_data.end_station_id = stations.ID
WHERE stations.ID IN (SELECT ID FROM stations) GROUP BY stations.ID;

SELECT * FROM UsageByDay ORDER BY StationID ASC;
DROP TABLE UsageByDay;


-- the table UsageByGender is created
CREATE TABLE UsageByGender (
	StationID INT,
    NumberStartMaleUsers INT,
    NumberStartFemaleUsers INT,
    NumberReturnMaleUsers INT,
    NUmberReturnFemaleUsers INT,
    FOREIGN KEY (StationID) REFERENCES stations(ID)
);

-- counting the number of users by checking the gender and usertype
INSERT INTO UsageByGender(StationID, NumberStartMaleUsers, NumberStartFemaleUsers, 
							NumberReturnMaleUsers, NumberReturnFemaleUsers)
SELECT stations.ID,
	   COUNT(CASE WHEN gender = 1 AND usertype = 'Customer' THEN 1 END),
       COUNT(CASE WHEN gender = 2 AND usertype = 'Customer' THEN 1 END),
       COUNT(CASE WHEN gender = 1 AND usertype = 'Subscriber' THEN 1 END),
       COUNT(CASE WHEN gender = 2 AND usertype = 'Subscriber' THEN 1 END)
FROM bike_data
JOIN stations ON bike_data.start_station_id = stations.ID OR bike_data.end_station_id = stations.ID
WHERE stations.ID IN (SELECT ID FROM stations) GROUP BY stations.ID;

SELECT * FROM UsageByGender ORDER BY StationID ASC;
DROP TABLE UsageByGender;


-- Creating the table UsageByAge
CREATE TABLE UsageByAge (
	StationID INT,
    NumberMaleUsersUnder18 INT,
    NumberMaleUsers18To40 INT,
    NumberMaleUsersOver40 INT,
    NumberFemaleUsersUnder18 INT,
    NumberFemaleUsers18To40 INT,
    NumberFemaleUsersOver40 INT,
    FOREIGN KEY (StationID) REFERENCES stations(ID)
);

-- We are using the birth year to find the age and checking usertype
INSERT INTO UsageByAge(StationID, NumberMaleUsersUnder18, NumberMaleUsers18To40, NumberMaleUsersOver40,
						NumberFemaleUsersUnder18, NumberFemaleUsers18To40, NumberFemaleUsersOver40)
SELECT stations.ID,
		COUNT(CASE WHEN ABS(2020 - birth_year) < 18 AND usertype = 'Subscriber' AND gender = 1 THEN 1 END),
        COUNT(CASE WHEN ABS(2020 - birth_year) >= 18 AND ABS(2020 - birth_year) <=  40 AND usertype = 'Subscriber' AND gender = 1 THEN 1 END),
        COUNT(CASE WHEN ABS(2020 - birth_year) > 40 AND usertype = 'Subscriber' AND gender = 1 THEN 1 END),
        COUNT(CASE WHEN ABS(2020 - birth_year) < 18 AND usertype = 'Subscriber' AND gender = 2 THEN 1 END),
        COUNT(CASE WHEN ABS(2020 - birth_year) >= 18 AND ABS(2020 - birth_year) <=  40 AND usertype = 'Subscriber' AND gender = 2 THEN 1 END),
        COUNT(CASE WHEN ABS(2020 - birth_year) > 40 AND usertype = 'Subscriber' AND gender = 1 THEN 1 END)
FROM bike_data
JOIN stations ON bike_data.start_station_id = stations.ID OR bike_data.end_station_id = stations.ID
WHERE stations.ID IN (SELECT ID FROM stations) GROUP BY stations.ID;

SELECT * FROM UsageByAge ORDER BY StationID ASC;
DROP TABLE UsageByAge;


/* creating the table frequent trips
   to store the number of trips between two different stations
*/
CREATE TABLE FrequentTrips (
	DayOfWeek INT,
    First_Station VARCHAR(50),
    Second_Station VARCHAR(50),
    Trips INT
);

-- Using the data from the table bike_data. Depending on the name od stations
INSERT INTO FrequentTrips(DayOfWeek, First_Station, Second_Station, Trips)
SELECT start_day, start_station_name, end_station_name, COUNT(*)
FROM bike_data
GROUP BY start_station_name, end_station_name;

SELECT DayOfWeek, First_Station, Second_Station, MAX(Trips) FROM FrequentTrips WHERE DayOfWeek = 1 ORDER BY Trips DESC;
DROP TABLE FrequentTrips;

/* this will give us the vacant stations but it returned nothing. 
   I beleive there are no vacant stations */
SELECT start_station_name AS Vacant_Station
FROM bike_data
WHERE start_station_name NOT IN (SELECT start_station_name FROM bike_data GROUP BY start_station_name, end_station_name);