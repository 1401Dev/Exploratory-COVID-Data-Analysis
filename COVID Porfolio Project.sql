USE portfolioProjects

SELECT *
FROM covidDeaths$
WHERE continent is not NULL
ORDER BY 3,4

SELECT *
FROM ['owid-covid-data$']
WHERE continent is not NULL
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covidDeaths$
WHERE continent is not NULL
ORDER BY 1,2

-- total cases vs deaths
-- this shows of likelihood of dying if you contract covid in USA

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covidDeaths$
WHERE location like '%States%' 
and continent is not NULL
ORDER BY 5 DESC


-- total cases vs population
-- this shows of what percentage of population got covid in USA
SELECT Location, date, population, total_cases, (total_cases/population)*100 as infected_percentage
FROM covidDeaths$
WHERE location like '%States%' 
and continent is not NULL
ORDER BY 5 DESC


-- this shows countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infected_percentage
FROM covidDeaths$
-- WHERE location like '%States%' 
WHERE continent is not NULL
GROUP BY Location, population
ORDER BY infected_percentage DESC


-- this shows countries with highest death counts per population
SELECT Location, MAX(cast(total_deaths as int)) as highest_death_count
FROM covidDeaths$
-- WHERE location like '%States%' 
WHERE continent is not NULL
GROUP BY Location
ORDER BY highest_death_count desc

---- this shows continent with highest death counts per population
--SELECT location, MAX(cast(total_deaths as int)) as highest_death_count
--FROM covidDeaths$
---- WHERE location like '%States%' 
--WHERE continent is NULL
--GROUP BY location
--ORDER BY highest_death_count desc


-- this shows continent with highest death counts per population
SELECT continent, MAX(cast(total_deaths as int)) as highest_death_count
FROM covidDeaths$
-- WHERE location like '%States%' 
WHERE continent is not NULL
GROUP BY continent
ORDER BY highest_death_count desc


-- GLOBAL NUMBERS BASED ON DATE
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM covidDeaths$
--WHERE location like '%States%' 
WHERE continent is not NULL
GROUP BY date
ORDER BY 4 


-- TOTAL GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM covidDeaths$
WHERE continent is not NULL


SELECT *
FROM covidDeaths$ AS dea
JOIN ['owid-covid-data$'] AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- Calculating the total vaccinated population

-- CTE Table
WITH popVsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
-- Looking a total population vs vaccination 
-- rolling count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location
ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM covidDeaths$ dea
JOIN ['owid-covid-data$'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 as percentPopulationVaccinated
FROM popVsVac


-- Creating view to store data for later visualizations
CREATE VIEW percentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location
ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM portfolioProjects..covidDeaths$ dea
JOIN portfolioProjects..['owid-covid-data$'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM percentPopulationVaccinated