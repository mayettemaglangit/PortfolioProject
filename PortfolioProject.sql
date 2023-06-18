select *
From PortfolioProject. .CovidDeaths$
where continent is not null
order by 3,4


select *
From PortfolioProject. .CovidVaccinations$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject. .CovidDeaths$
where continent is not null
order by 1,2


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject. .CovidDeaths$
Where location like '%philippines%'
and continent is not null
order by 1,2

select location, population, Max(total_cases) as HighestPopulationInfectionCount, Max((total_cases/population))*100 as HighestPopulationInfected
from PortfolioProject. .CovidDeaths$
--Where location like '%philippines%'
group by location, population
order by HighestPopulationInfected desc

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject. .CovidDeaths$
--Where location like '%philippines%'
Where continent is not null
Group by Location
order by TotalDeathCount desc



Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject. .CovidDeaths$
--Where location like '%philippines%'
Where continent is  null
Group by location
order by TotalDeathCount desc


--*Global Numbers

select SUM( new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject. .CovidDeaths$
--Where location like '%philippines%'
where continent is not null
--group by date
order by 1,2 

Select death.continent, death.location,death.population, death.date, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location,
death.date) as TotalPeopleVaccinated
From PortfolioProject. .CovidDeaths$ death
join PortfolioProject. .CovidVaccinations$ vac
     --(TotalPeopleVaccinated/Population)*100
       on death.location = vac.location
	   and death.date = vac.date
where death.continent is not null
order by 2,3


--Using CTE

with PopvsVac (continent,location,date,population,new_vaccinations,TotalPeopleVaccinated)
as
(
Select death.continent, death.location, death.date,death.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location,
death.date)
From PortfolioProject. .CovidDeaths$ death
join PortfolioProject. .CovidVaccinations$ vac
     --(TotalPeopleVaccinated/Population)*100
       on death.location = vac.location
	   and death.date = vac.date
where death.continent is not null
--order by 2,3
)
Select*, (TotalPeopleVaccinated/Population)*100
From PopvsVac


--Use Temp_Table

DROP Table if exists #PercentagePopulationVacc
Create Table #PercentagePopulationVacc
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 TotalPeopleVaccinated numeric
 )

Insert into #PercentagePopulationVacc
Select death.continent, death.location,death.date,death.population,death.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location,
death.date) as TotalPeopleVaccinated
From PortfolioProject. .CovidDeaths$ death
join PortfolioProject. .CovidVaccinations$ vac
     --(TotalPeopleVaccinated/Population)*100
       on death.location = vac.location
	   and death.date = vac.date
--where death.continent is not null
--order by 2,3

Select*, (TotalPeopleVaccinated/Population)*100
From #PercentagePopulationVacc


--DROP TABLE #PercentagePopulationVacc;

Create View PercentagePopulationVacc as
Select death.continent, death.location,death.date,death.population,death.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.location Order by death.location,
death.date) as TotalPeopleVaccinated
From PortfolioProject. .CovidDeaths$ death
join PortfolioProject. .CovidVaccinations$ vac
     --(TotalPeopleVaccinated/Population)*100
       on death.location = vac.location
	   and death.date = vac.date
where death.continent is not null
--order by 2,3

Select *
From PercentagePopulationVacc