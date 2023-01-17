select* from [project 1].dbo.[Data1];

select* from [project 1].dbo.[Data2];

--number of rows into our dataset
select count(*) from [project 1]..Data1
select count(*) from [project 1]..Data2

--dataset for jharkhand and bihar
select* from [project 1]..Data1 where [State ] IN('Jharkhand','Bihar')
--population of India 
select* from [project 1]..Data2
select sum(population) from [project 1]..Data2
--avg growth of india
select avg(growth)*100 avg_growth from [project 1]..Data1
--avg growth of particular states
select [State ],avg(growth)*100 avg_growth from [project 1]..Data1 group by [State ]
--avg sex ratio 
select [State ],round(avg(Sex_Ratio),0) avg_sexratio from [project 1]..Data1 group by [State ] order by avg_sexratio Desc
--literacy rate of states having greater than 90
select [State ],round(avg(literacy),0) avg_literacy from [project 1]..Data1
group by [State ] having round(avg(literacy),0)>90 order by avg_literacy Desc 
--top 3 state showing highest growth ratio
select top 3 [State ],avg(growth)*100 avg_growth from [project 1]..Data1 group by [State ] order by avg_growth Desc
--bottom 3 state showing highest growth ratio
select top 5[State ],round(avg(Sex_Ratio),0) avg_sexratio from [project 1]..Data1 group by [State ] order by avg_sexratio asc
--top and bottom 3 states in literacy rate

drop table if exists #topstates
create table #topstates
(state nvarchar(255),
topstates float)

insert into #topstates
select top 3 [State ],round(avg(literacy),0) avg_literacy from [project 1]..Data1 group by [State ] order by avg_literacy desc

select* from #topstates
----------------------------------------------
drop table if exists #bottomstates;
create table #bottomstates
(state nvarchar(255),
bottomstates float)

insert into #bottomstates
select top 3 [State ],round(avg(literacy),0) avg_literacy from [project 1]..Data1 group by [State ] order by avg_literacy asc

select* from #bottomstates
---union operator to join two set of output table results
select* from (
select top 3 [State ],round(avg(literacy),0) avg_literacy from [project 1]..Data1 group by [State ] order by avg_literacy desc)a
union
select* from(
select top 3 [State ],round(avg(literacy),0) avg_literacy from [project 1]..Data1 group by [State ] order by avg_literacy asc)b
----states starting with letter A
select distinct [State ] from [project 1]..Data1 where [State ] like 'a%'
--or operator
select distinct [State ] from [project 1]..Data1 where [State ] like 'a%' or [State ] like 'b%'
--and operator
select distinct [State ] from [project 1]..Data1 where [State ] like 'a%' and [State ] like '%m'

---joining both tables
select a.district,a.state,a.sex_ratio,b.population from [project 1]..Data1 a 
INNER JOIN [project 1]..Data2 b on a.District=b.District

---to get total no:of males and females
select c.district,c.state,c.population/(c.sex_ratio+1) males,(c.population*c.sex_ratio)/(c.sex_ratio+1) females from

(select a.district,a.state,a.sex_ratio/1000,b.population from [project 1]..Data1 a 
INNER JOIN [project 1]..Data2 b on a.District=b.District) c

---total literacy rate 
select c.state,sum(literate_people) total_literate_people,sum(illiterate_people) total_illiterate_people from
(select d.district,d.state,d.literacy_ratio*d.population literate_people,(1-d.literacy_ratio)*d.population illiterate_people from

(select a.district,a.state,a.Literacy/100 literacy_ratio,b.population from [project 1]..Data1 a 
INNER JOIN [project 1]..Data2 b on a.District=b.District)d)c
group by c.state

---population in previous census
select sum(m.previous_census_population),sum(current_census_population) from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+growth_rate),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth_rate,b.population from [project 1]..Data1 a 
INNER JOIN [project 1]..Data2 b on a.District=b.District)d)e
group by e.state)m

---population v/s area

select q.*,r.* from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+growth_rate),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth_rate,b.population from [project 1]..Data1 a 
INNER JOIN [project 1]..Data2 b on a.District=b.District)d)e
group by e.state)m)n)q INNER JOIN(

select '1' as keyy,z.* from
(select sum(area_km2) total_area from [project 1]..Data2)z)r on q.keyy=r.keyy
----------------------------------------------------------------------------------------------------------------------------------

select (g.total_area/g.previous_census_population) as previous_census_population_vs_area, (g.total_area/g.current_census_population) as current_census_population_vs_area from(
select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+growth_rate),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth_rate,b.population from [project 1]..Data1 a 
INNER JOIN [project 1]..Data2 b on a.District=b.District)d)e
group by e.state)m)n)q INNER JOIN(

select '1' as keyy,z.* from
(select sum(area_km2) total_area from [project 1]..Data2)z)r on q.keyy=r.keyy)g

--windows function
--output top 3 districts from each state with highest literacy rate

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc)rnk from [project 1]..Data1)a
where a.rnk in (1,2,3) order by state
