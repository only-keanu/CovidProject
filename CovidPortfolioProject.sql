--SELECT *
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are going to be using

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths$
--order by 1,2

--Looking at Total Cases vs Total Deaths

--Shows likelihood of dying if you contract covid in your country
--Select Location, date, Population,total_cases, (cast(total_cases as float)/cast(population as float))*100 AS TotalCasesPercentage
--From PortfolioProject..CovidDeaths$
----Where location like '%states%'
--order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population 

--Select Location,Population,MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float)))*100 AS PercentPopulationInfected
--From PortfolioProject..CovidDeaths$
--Where location like '%states%'
--Group by Location, Population
--order by Population DESC, PercentPopulationInfected DESC 

-- Showing Countries with Highest Death Count per Population

--Select Location,MAX(cast(total_deaths AS int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths$
--Where location like '%states%'
--Group by Location
--order by TotalDeathCount DESC

-- GLOBAL NUMBERS
--Select date, SUM(new_cases) as total_cases ,SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage--,total_deaths, cast(total_deaths AS int)/cast(total_cases AS int)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths$
--Where location like '%states%'
--where continent is not null
--Group by date
--order by 1,2

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3