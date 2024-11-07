----Select *
----From COVID.dbo.CovidDeaths$
----order by 3,4

--Select *
--From COVID..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From COVID..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths

--Shows the liklihood of dying if you contract Covid in the United States
Select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage 
From COVID..CovidDeaths$
Where location = 'United States'
order by 1,2

--Looking at the total cases vs population
--Shows what percentage of population got Covid
Select location,date,population,total_cases,(total_cases/population) * 100 as InfectedPercentage
From COVID..CovidDeaths$
Where location = 'United States'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as InfectedPercentage
From COVID..CovidDeaths$
Group by population,location
order by InfectedPercentage desc

--Showing countries with the highest death count per population

Select location,max(cast(total_deaths as int)) as TotalDeathCount
From COVID..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

--Continent Breakdown

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
From COVID..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing the Continent with the highest death count 

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
From COVID..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date,SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
From COVID..CovidDeaths$
Where continent is not null 
Group by date
order by 1,2

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
From COVID..CovidDeaths$
Where continent is not null 
order by 1,2


--Looking at Total Population Vs. Vaccinations

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From COVID..CovidDeaths$ as dea
JOIN COVID..CovidVaccinations$ as vac
 on  dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 Order by 2,3


 --USE Common Table Expression

 WITH PopvsVac (Continent, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
 as
 (
 Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From COVID..CovidDeaths$ as dea
JOIN COVID..CovidVaccinations$ as vac
 on  dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 )

Select *,(RollingPeopleVaccinated/Population) *100
From PopvsVac


-- TEMP TABLE

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

Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From COVID..CovidDeaths$ as dea
JOIN COVID..CovidVaccinations$ as vac
 on  dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null

Select *,(RollingPeopleVaccinated/Population) *100
From  #PercentPopulationVaccinated


--Creating View to Store Data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From COVID..CovidDeaths$ as dea
JOIN COVID..CovidVaccinations$ as vac
 on  dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null

 Select *
 From PercentPopulationVaccinated

 

