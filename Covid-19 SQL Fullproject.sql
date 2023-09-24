/*
           Covid-19 Data Exploration 
		   
 Skills: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types, Creating Views

 */
 --Data Tables
 Select *
From [Sql Project]..CovidDeath
   Where continent is not null 
   order by 3,4

   Select*
   From [Sql Project]..CovidVacination
 Where continent is not null 
   order by 3,4
    
 --Selecting Data
  
 Select location, date, total_cases, new_cases, total_deaths, population
  From [Sql Project]..CovidDeath
 Where continent is not null 
 order by 1,2
  
   --Total Cases vs Total Death
    Select location,date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100  as DeathPercentage
  From [Sql Project]..CovidDeath
 Where continent is not null and
 location  like '%akistan%'
 order by 1,2
  
 --Total Cases per population

 Select location,date, total_cases, (total_cases/population)*100  as percentPopulationInfected
  From [Sql Project]..CovidDeath
 Where continent is not null and
 location  like '%akistan%'
 order by 1,2

 --Total Deaths per population
 Select location,date, total_cases,total_deaths, (total_deaths/population)*100  as DeathPercentPopulation
  From [Sql Project]..CovidDeath
 Where continent is not null and
 location  like '%akistan%'
 order by 1,2
  
 -- Countries with Highest Death Count per Population
 
 Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
 From [Sql Project]..CovidDeath
 Where continent is not null 
 Group by Location
 order by TotalDeathCount desc
  
 -- GLOBAL NUMBERS
  
 Select SUM(new_cases+total_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
 From [Sql Project]..CovidDeath
where continent is not null 
order by 1,2
 
--Hospital Paitents vs ICU Paitent
Select location,date,icu_patients,hosp_patients
from [Sql Project]..CovidDeath
where continent is not null
order by 1,2

-----------------------------------------------------------------------------------------------------------------------------------------------
   --People Fully Vacinated vs Population
    
Select  dea.continent, dea.location, dea.date, dea.population,new_vaccinations,people_fully_vaccinated, SUM(convert(bigint,vac.new_vaccinations))
OVER( partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Sql Project]..CovidDeath dea
join  [Sql Project]..CovidVacination Vac
on  dea.continent=Vac.continent
  Where dea.continent is not null and
 dea.location  like '%akistan%'
order by 1,2 
 
 --People Fully Vacinated
  
 Select location,date,people_fully_vaccinated
 from [Sql Project]..CovidVacination
 Where continent is not null and
 location  like '%akistan%'
 order by 1,2
  
 --Creating CTE 

  
 With Pop_vs_Vac as(
  Select dea.continent, dea.location,dea.population,new_vaccinations,people_fully_vaccinated, SUM(convert(bigint,vac.new_vaccinations))
 OVER( partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 From [Sql Project]..CovidDeath dea
 join [Sql Project]..CovidVacination Vac
 on dea.continent=Vac.continent
  Where dea.continent is not null and
 dea.location  like '%akistan%'
) 
 
 Select *
from Pop_vs_Vac

-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Sql Project]..CovidDeath dea
join [Sql Project]..CovidVacination Vac
on dea.continent=Vac.continent

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

---------------------------------------------------------------------------------------------------------------------------------------

--Creating Views for later Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.population,new_vaccinations,people_fully_vaccinated, SUM(convert(bigint,vac.new_vaccinations))
OVER( partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Sql Project]..CovidDeath dea
join [Sql Project]..CovidVacination Vac
on dea.continent=Vac.continent
 Where dea.continent is not null 

 --Creating Views
 Create View Globalnumbers as
 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Sql Project]..CovidDeath
where continent is not null 
--order by 1,2

Select*
from Globalnumbers

----Views for later Visualization
Create View deathpercentpopulation  as
Select location,date, total_cases,total_deaths, (total_deaths/population)*100  as DeathPercentPopulation
 From [Sql Project]..CovidDeath
Where continent is not null and
location  like '%akistan%'
--order by 1,2

--- Creating View
Create View Highestdeathcount  as
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Sql Project]..CovidDeath
Where continent is not null 
Group by Location

Select*
from Highestdeathcount

