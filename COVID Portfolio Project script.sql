SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

--Looking at total cases vs total deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null 
Group By Location, population
order by PercentPopulationInfected DESC

--Showing countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group By Location
order by TotalDeathCount DESC	

--LET's break things by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group By continent
order by TotalDeathCount DESC	

-- SHowing the continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group By continent
order by TotalDeathCount DESC

-- GLOBAL numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
group by date
order by 1,2

--GLOBAL TOTAL
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100 as RPVperPop_Percent
From PopvsVac


--TEMP Table

Drop Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3
Select *, (RollingPeopleVaccinated/population)*100 as RPVperPop_Percent
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


SELECT *
From PercentPopulationVaccinated