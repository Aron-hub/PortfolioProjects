-- query that use for tableau project

-- 1. Global number for Cases VS Deaths
SELECT 
	SUM(new_cases) AS totalCases,
    SUM(cast(new_deaths AS UNSIGNED)) AS totalDeaths,
    (  SUM(cast(new_deaths AS UNSIGNED))/SUM(new_cases))*100 AS deathsPercentage	
FROM coviddeath
WHERE continent !='';


-- 2. Total Deaths and Cases per continent
SELECT 
	location,
	SUM(cast(new_deaths AS UNSIGNED)) AS totalDeaths,
    SUM(new_cases) AS totalCases
FROM coviddeath
WHERE continent ='' AND location NOT IN (
'World','European Union', 'International', 'High Income', 
'Upper middle income', 'Lower middle income', 'Low income'
)
GROUP BY location
ORDER BY totalDeaths DESC;

-- 3. Number of deaths and Cases per location
SELECT 
	location,
	MAX(total_cases) AS highInfectionCount,
    MAX(cast(total_deaths AS UNSIGNED)) As highDeathCount
FROM coviddeath
GROUP BY location
ORDER BY highInfectionCount AND highDeathCount DESC;

-- 4. Total deaths and cases per location per date
SELECT 
	location,
    date,
	MAX(total_cases) AS highInfectionCount,
    MAX(cast(total_deaths AS UNSIGNED)) As highDeathCount
FROM coviddeath
WHERE continent !='' AND location NOT IN (
'World','European Union', 'International', 'High Income', 
'Upper middle income', 'Lower middle income', 'Low income'
)
GROUP BY location, population, date
ORDER BY highInfectionCount AND  highDeathCount DESC;

-- 5 Number of population had infected
SELECT 
	location,
    population,
    MAX(total_cases) AS highInfectionCount,
    MAX(total_cases)/population AS populationInfected
FROM coviddeath 
WHERE continent !='' AND location NOT IN (
'World','European Union', 'International', 'High Income', 
'Upper middle income', 'Lower middle income', 'Low income'
)
GROUP BY location, population
ORDER BY populationInfected DESC;

SELECT total_vaccinations, people_fully_vaccinated
FROM covidvacine;

-- 6. Showing number of cases vs vaccine
SELECT 
	dea.location AS location,
	MAX(dea.total_cases) AS totalCases,
    MAX(CAST(vac.total_vaccinations AS UNSIGNED)) AS totalVaccination
FROM coviddeath AS dea
INNER JOIN covidvacine AS vac
ON dea.date=vac.date AND dea.location=vac.location
WHERE dea.continent ='' AND dea.location NOT IN (
'World','European Union', 'International', 'High Income', 
'Upper middle income', 'Lower middle income', 'Low income'
)
GROUP BY dea.location
ORDER BY totalCases AND totalVaccination;

-- 7. Total vaccination, completely vaccinated, total booster
SELECT 
	location,
    date,
	MAX(CAST(total_vaccinations AS UNSIGNED)) AS totalVaccinations,
    MAX(CAST(people_fully_vaccinated AS UNSIGNED)) AS fullVaccinated,
    MAX(CAST(total_boosters AS UNSIGNED)) AS totalBooster
FROM covidvacine
WHERE continent !='' AND location NOT IN (
'World','European Union', 'International', 'High Income', 
'Upper middle income', 'Lower middle income', 'Low income'
)
GROUP BY location, date
ORDER BY location,date;

