Select Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%united states%' and not(location like '%virgin island%')
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got Covid
Select Location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as PopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%united states%' and not(location like '%virgin island%')
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, population, max(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float)))*100 as PopulationInfected
FROM PortfolioProject..CovidDeaths
group by location, population
order by PopulationInfected desc

--Showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ NULLIF(SUM(new_cases),0) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccination

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dth.location Order by dth.location, dth.date) as CumulativePeopleVaccinated
FROM PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 2,3

--USE CTE 

With PopvsVac (Continent, location, date, population, New_vaccinations, CumulativePeopleVaccinated)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dth.location Order by dth.location, dth.date) as CumulativePeopleVaccinated
FROM PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 2,3
)
Select *, (CumulativePeopleVaccinated/Population)*100
From PopvsVac

--USE TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dth.location Order by dth.location, dth.date) as CumulativePeopleVaccinated
FROM PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 2,3

Select *, (CumulativePeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dth.location Order by dth.location, dth.date) as CumulativePeopleVaccinated
FROM PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated