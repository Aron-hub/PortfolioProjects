-- ** DATA EXPLORATION ** 
-- ** Sharpened skill: Joins, Windows Functions, Aggregate Functions, CTE's, Temporary Table,Creating Views, & Converting Data Types

-- describe the data
DESCRIBE coviddeath;
DESCRIBE covidvacine;

-- See the data
SELECT * FROM coviddeath
WHERE continent !=''
GROUP BY continent,location
ORDER BY continent,location,str_to_date(date,'%d%m/Y');
SELECT * FROM covidvacine
ORDER BY location, date;

-- Focus on analysis CovidDeath
-- Selecting the data that we only use  
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM coviddeath
ORDER BY location, date;

-- Total_cases VS Total_dates
-- (Showing likelihood of dying per country)
SELECT 
	location,
    STR_TO_DATE(date, '%d/%m/%Y') AS Date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS Death_Percentage
FROM coviddeath
WHERE continent != ''
ORDER BY location, Date;

-- (Showing likelihood of dying just For my Country)
SELECT 
	location,
    STR_TO_DATE(date, '%d/%m/%Y') AS Date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS Death_Percentage
FROM coviddeath
WHERE location='Indonesia' AND continent != ''
ORDER BY location, Date;

-- Total Cases VS Population
--(Showing the percentage of the population infected by covid)
SELECT 
	location,
    STR_TO_DATE(date, '%d/%m/%Y') AS Date,
    total_cases,
    population,
    (total_cases/population)*100 AS Case_Percentage
FROM coviddeath
ORDER BY location, Date;

-- Special for My Country
--(Showing the percentage of the population infected by covid for my country)
SELECT 
	location,
    STR_TO_DATE(date, '%d/%m/%Y') AS Date,
    population,
    total_cases,
    (total_cases/population)*100 AS Case_Percentage
FROM coviddeath
WHERE location='Indonesia'
ORDER BY location, Date;

-- looking at countries with highest infection rate compared to population
SELECT 
	location,
    population,
    MAX(total_cases) AS highest_cases,
    MAX((total_cases/population))*100 AS Case_Percentage
FROM coviddeath
GROUP BY location, population
ORDER BY Case_Percentage DESC;



-- looking at countries with highest death Count per Population
SELECT 
	location,
    MAX(cast(total_deaths AS UNSIGNED)) AS highest_death
FROM coviddeath
WHERE continent !=''
GROUP BY location
ORDER BY highest_death DESC;

-- looking at continent with highest death count 
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
    STR_TO_DATE(dea.date, '%d/%m/%Y') AS DataDate,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y')) AS RollingPeopleVaccinated
FROM coviddeath as dea
INNER JOIN  covidvacine as vac
	ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent !=''
ORDER BY dea.location, DataDate;

-- Using CTE to perform calculation on Partition BY in previous query
WITH PopVsVac(Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT
	dea.continent,
    dea.location,
    STR_TO_DATE(dea.date, '%d/%m/%Y') AS DataDate,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y')) AS RollingPeopleVaccinated
FROM coviddeath as dea
INNER JOIN  covidvacine as vac
	ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent !=''
ORDER BY dea.location, DataDate
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Vaccine_Percentage 
FROM PopVsVac
WHERE (RollingPeopleVaccinated/Population)*100 !=0;


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
    STR_TO_DATE(dea.date, '%d/%m/%Y') AS DataDate,
    dea.population,
    CAST(vac.new_vaccinations AS DOUBLE) AS New_Vaccinations,
    SUM(CAST(vac.new_vaccinations AS DOUBLE)) OVER 
	(PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y')) AS RollingPeopleVaccinated
FROM coviddeath as dea
INNER JOIN  covidvacine as vac
	ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent !=''
ORDER BY dea.location, DataDate;

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Vaccine_Percentages
FROM Vaccine_Percentage;

-- Crete a view to store the data for later visualizations
CREATE VIEW  VaccinePercentage AS	
SELECT
	dea.continent,
    dea.location,
    STR_TO_DATE(dea.date, '%d/%m/%Y') AS DataDate,
    dea.population,
    CAST(vac.new_vaccinations AS DOUBLE) AS New_Vaccinations,
    SUM(CAST(vac.new_vaccinations AS DOUBLE)) OVER 
	(PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%d/%m/%Y')) AS RollingPeopleVaccinated
FROM coviddeath as dea
INNER JOIN  covidvacine as vac
	ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent !=''
ORDER BY dea.location, DataDate;












