--Some SQL queries for Analysis (PostgreSQL)

select location, date, total_cases, new_cases, total_deaths, population from coviddeaths order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in Russia
select location, date, total_cases, total_deaths,(cast(total_deaths as float)/ cast(total_cases as float))*100 as DeathPercentage 
from coviddeaths where location like '%Russia%' 
order by 1, 2 

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
select location, date, population, total_cases, (cast(total_cases as float)/ cast(population as float))*100 as PercentPopulationInfected 
from coviddeaths where location like '%Russia%' 
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
select location, population, Max(total_cases) as HighestInfectionCount, Max(cast(total_cases as float)/ cast(population as float))*100 
as PercentPopulationInfected 
from coviddeaths
where total_cases IS NOT NULL and population is not null
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
select location, max(total_deaths) as TotalDeathsCount from coviddeaths
where total_deaths is not null and continent is not null
group by location
order by TotalDeathsCount desc

-- by continent
select continent, max(total_deaths) as TotalDeathsCount from coviddeaths
where total_deaths is not null and continent is not null
group by continent
order by TotalDeathsCount desc

-- or by continent like this:
select location, max(total_deaths) as TotalDeathsCount from coviddeaths
where total_deaths is not null and continent is null
group by location
order by TotalDeathsCount desc

-- Global Numbers
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as Death_Percentage 
from coviddeaths
where continent is not null
group by date
order by 1, 2 desc

-- Global Number
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as Death_Percentage 
from coviddeaths
where continent is not null
order by 1, 2 desc

-- Looking at total Population vs Vaccination
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) 
over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from coviddeaths cd join covidvaccination cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null -- and cv.new_vaccinations is not null
order by 2, 3

--use CTE
with PopvsVac as ( 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) 
over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from coviddeaths cd join covidvaccination cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null -- and cv.new_vaccinations is not null
-- order by 2, 3
)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac

-- Temp table
create temp table PercentPopulationVaccinated(
continent text,
location text,
date date,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) 
over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from coviddeaths cd join covidvaccination cv on cd.location = cv.location and cd.date = cv.date
-- where cd.continent is not null -- and cv.new_vaccinations is not null
-- order by 2, 3


-- Creating View to store data for later visualization
create view PercentPopulationVaccinatedView as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) 
over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from coviddeaths cd join covidvaccination cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null -- and cv.new_vaccinations is not null
-- order by 2, 3

select *from PercentPopulationVaccinatedView
