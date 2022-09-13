-- query that use for tableau project

-- 1. Global number for Cases VS Deaths
SELECT 
	SUM(new_cases) AS totalCases,
    SUM(cast(new_deaths AS UNSIGNED)) AS totalDeaths,
    (  SUM(cast(new_deaths AS UNSIGNED))/SUM(new_cases))*100 AS deathsPercentage	
FROM coviddeath
WHERE continent !='';


-- 2. Total Deaths per continent
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

-- 3. Number population had infected per location
SELECT 
	location,
    population,
	MAX(total_cases) AS highInfectionCount,
    MAX(total_cases/population)*100 AS percentagePopulationInfected
FROM coviddeath
GROUP BY location, population
ORDER BY percentagePopulationInfected DESC;

-- 4. Number population had infected per location per date
SELECT 
	location,
    population,
    STR_TO_DATE(date, '%d/%m/%Y') AS dataDate,
	MAX(total_cases) AS highInfectionCount,
    MAX((total_cases/population))*100 AS percentagePopulationInfected
FROM coviddeath
GROUP BY location, population, dataDate
ORDER BY percentagePopulationInfected DESC;

