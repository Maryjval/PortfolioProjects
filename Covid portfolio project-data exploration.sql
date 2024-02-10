select *
from PortfolioProject. .CovidDeaths
order by 3,4


select *
from PortfolioProject. .CovidVaccinations
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject. .CovidDeaths
order by 1,2


--Looking at Total cases vs population

select location, date, population, total_cases,(total_deaths/population)* 100 as PercentPopulationInfected
from PortfolioProject. .CovidDeaths
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location,population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject. .CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death counts

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject. .CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--LET BREAK THINGS DOWN BY CONTINENT

select continent	, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject. .CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS



select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage


where continent is not null
order by 1,2


select *
from PortfolioProject. .CovidDeaths cd
join PortfolioProject. .CovidVaccinations cv
    on cd.location =cv.location
	and cd.date = cv.date

--Looking at Total Population vs Vaccination

select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations
from PortfolioProject. .CovidDeaths cd
join PortfolioProject. .CovidVaccinations cv
    on cd.location =cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3



select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations, 
sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject. .CovidDeaths cd
join PortfolioProject. .CovidVaccinations cv
    on cd.location =cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

--USE CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) 
as
(
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject. .CovidDeaths cd
join PortfolioProject. .CovidVaccinations cv
    on cd.location =cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject. .CovidDeaths cd
join PortfolioProject. .CovidVaccinations cv
    on cd.location =cv.location
	and cd.date = cv.date
where cd.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Create View to store data for later visualizations

Create view PercentPopulationVaccinated as
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortfolioProject. .CovidDeaths cd
join PortfolioProject. .CovidVaccinations cv
    on cd.location =cv.location
	and cd.date = cv.date
where cd.continent is not null


select *
from PercentPopulationVaccinated
