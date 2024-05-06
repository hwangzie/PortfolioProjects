select * from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_cases, population
from PortfolioProject..CovidDeaths$
order by 1,2


-- looking at total cases vs total deaths
-- shows likelyhood of dying in indonesia
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%indonesia%'
order by 1,2

-- lookin at total cases vs population
-- shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%indonesia%'
order by 1,2

-- countries with higest infection rate compared to population
select location, population, max(total_cases) higestInfectionCount, max((total_cases/population))*100 PercentPopulationInfected 
from PortfolioProject..CovidDeaths$
--where location like '%indonesia%'
group by location, population
order by PercentPopulationInfected desc

-- showing country with high death count for population
select location, MAX(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%indonesia%'
where continent is not null
group by location
order by TotalDeathCount desc


-- split by continent
-- showing country with high death count for population
select location, MAX(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%indonesia%'
where continent is null
group by location
order by TotalDeathCount desc


-- showing contintents with the highest death count per population
select location, MAX(cast(total_deaths as int)) TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%indonesia%'
where continent is not null
group by location
order by TotalDeathCount desc




-- global numbers

select  sum(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(New_deaths as int))/SUM(New_cases)*100 as 
DeathPercantage
from PortfolioProject..CovidDeaths$
--where location like '%indonesia%'
where continent is not null
--group by date
order by 1,2



-- total population vs vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
-- use a CTE
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- creating view to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


select * 
from PercentPopulationVaccinated
