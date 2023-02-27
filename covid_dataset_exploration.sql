--Covid 19 Data Exploration

-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

--CovidDeaths Full Table View

select * from portfolio..CovidDeaths$
where continent is not null
order by 4 Desc

--Covid Vaccination Full Table View
select * from portfolio..CovidVaccitnations$
where continent is not null
order by 3,4


--Querying certain rows in Coviddeath Table

select location,date,population,total_cases,new_cases,total_deaths
from portfolio..CovidDeaths$
order by 1,2

--Querying Total Death, Total Cases in France

select location,population,max(total_cases) as Total_Cases,max(total_deaths) as Total_Deaths
from portfolio..CovidDeaths$
where location = 'France'
group by location,population

--Creating a Covid 19 in depth analysis of France (New Cases and Deaths against population)

select location,population,max(total_cases) as Total_Cases,max(total_deaths) as Total_Deaths, (max(total_deaths)/max(total_cases)*100) as Fatality_Rate,
(max(total_cases)/population)*100 as Pop_Infected_Covid, (max(total_deaths)/population)*100 as Covid_Deaths
from portfolio..CovidDeaths$
where location = 'France'
group by location,population


--Looking at Total Cases vs Total Deaths for France
--Shows liklihood of dying if you contract Covid 19 at any instance in time

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as fatality_rate
from portfolio..CovidDeaths$
where location = 'France'
order by 1,2


--Looking at Infection Rate in all Countries (Highest to Lowest)

select location,population,Max(total_cases) as Highest_Infection_Count,(max(total_cases)/population)*100 as Infection_Rate,
(max(total_deaths)/max(total_cases)*100) as Fatality_Rate,
(max(total_deaths)/population)*100 as Mortality_rate
from portfolio..CovidDeaths$
where continent is not null
group by location,population
order by Infection_Rate Desc

--Countries with highest Death Count per Location

select location,population,Max(cast(total_deaths as int)) as Total_Death_Count
from portfolio..CovidDeaths$
where continent is Not Null
group by location,population
order by Total_Death_Count Desc


-- Global Numbers
select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from portfolio..CovidDeaths$
where continent is Not Null

--Querying number of people getting hospitalized and in ICU

select location,date,population,
sum(convert(bigint,icu_patients)) Over (Partition by location order by location,date) as rolling_icu_patients,
sum(convert(bigint, hosp_patients)) over (partition by location order by location,date)as rolling_hosp_patients,
sum(convert(bigint,total_deaths)) Over (Partition by location Order by location, date) as rolling_deaths
from portfolio..CovidDeaths$
where continent is not Null

--Querying number of people getting vaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location,dea.date) as Rolling_Population_vaccinated
from portfolio..CovidDeaths$ dea
join portfolio..CovidVaccitnations$ vac
	On dea.location = vac.location
	And dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to get the percentage of people getting vaccinated

With population_vs_vaccination (continent, location,date,population,new_vaccinations,Rolling_Population_vaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location,dea.date) as Rolling_Population_vaccinated
from portfolio..CovidDeaths$ dea
join portfolio..CovidVaccitnations$ vac
	On dea.location = vac.location
	And dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rolling_Population_vaccinated/population)*100 as per_of_people_vac
from population_vs_vaccination

-- Temp Table

Drop table if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_Population_vaccinated numeric
)

Insert into #percentpopulationvaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location,dea.date) as Rolling_Population_vaccinated
from portfolio..CovidDeaths$ dea
join portfolio..CovidVaccitnations$ vac
	On dea.location = vac.location
	And dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (Rolling_Population_vaccinated/population)*100 as per_of_people_vac
from #percentpopulationvaccinated




-- Creating view to store data for later visualizations

Create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location,dea.date) as Rolling_Population_vaccinated
from portfolio..CovidDeaths$ dea
join portfolio..CovidVaccitnations$ vac
	On dea.location = vac.location
	And dea.date=vac.date
where dea.continent is not null
