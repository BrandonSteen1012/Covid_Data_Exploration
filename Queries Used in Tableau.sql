--1

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL  -- Handles a divide by zero error
        ELSE SUM(new_deaths) * 100.0 / SUM(new_cases)  -- Calculatea the death percentage
    END AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--2 

SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is NULL
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location 
ORDER BY TotalDeathCount DESC 

--3

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Portfolio..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--4

Select location, population, date, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

