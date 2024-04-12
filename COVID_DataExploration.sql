-- COVID Deaths

Select *
From CovidDeaths$

Select 
    [location]
    ,[date]
    ,total_cases
    ,new_cases
    ,total_deaths
    ,[population]
From CovidDeaths$
Order by 1, 2

-- Total Cases vs Total Deaths
Select 
    [location]
    ,[date]
    ,total_cases
    ,total_deaths
    ,(total_deaths/total_cases)*100 as Percent_of_Deaths
From CovidDeaths$
Where [location] like '%states%'
Order by 1, 2


-- Total Cases vs Population
Select 
    [location]
    ,[date]
    ,total_cases
    ,[population]
    ,(total_cases/[population])*100 as Cases_to_Population
From CovidDeaths$
Where [location] like '%states%'
Order by 1, 2


-- Countries w/ Highest Infection Rate to Population
Select 
    [location]
    ,Max(total_cases) as Highest_Infection_Count
    ,[population]
    ,Max((total_cases/[population]))*100 as PercentPopulationInfected
From CovidDeaths$
--Where [location] like '%states%'
Group by [location], [population]
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select 
    [location]
    ,Max(cast(total_deaths as int)) as Total_Death_Count
From CovidDeaths$
Where continent is not null
Group by [location]
Order by 2 desc

-- By Continent Breakdown
Select 
    [location]
    ,Max(cast(total_deaths as int)) as Total_Death_Count
From CovidDeaths$
Where continent is null
Group by [location]
Order by 2 desc

-- Continents w/ Highest Death Count
Select 
    [continent]
    ,Max(cast(total_deaths as int)) as Total_Death_Count
From CovidDeaths$
Where continent is not null
Group by [continent]
Order by 2 desc

-- Global Data
Select 
    [date]
    ,Sum(new_cases) as Total_Cases
    ,Sum(cast(new_deaths as int)) as total_Deaths
    ,Sum(cast(new_deaths as int))/sum(new_cases)*100 as Percent_of_Deaths
From CovidDeaths$
Where continent is not null
Group by date
Order by 1,2


-- COVID Vacciations

-- Total Population vs Vacciations

Select 
    dea.continent
    ,dea.[location]
    ,dea.[date]
    ,dea.population
    ,vac.new_vaccinations
    ,SUM(convert(int, vac.new_vaccinations)) over 
        (Partition by dea.location
            Order by dea.location, dea.date) as Rolling_Total_Vaccinations
From CovidDeaths$ dea
JOIN CovidVaccinations$ vac ON
    dea.[location] = vac.[location] AND
    dea.[date] = vac.[date]
Where dea.continent is not null
Order by 2,3

--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Total_Vacciations)
as
(Select 
    dea.continent
    ,dea.[location]
    ,dea.[date]
    ,dea.population
    ,vac.new_vaccinations
    ,SUM(convert(int, vac.new_vaccinations)) over 
        (Partition by dea.location
            Order by dea.location, dea.date) as Rolling_Total_Vaccinations
From CovidDeaths$ dea
JOIN CovidVaccinations$ vac ON
    dea.[location] = vac.[location] AND
    dea.[date] = vac.[date]
Where dea.continent is not null
)
Select *, (Rolling_Total_Vacciations/Population)*100 as Vaccination_per_Pop
From PopvsVac
Order by 2,3

-- Use Temp Table
Create Table #PercentPopVac
(
    Continent nvarchar(255)
    ,Location nvarchar(255)
    ,Date datetime
    ,Popluation numeric
    ,New_vaccinations numeric
    ,Rolling_Total_Vaccinations numeric
)

Insert Into #PercentPopVac
Select 
    dea.continent
    ,dea.[location]
    ,dea.[date]
    ,dea.population
    ,vac.new_vaccinations
    ,SUM(convert(int, vac.new_vaccinations)) over 
        (Partition by dea.location
            Order by dea.location, dea.date) as Rolling_Total_Vaccinations
From CovidDeaths$ dea
JOIN CovidVaccinations$ vac ON
    dea.[location] = vac.[location] AND
    dea.[date] = vac.[date]
Where dea.continent is not null

Select *, (Rolling_Total_Vaccinations/Popluation)*100 as Vaccination_per_Pop
From #PercentPopVac
Order by 2,3


-- Creating View for Visualizations
Create View PercentPopulationVaccinated as

Select 
    dea.continent
    ,dea.[location]
    ,dea.[date]
    ,dea.population
    ,vac.new_vaccinations
    ,SUM(convert(int, vac.new_vaccinations)) over 
        (Partition by dea.location
            Order by dea.location, dea.date) as Rolling_Total_Vaccinations
From CovidDeaths$ dea
JOIN CovidVaccinations$ vac ON
    dea.[location] = vac.[location] AND
    dea.[date] = vac.[date]
Where dea.continent is not null
