Select *
From coviddeaths
Where continent is not null  --To filter out the aggregated locations (data cleaning)
Order By 3, 4

--Select *
--From covidvaccinations
--Order By 3, 4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
Where continent is not null  --To filter out the aggregated locations (data cleaning)
order by 1, 2

-- Looking at Total cases vs Total deaths
-- Shows liklihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
Where continent is not null  --To filter out the aggregated locations (data cleaning)
order by 1, 2

--Looking at Total cases vs Population 
-- Shows what percentage of population got Covid

Select location, date, Population, total_cases, (total_cases/Population)*100 as InfectionPercentage
From coviddeaths
Where continent is not null  --To filter out the aggregated locations (data cleaning)
order by 1, 2

--Looking at countries with highest infection rate comapred to population

Select location, Population, Max (total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as InfectionPercentage
From coviddeaths
Where continent is not null  --To filter out the aggregated locations (data cleaning)
Group by location, Population
order by InfectionPercentage DESC

--Showing countries with highest death coount per population

Select location, Max (total_deaths) as TotalDeathCount
From coviddeaths
Where continent is not null --and total_deaths is not null (if further filtering is desired) --To filter out the aggregated locations (data cleaning)
Group by location
order by TotalDeathCount DESC

--Showing Continents with highest death coount per population

Select continent, Max (total_deaths) as TotalDeathCount
From coviddeaths
Where continent is not null --To filter out the aggregated locations (data cleaning)
Group by continent
order by TotalDeathCount DESC

-- Global Numbers

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum (new_deaths)/sum (new_cases)*100 as DeathPercentage
From Coviddeaths
where continent is not null

--Let's join the tables on location and date

Select *
From coviddeaths
Join covidvaccinations
On coviddeaths.location = covidvaccinations.location 
and coviddeaths.date = covidvaccinations.date
 
--Now look at total population vs vaccinations

Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations
From coviddeaths
Join covidvaccinations
On coviddeaths.location = covidvaccinations.location 
and coviddeaths.date = covidvaccinations.date
where .coviddeaths.continent is not null
order by 2,3

--Now roll vaccinated people as time proceeds and show how many new vaccinations exist each day per country

Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations,
sum (covidvaccinations.new_vaccinations) over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.Date) as RollingPeopleVaccinated
From coviddeaths
Join covidvaccinations
On coviddeaths.location = covidvaccinations.location 
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null
order by 2,3


--Now use the query above and determine how many people are vaccinated in each country

Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations,
sum (covidvaccinations.new_vaccinations) over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.Date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100   --You cant use a column that we have jsut created to do calculations are. So use CTE or Temp table
From coviddeaths
Join covidvaccinations
On coviddeaths.location = covidvaccinations.location 
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null
order by 2,3

-- Use CTE

With CTE_PopVsVac as 
(
Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations,
sum (covidvaccinations.new_vaccinations) over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.Date) as RollingPeopleVaccinated
From coviddeaths
Join covidvaccinations
On coviddeaths.location = covidvaccinations.location 
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From CTE_PopVsVac

-- or second option: Temp Table

Drop ttable if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(225),
location nvarchar(225),
Date datetime, 
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations,
sum (covidvaccinations.new_vaccinations) over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.Date) as RollingPeopleVaccinated
From coviddeaths
Join covidvaccinations
On coviddeaths.location = covidvaccinations.location 
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Let's now create views to store data for later visualizations!

Create View PercentPopulationVaccinated as 
Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations,
sum (covidvaccinations.new_vaccinations) over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.Date) as RollingPeopleVaccinated
From coviddeaths
Join covidvaccinations
On coviddeaths.location = covidvaccinations.location 
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null

--Save and put it in GitHub
