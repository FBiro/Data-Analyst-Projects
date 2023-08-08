Select *
from Portfolioproject.dbo.['covid-data-deaths']
where continent is not null
order by 1,2

--Select *
--from Portfolioproject.dbo.['covid-data-vax$']
--order by 1,2

select location, date, total_cases,total_deaths,population
from Portfolioproject.dbo.['covid-data-deaths']
order by 1,2

-- Total cases vs Total deaths

ALTER TABLE Portfolioproject.dbo.['covid-data-deaths']
ALTER COLUMN total_deaths NUMERIC(38, 0);


--likelyhood of dying now in serbia now
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject.dbo.['covid-data-deaths']
where location like 'Serbia'
order by 2 desc


--% of people who got covid
select location, date, population,total_cases, (total_cases/population)*100 as InfectionRating
from Portfolioproject.dbo.['covid-data-deaths']
where location like 'Serbia'
order by 1,2 desc


--% Highest infectionrate
select location, population, MAX(total_cases) as HighestInfectionrate, MAX((total_cases/population))*100 as InfectionRating
from Portfolioproject.dbo.['covid-data-deaths']
Group by location, population
order by 4 desc

--% Highest infectionrate
select location, Max(Total_deaths) as DeathCountTotal
from Portfolioproject.dbo.['covid-data-deaths']
where continent is not null
Group by location
Order by DeathCountTotal desc


--% Continet death view
select continent, Max(Total_deaths) as DeathCountTotal
from Portfolioproject.dbo.['covid-data-deaths']
where continent is not null
Group by continent
Order by DeathCountTotal desc


--GLOBAL

select date,SUM(new_cases), SUM(cast(new_deaths as int)), (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DEATHPER 
from Portfolioproject.dbo.['covid-data-deaths']
--where location like 'Serbia'
where (new_cases)>(cast(new_deaths as int))
Group by date
order by 4 desc


-- Total death%
select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Deathper
from Portfolioproject.dbo.['covid-data-deaths']
where (new_cases)>(cast(new_deaths as int))
order by 1,2 desc


-- Total pop vs Vax
Select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingSumOFPeopleVAX
from Portfolioproject.dbo.['covid-data-deaths'] dea
join Portfolioproject.dbo.['covid-data-vax$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 1,2


-- TEMP TABLE
Drop Table if exists #PercentPopVaxed 
CREATE TABLE #PercentPopVaxed
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingSumOFPeopleVAX numeric
)
INSERT INTO #PercentPopVaxed
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingSumOFPeopleVAX
FROM Portfolioproject.dbo.['covid-data-deaths'] dea
JOIN Portfolioproject.dbo.['covid-data-vax$'] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2

SELECT
    *,
    (RollingSumOFPeopleVAX / CONVERT(NUMERIC(18, 2), Population)) * 100 AS Percentage
FROM #PercentPopVaxed




--Views for visualisations

CREATE VIEW PercentPopVaxed AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingSumOFPeopleVAX
FROM Portfolioproject.dbo.['covid-data-deaths'] dea
JOIN Portfolioproject.dbo.['covid-data-vax$'] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


