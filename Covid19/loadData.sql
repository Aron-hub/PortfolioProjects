
-- copy table from latihanload
DROP TABLE IF EXISTS coviddeath;
CREATE TABLE covidDeath
SELECT * FROM latihanload.coviddeath_manual;

DROP TABLE IF EXISTS covidvacine;
CREATE TABLE covidVacine
SELECT * FROM latihanload.covidvacine_manual;

-- Count number of rows
SELECT COUNT(*) FROM coviddeath;

-- See the data
SELECT * FROM coviddeath
ORDER BY date;
SELECT * FROM covidvacine
ORDER BY date;

-- describe the data
DESCRIBE coviddeath;
DESCRIBE covidvacine;