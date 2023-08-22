Select *
From PortfolioProject..CovidDeaths$
Order by 2,3

--Select *
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

Alter Table CovidDeaths$
Alter Column total_cases float

Alter Table CovidDeaths$
Alter Column total_deaths float

Select Location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date,total_cases,population,(total_cases/population)*100 as InfectionRate 
From PortfolioProject..CovidDeaths$
Where location like '%china%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, population, MAX (total_cases) as HighestInfectionCount, MAX (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%china%'
Group by Location, Population
Order by PercentPopulationInfected DESC

--Showing countries with highest death count per population

Select Location, MAX (total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%china%'
Where continent is not null
Group by Location
Order by TotalDeathCount DESC

-- Let's Break Things Down by Continent

Select location, MAX (total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%china%'
Where continent is null AND location not like '%income%' AND location not like '%world%'
Group by location
Order by TotalDeathCount DESC

-- Showing continents with the highest death count per population

Select location, MAX (total_deaths) as TotalDeathCount, MAX(total_deaths/population)*100 as HighestDeathsPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%china%'
Where continent is null AND location not like '%income%' AND location not like '%world%'
Group by location
Order by HighestDeathsPercentage DESC


-- Global Numbers

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, Sum(new_deaths)/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%china%'
Where continent is not null AND new_cases <> 0
--Group by date
Order by 1,2


--Calling Covid Vaccination Table
Select *
From PortfolioProject..CovidVaccinations$
Order by 2,3

-- Join Covid Deaths and Covid Vaccination Table

Select*
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Order by 3,4

-- Looking at Total Population vs Vaccinations

Alter Table CovidVaccinations$
Alter Column new_vaccinations float

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Use CTE

With PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)

Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

DROP TABLE if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccination/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


Select*
From PercentPopulationVaccinated