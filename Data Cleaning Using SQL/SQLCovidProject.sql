
select * 
from PortfolioProject..CovidDeaths$

select * 
from PortfolioProject..CovidDeaths$
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4 sort the table according to third and fourth column

-- select data that we are going to using

select location , date , total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2


-- looking at total cases vs total deaths
--shows likelyhood of dying if you contract in your country

select location , date , total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percent
from PortfolioProject..CovidDeaths$
where location like'%states%'
order by 1,2


--looking at a total cases vs population
--shows what percentage of population got covid

select location , date , total_cases,  population, (total_cases/population) * 100 as death_percent
from PortfolioProject..CovidDeaths$
where location like'%states%'
order by 1,2

select location , date , total_cases,  population, (total_cases/population) * 100 as death_percent
from PortfolioProject..CovidDeaths$
--where location like'%states%'
order by 1,2


-- looking at countries where highest infection rate compared to population

select location , population,  max(total_cases) as HighestInfectionCount ,  max((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like'%states%'
group by  population,location
order by PercentPopulationInfected desc


-- showing counties with highest death count per population

select location , population,  max(total_deaths)  as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like'%states%'
group by  population,location
order by TotalDeathCount desc

-- casting the text into integer 

select location ,  max(cast(total_deaths as int))  as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like'%states%'
group by location
order by TotalDeathCount desc


select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


select location ,  max(cast(total_deaths as int))  as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like'%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- lets break things down by continent

select continent,  max(cast(total_deaths as int))  as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like'%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

select location,  max(cast(total_deaths as int))  as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like'%states%'
where continent is  null
group by location
order by TotalDeathCount desc

-- looking at countries with Highest Infection Rate compared to Population

select location, Population, continent, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by location, population,continent
order by PercentPopulationInfected desc


--showing continents with the highest deatrh count per population

select continent,  max(cast(total_deaths as int))  as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like'%states%'
where continent is  null
group by continent
order by TotalDeathCount desc

select continent,  max(cast(total_deaths as int))  as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like'%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select location , date , total_cases, total_deaths, population, (total_cases/population) * 100 as death_percent
from PortfolioProject..CovidDeaths$
--where location like'%states%' 
where continent is not null
order by 1,2

select sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercetage-- total_deaths, population, (total_cases/population) * 100 as death_percent
from PortfolioProject..CovidDeaths$
--where location like'%states%' 
where continent is not null
--group by date
order by 1,2


-- looking at Total Population vs Vaccinations

select * 
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location and dea.date= vac.date 

select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location and dea.date= vac.date 
where dea.continent is not null
order by 2,3

select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location and dea.date= vac.date 
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, location, Date, Population, new_vaccinations,RollingPeopleVaccinated) as 
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location and dea.date= vac.date 
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/Population) * 100 as RollingPercent from PopvsVac


--Temp Table

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric

)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location and dea.date= vac.date 
where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/Population) * 100 as RollingPercent from #PercentPopulationVaccinated



-- create view to store data for later visualization this is just a virtual table 

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location and dea.date= vac.date 
where dea.continent is not null
--order by 2,3


select * 
from PercentPopulationVaccinated