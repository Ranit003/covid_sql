
select * from Covid..CovidDeaths$ order by 3,4;

select * from Covid..CovidVaccinations$ order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population from Covid..CovidDeaths$ order by 1,2;


select location,date,total_cases,total_deaths, (total_deaths/total_cases) *100 as Deathpercentage from Covid..CovidDeaths$ 
where location like '%India%'
order by 1,2; 


select location,date,population,total_cases, (total_cases/population) *100 as Deathpercentage from Covid..CovidDeaths$ 
where location like '%India%'
order by 1,2;


select location,population, max(total_cases) as Highestpoulationinfected, max((total_cases/population))*100 as percentpopulationinfected
from Covid..CovidDeaths$ 
--where location like '%India%'
group by location, population
order by percentpopulationinfected desc



select location, max(total_deaths) as TotalDeaths
from Covid..CovidDeaths$ 
--where location like '%India%'
where continent is not null
group by location
order by TotalDeaths desc   



select location, max(cast(total_deaths as int)) as TotalDeaths
from Covid..CovidDeaths$ 
--where location like '%India%'
where continent is null
group by location
order by TotalDeaths desc


select sum(new_cases) as totalcases, sum(cast(new_deaths as int )) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Covid..CovidDeaths$ 
--where location like '%India%'
where continent is null
order by 1,2

-- looking At total population bs new vaccination
with popvsvac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert( int , vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingpeopleVaccinated/population)*100 
from popvsvac

--TEMP TABLE

DROP TABLE IF EXISTS #Percentpopulationvaccinated
create table #Percentpopulationvaccinated(
continent varchar(255),
loctaion varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,
)

insert into #Percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert( int , vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingpeopleVaccinated/population)*100 
from #Percentpopulationvaccinated


--creating views
create view percentpoulationvaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert( int , vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths$ dea
join Covid..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3