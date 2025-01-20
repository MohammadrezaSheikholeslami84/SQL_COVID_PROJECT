SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [dbo].[CovidDeaths]
ORDER BY 1, 2;

-- Shows Likelihood of dying if you contract covid in your Country ( Here Iran)
SELECT location,date,total_cases,total_deaths, ROUND((total_deaths/total_cases) * 100 ,2) AS DeathPercentage,
          CONCAT(ROUND((total_deaths/total_cases) * 100 ,2),'%') AS DeathPercentage2
FROM [dbo].[CovidDeaths]
WHERE location like '%Iran%' and continent IS NOT NULL
ORDER BY 1, 2;

-- Shows WhatPercentage of Population got Covid
SELECT location,date,population,total_cases, ROUND((total_cases/population) * 100 ,2) AS CovidPercentage
FROM [dbo].[CovidDeaths]
WHERE location like '%Iran%' 
ORDER BY 1, 2;

-- Which Country Has the most Infaction Rate
SELECT location,population,MAX(total_cases) as HighestInfectionCount, 
       MAX( ROUND((total_cases/population) * 100 ,2)) AS CovidPercentage
FROM [dbo].[CovidDeaths]
GROUP BY location,population
ORDER BY CovidPercentage DESC;

-- Showing Countries With Highest Death Count per Population
SELECT location,MAX(CAST(total_deaths AS INT)) as HighestDeathCount, 
       MAX( ROUND((total_deaths/population) * 100 ,2)) AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC, DeathPercentage DESC;

-- Showing CONTINENTS With Highest Death Count per Population
SELECT location,MAX(CAST(total_deaths AS INT)) as HighestDeathCount, 
       MAX( ROUND((total_deaths/population) * 100 ,2)) AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC, DeathPercentage DESC;

-- GOLBAL NUMBERS
SELECT SUM(new_cases) AS total_Cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
            Round(( SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100,2) AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL and total_Cases IS NOT NULL  and total_deaths IS NOT NULL


-- Total Population vs Vaccinations

-- USE CTES

With cte as (
SELECT CV.continent,CD.location,CD.date,cd.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT)) OVER (Partition by CD.location ORDER BY CD.location,CD.date) AS RollingPeopleVacsinated
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location and CD.date = CV.date
WHERE CV.continent IS NOT NULL and new_vaccinations IS NOT NULL
)

SELECT continent,location,MAX(Round((RollingPeopleVacsinated/population)*100,2)) AS Vacsinated_Percentage FROM cte
GROUP BY continent,location
ORDER BY 2 , 3 ;



-- Creating View to Store Data

CREATE VIEW PercentagePopulationVaccinated 
AS (
SELECT CV.continent,CD.location,CD.date,cd.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT)) OVER (Partition by CD.location ORDER BY CD.location,CD.date) AS RollingPeopleVacsinated
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location and CD.date = CV.date
WHERE CV.continent IS NOT NULL and new_vaccinations IS NOT NULL
)
