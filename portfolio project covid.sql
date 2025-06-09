-- data using for this project

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2;


-- total cases vs total death
-- shows likelihood of dying when you get covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1, 2;


-- percentage of people who get covid in their countries
select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfCovidPatients
from PortfolioProject..CovidDeaths
where location like '%korea%'
and continent is not null
order by 1, 2;

-- highest infection rate by countries
select location, population, max(total_cases) as highestInfextionCount, max((total_cases/population))*100 as PercentageOfCovidPatients
from PortfolioProject..CovidDeaths
where continent is not null
group by population, location
order by PercentageOfCovidPatients desc;

-- highest death count by countries
select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by population, location
order by TotalDeathCount desc;

-- hightest death count by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- global numbers

	--total case, total death
select sum(new_cases) as totalNewCases, sum(cast(new_deaths as int)) as totalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2;

	-- total case, total death by date
select date, sum(new_cases) as totalNewCases, sum(cast(new_deaths as int)) as totalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2;

-- new vaccination by date
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 1, 2, 3;

-- rolling sum of new vaccination by country

with VacPercent as (
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rollingSumPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select *, (rollingSumPeopleVaccinated/population)*100 as vacPercentage
from VacPercent
order by 2, 3
;


-- Vaccination start date by country
select cd.location, min(cd.date) as VaccinationStartDate
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
and cv.new_vaccinations > 0
group by cd.location
order by 1, 2;



-- create temp table and insert data above
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rollingSumPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null;

select * from #PercentPopulationVaccinated;

-- create view to store data for visualisation
create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rollingSumPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null;

select * from PercentPopulationVaccinated;