SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


-- Select Data that we are going to be using

-- Looking at total cases vs total deaths
-- Shows likelyhood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location Like '%India%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as TotalcaseVsPopulation
FROM PortfolioProject..CovidDeaths
WHERE location Like '%India%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to other countries

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%India%'
Group by Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location Like '%India%'
Group by Location, Population
ORDER BY HighestDeathCount DESC


-- Let's break things by continent

-- Showing Continents with highest death count per population

SELECT continent,  MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location Like '%India%'
Group by continent
ORDER BY HighestDeathCount DESC

-- GLOBAL NUMBERS per day

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location Like '%India%'
Group by date
ORDER BY 1,2

--GLOBAL NUMBERS OF Total Cases, Total Deaths and Death Percentage

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location Like '%India%'
ORDER BY 1,2

SELECT *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations(People Vaccinated).

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3	

-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *,(RollingPeopleVaccinated/population)*100 as TotalPopVaccPercent
FROM PopvsVac
--WHERE Location LIKE '%Arab%'


-- Use Temp Tables



DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinationed numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

SELECT *,(RollingPeopleVaccinated/population)*100 as TotalPopVaccPercent
FROM #PercentPopulationVaccinated

-- Views

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3



/*
-- Looking at Total People Vaccinated in each country.

WITH PopvsVac (Continent, Location, Population, New_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.population, vac.total_vaccinations,
MAX(CAST(vac.total_vaccinations as int)) OVER(Partition BY dea.location ORDER BY dea.location) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *,(RollingPeopleVaccinated/population)*100 as TotalPopVaccPercent
FROM PopvsVac
*/

