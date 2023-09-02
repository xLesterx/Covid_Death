SELECT *
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject1.dbo.CovidVaccinations
ORDER BY 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2


-- LOOKING AT THE TOTAL CASES OVER TOTAL DEATHS
-- SHOWS THE LIKELIHOOD OF DYING (PHILIPPINES)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE Location LIKE '%Philippines%' and continent is not Null
ORDER BY 1,2

--TOTAL CASES OVER POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Population_Infected_Percentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE Location LIKE '%Philippines%' and continent is not Null
ORDER BY 1,2

--LOOKING AT THE HIGHEST INFECTION RATE COMPARE TO POPULATION
SELECT Location, MAX(total_cases) AS Highest_Infection_Count, population, MAX(total_cases/population)*100 AS Population_Infected_Percentage
FROM PortfolioProject1.dbo.CovidDeaths
GROUP BY location, population
ORDER BY  Population_Infected_Percentage DESC



--LOOKING AT THE COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT Location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not Null
GROUP BY location
ORDER BY  Total_Death_Count DESC


--BREAKING THINGS DOWN BY CONTINENT


--SHOWING THE CONTINENT WITH HIGHEST DEATH COUNT
SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not Null
GROUP BY continent
ORDER BY  Total_Death_Count DESC

--GLOBAL NUMBERS

--DEATH PERCENTAGE BY DAYS
SELECT  date, SUM(new_cases) AS Total_Cases ,SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not Null
GROUP BY date
ORDER BY 1,2


--DEATH PERCENTAGE OF WHOLE WORLD
SELECT   SUM(new_cases) AS Total_Cases ,SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not Null
ORDER BY 1,2



SELECT *
FROM CovidDeaths AS DTH
JOIN CovidVaccinations AS VAC
	ON DTH.location = VAC.location
	and DTH.date = VAC.date


--	LOOKING AT THE TOTAL POPULATION OVER VACCINATION
SELECT DTH.continent, DTH.date, DTH.location, DTH.population, VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS int)) OVER (PARTITION BY DTH.location ORDER BY DTH.location, DTH.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS DTH
JOIN CovidVaccinations AS VAC
	ON DTH.location = VAC.location
	and DTH.date = VAC.date
WHERE DTH.continent is not NULL
ORDER BY 1,3


--CTE
WITH Pop_Vac(Continent, Location, Date, Population, New_Vaccinations , Rolling_People_Vaccinated)
as
(
SELECT DTH.continent, DTH.date, DTH.location, DTH.population, VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS int)) OVER (PARTITION BY DTH.location ORDER BY DTH.location, DTH.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS DTH
JOIN CovidVaccinations AS VAC
	ON DTH.location = VAC.location
	and DTH.date = VAC.date
WHERE DTH.continent is not NULL
--ORDER BY 1,3
)

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM Pop_Vac


--TEMP TABLE
DROP TABLE if exists #Percentage_Population_Vaccinated
CREATE TABLE #Percentage_Population_Vaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Peoplie_Vaccinated numeric
)

INSERT INTO #Percentage_Population_Vaccinated
SELECT DTH.continent, DTH.date, DTH.location, DTH.population, VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS int)) OVER (PARTITION BY DTH.location ORDER BY DTH.location, DTH.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS DTH
JOIN CovidVaccinations AS VAC
	ON DTH.location = VAC.location
	and DTH.date = VAC.date
--WHERE DTH.continent is not NULL

SELECT *, (Rolling_Peoplie_Vaccinated/Population)*100
FROM #Percentage_Population_Vaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW Percentage_Population_Vaccinated AS
SELECT DTH.continent, DTH.date, DTH.location, DTH.population, VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS int)) OVER (PARTITION BY DTH.location ORDER BY DTH.location, DTH.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS DTH
JOIN CovidVaccinations AS VAC
	ON DTH.location = VAC.location
	and DTH.date = VAC.date
WHERE DTH.continent is not NULL

SELECT * 
FROM Percentage_Population_Vaccinated