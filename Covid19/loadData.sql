-- 1. Create a table from table_header
DROP TABLE IF EXISTS coviddeath;
CREATE TABLE coviddeath LIKE coviddeathHeader;

DROP TABLE IF EXISTS covidvacine;
CREATE TABLE covidvacine LIKE covidvacineHeader;

-- 2. Check the type of the column
DESCRIBE coviddeath;
DESCRIBE covidvacine;

-- 3. See the local infile status
SHOW VARIABLES LIKE 'Local_infile';
SET GLOBAL local_infile=1;


-- 4. load data
LOAD DATA LOCAL INFILE "D:/Data_analysist/project'/file/covidDeath.csv'"
INTO TABLE reviews
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "D:/Data_analysist/project'/file/covidVacine.csv'"
INTO TABLE reviews
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- 5. see the data
SELECT * FROM coviddeath;
SELECT * FROM covidvacine;
