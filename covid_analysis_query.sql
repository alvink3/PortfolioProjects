select *
from ANAL_PRO..CovidDeaths
where continent is not null
order by 3,4

--select *
--from ANAL_PRO..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from ANAL_PRO..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from ANAL_PRO..CovidDeaths
where location like '%singapore%'
and continent is not null
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
select location, date,population, total_cases,  (total_cases/population)*100 as PopulationInfectedRate
from ANAL_PRO..CovidDeaths
--where location like '%singapore%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PopulationInfectedRate
from ANAL_PRO..CovidDeaths
--where location like '%singapore%'
group by location,population
order by PopulationInfectedRate DESC

-- Showing Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from ANAL_PRO..CovidDeaths
--where location like '%singapore%'
where continent is not null
group by location
order by TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from ANAL_PRO..CovidDeaths
--where location like '%singapore%'
where continent is not null
group by continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths ,sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathRate
from ANAL_PRO..CovidDeaths
--where location like '%singapore%'
where continent is not null
--group by date
order by 1,2





-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from ANAL_PRO..CovidDeaths dea
join ANAL_PRO..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (bigint,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from ANAL_PRO..CovidDeaths dea
join ANAL_PRO..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select*,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from ANAL_PRO..CovidDeaths dea
join ANAL_PRO..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Create View to store date for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from ANAL_PRO..CovidDeaths dea
join ANAL_PRO..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated