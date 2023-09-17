SELECT *
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4

--SELECT *
--FROM Portfolio..CovidVaccinations
--ORDER BY 3, 4

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM Portfolio..CovidDeaths
--ORDER BY 1,2

--looking at the Total Cases vs the Total Deaths
--Shows the likelihood of dying if you contracted covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentages
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Looking at the Total Cases VS the Population
--Shows the percentage of the population that contracted Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS ContractionPercentages
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


--Looking at countries with the highest infection rates compared to their populations
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS ContractionPercentages
FROM Portfolio..CovidDeaths
GROUP BY population, location 
ORDER BY ContractionPercentages DESC 


--Showing the countries with the highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC 

--BREAK DOWN DATA BY CONTINENT

SELECT continent, SUM(total_deaths) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not NULL
and location not in ('World', 'European Union', 'International')
GROUP BY continent 
ORDER BY TotalDeathCount DESC 

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL  -- Handles a divide by zero error
        ELSE SUM(new_deaths) * 100.0 / SUM(new_cases)  -- Calculatea the death percentage
    END AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Populations vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location) AS CumulativeVaccinations,
--(CumulativeVaccinations/population) * 100
FROM Portfolio..CovidDeaths AS dea
JOIN Portfolio..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, CumulativeVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations
--(CumulativeVaccinations/population) * 100
FROM Portfolio..CovidDeaths AS dea
JOIN Portfolio..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (CumulativeVaccinations/population) * 100
FROM PopvsVac

--TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
CumulativeVaccinations NUMERIC
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations
--(CumulativeVaccinations/population) * 100
FROM Portfolio..CovidDeaths AS dea
JOIN Portfolio..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CumulativeVaccinations/population) * 100
FROM #PercentPopulationVaccinated


--Creating a View to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations
--(CumulativeVaccinations/population) * 100
FROM Portfolio..CovidDeaths AS dea
JOIN Portfolio..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
