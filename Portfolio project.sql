SELECT*
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

SELECT*
FROM PortfolioProject..CovidVaccination
 
order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- TotalCases vs TotalDeaths 
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

--Total Cases Vs Population
select location,date,total_cases,population, (total_cases/population)*100 As PercentagePopulationgetInfected
FROM PortfolioProject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

-- Highest Infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 As PercentagePopulationgetInfected
FROM PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group By location,population
order by PercentagePopulationgetInfected desc

-- Highest death count per population

select location,MAX(cast (Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group By location
order by TotalDeathCount desc

-- Highest death count per population by continen( Accurate)

select location ,MAX (cast (Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is  null
Group By location
order by TotalDeathCount desc

-- Global Numbers total deaths to total cases

select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM (cast(new_deaths as int ))/SUM (new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1,2

-- Looking at totalpopulation vs vaccination 


select dea.continent,dea.location,dea.date,dea.population, vac. new_vaccinations, 
SUM(convert(BIGint ,vac.new_vaccinations)) OVER ( Partition by dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccination vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- ANOTHER WAY OF EXECUTING ABOVE QUERY

select dea.continent,dea.location,dea.date,dea.population, vac. new_vaccinations, 
SUM(CAST( vac.new_vaccinations AS BIGINT)) OVER ( Partition by dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccination vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
order by 2,3

 --USE CTE 

with PopvsVac (continent, location,date,population,RollingPeopleVaccinated,new_vaccinations )
as

(
select dea.continent,dea.location,dea.date,dea.population, vac. new_vaccinations, 
SUM(CAST( vac.new_vaccinations AS BIGINT)) OVER ( Partition by dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccination vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, ( RollingPeopleVaccinated /population)*100
from PopvsVac
 
 -- TEMP TABLE
 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 continent nvarchar (255),
 location nvarchar (255),
 Date datetime,
 Population numeric,
 New_vaccination numeric,
 RollingPeopleVaccinated numeric
 )


 insert into #PercentPopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population, vac. new_vaccinations, 
SUM(CAST( vac.new_vaccinations AS BIGINT)) OVER ( Partition by dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccination vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, ( RollingPeopleVaccinated /population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualization

create view PercentPopulationVaccinated as
 select dea.continent,dea.location,dea.date,dea.population, vac. new_vaccinations, 
SUM(CAST( vac.new_vaccinations AS BIGINT)) OVER ( Partition by dea.location ORDER BY dea.location, dea.Date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccination vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated


