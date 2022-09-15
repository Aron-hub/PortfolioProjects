-- ** DATA EXPLORATION ** 
-- ** Sharpened skill: Joins, Windows Functions, Aggregate Functions, CTE's, Temporary Table,Creating Views, & Converting Data Types

-- describe the data

DESCRIBE coviddeath;-- 
DESCRIBE covidvacine;

-- Change type of date from text to date

SET SQL_SAFE_UPDATES=0;

UPDATE coviddeath
SET date = STR_TO_DATE(date,'%d/%m/%Y');
ALTER TABLE coviddeath
MODIFY COLUMN date Date;
DESCRIBE coviddeath;

UPDATE covidvacine
SET date = STR_TO_DATE(date,'%d/%m/%Y');
ALTER TABLE covidvacine
MODIFY COLUMN date Date;
DESCRIBE covidvacine;

SET SQL_SAFE_UPDATES=1;

-- Focus on analysis CovidDeath

-- Total_cases VS Total_dates
-- (Showing likelihood of dying per country)
SELECT 
	location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS Death_Percentage
FROM coviddeath
WHERE continent != ''
ORDER BY location, date;

-- (Showing likelihood of dying just For my Country)
SELECT 
	location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS Death_Percentage
FROM coviddeath
WHERE location='Indonesia' AND continent != ''
ORDER BY location, date;

-- Total Cases VS Population
-- (Showing the percentage of the population infected by covid)
SELECT 
	location,
    date,
    total_cases,
    population,
    (total_cases/population)*100 AS Case_Percentage
FROM coviddeath
WHERE continent != ''
ORDER BY location, date;

-- Special for My Country
-- (Showing the percentage of the population infected by covid for my country)
SELECT 
	location,
    date,
    population,
    total_cases,
    (total_cases/population)*100 AS Case_Percentage
FROM coviddeath
WHERE location='Indonesia'
ORDER BY location, date;

-- looking at countries with highest infection rate according to population
SELECT 
	location,
    population,
    MAX(total_cases) AS highest_cases,
    MAX((total_cases/population))*100 AS Case_Percentage
FROM coviddeath
GROUP BY location, population
ORDER BY Case_Percentage DESC;


-- looking at countries with highest deaths according to population
SELECT 
	location,
    population,
    MAX(total_deaths) AS highest_deaths,
    MAX((total_deaths/population))*100 AS Death_Percentage
FROM coviddeath
GROUP BY location, population
ORDER BY Death_Percentage DESC;

-- looking at countries with highest death Count per Location
SELECT 
	location,
    MAX(cast(total_deaths AS UNSIGNED)) AS highest_death
FROM coviddeath
WHERE continent !=''
GROUP BY location
ORDER BY highest_death DESC;

-- looking at continent with highest death count per continent
SELECT 
	continent,
    MAX(cast(total_deaths AS UNSIGNED)) AS highest_death
FROM coviddeath
WHERE continent !=''
GROUP BY continent
ORDER BY highest_death DESC;

-- showing continents with the highest death count per population
SELECT 
	continent,
	MAX( cast(total_deaths AS UNSIGNED)/ population)*100 AS deathPerPopulation
FROM coviddeath
WHERE continent !=''
GROUP BY continent 
ORDER BY deathPerPopulation DESC;


-- GLobal Number
 SELECT 
	SUM(new_cases) AS totalCases,
    SUM(cast(new_deaths AS UNSIGNED)) AS totalDeaths,
    ((SUM(cast(new_deaths AS UNSIGNED))/(SUM(new_cases))))*100 AS deathPercentage    
 FROM coviddeath
 WHERE continent !='';
 
-- Total Population vs Vaccination
-- Shows Percentage of population that has received at least one Covid vaccine

SELECT
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
FROM coviddeath as dea
INNER JOIN  covidvacine as vac
	ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent !=''
ORDER BY dea.location, dea.date;

-- Using CTE to perform calculation on Partition BY in previous query
WITH PopVsVac(Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeath as dea
INNER JOIN  covidvacine as vac
	ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent !=''
ORDER BY dea.location, date
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Vaccine_Percentage 
FROM PopVsVac;



-- Using Temp Table to perform calculation on Partition BY in previous query
DROP TEMPORARY TABLE  IF EXISTS Vaccine_Percentage;
CREATE TEMPORARY TABLE Vaccine_Percentage (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO  Vaccine_Percentage
SELECT
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(vac.new_vaccinations AS DOUBLE) AS New_Vaccinations,
    SUM(CAST(vac.new_vaccinations AS DOUBLE)) OVER 
	(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeath as dea
INNER JOIN  covidvacine as vac
	ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent !=''
ORDER BY dea.location, date;

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Vaccine_Percentages
FROM Vaccine_Percentage;

-- Crete a view to store the data for later visualizations
-- 1 vaccinePercentage
DROP VIEW IF EXISTS VaccinePercentage;
CREATE VIEW  VaccinePercentage AS	
SELECT
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(vac.new_vaccinations AS DOUBLE) AS New_Vaccinations,
    SUM(CAST(vac.new_vaccinations AS DOUBLE)) OVER 
	(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeath as dea
INNER JOIN  covidvacine as vac
	ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent !=''
ORDER BY dea.location, date;

-- 2 Global Number
DROP VIEW IF EXISTS globalNUmber;
CREATE VIEW globalNUmber AS
SELECT 
	SUM(new_cases) AS totalCases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS totalDeaths,
	(SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases))*100 AS deathPercenatge
FROM coviddeath
WHERE continent !='';

-- 3. Total Deaths per continent
DROP VIEW IF EXISTS deathsPerContinent;
CREATE VIEW deathsPerContinentr AS
SELECT 
	location,
	SUM(cast(new_deaths AS UNSIGNED)) AS totalDeaths
FROM coviddeath
WHERE continent ='' AND location NOT IN (
'World','European Union', 'International', 'High Income', 
'Upper middle income', 'Lower middle income', 'Low income'
)
GROUP BY location
ORDER BY totalDeaths DESC;

-- 4. Number population had infected per location
DROP VIEW IF EXISTS populationInfected;
CREATE VIEW populationInfected AS
SELECT 
	location,
    population,
	MAX(total_cases) AS highInfectionCount,
    MAX(total_cases/population)*100 AS percentagePopulationInfected
FROM coviddeath
GROUP BY location, population
ORDER BY percentagePopulationInfected DESC;






