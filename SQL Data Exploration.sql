
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Selecting the data we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Checking the Percentage of the Total Cases to the Total Deaths
--Shows the likelihood of dying if you contract Covid in Nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%nigeria%'
AND continent IS NOT NULL
ORDER BY 1,2


--Shows the Percentage of Population that got Covid in Nigeria
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%nigeria%'
AND continent IS NOT NULL
ORDER BY 1,2



--Checking Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC



--Showing the Country with the highest death count per population
SELECT location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the Continents with the Highest DeathCount per Population

SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2




-- Checking Total population vs vacinnations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulatedPeopleVaccinated
	--(CummulatedPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
WITH PopvsVac (Continent, Location, date, population, new_vaccinations, CummulatedPeopleVaccinated)
AS 
 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulatedPeopleVaccinated
	--(CummulatedPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (CummulatedPeopleVaccinated/population)*100 AS PercentageOfPeopleVaccinated
FROM PopvsVac



--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulatedPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulatedPeopleVaccinated
	--(CummulatedPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (CummulatedPeopleVaccinated/population)*100 AS PercentageOfPeopleVaccinated
FROM #PercentPopulationVaccinated



--Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulatedPeopleVaccinated
	--(CummulatedPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
