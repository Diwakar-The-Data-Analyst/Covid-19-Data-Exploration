Select * from CovidDeaths
where continent is not null
order by 3,4

Use Covid
Select Location, date, total_cases, new_cases, total_deaths, new_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths, Round(((total_deaths/total_cases)*100),2) as DeathPercentage
From CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
Select Location, date, Population, total_cases, Round(((total_cases/population)*100),2) as PercentPopulationInfected
From CovidDeaths
Where location like '%india%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population
Select Continent, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Continent
order by TotalDeathCount desc

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(new_deaths) as TotalDeathCount
From CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
--Group By date
order by 1,2

--Vaccination Table
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
from PopvsVac

-- Using Temp Table to perform Calculation on Partition 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Select * from PercentPopulationVaccinated
Drop View PercentPopulationVaccinated
