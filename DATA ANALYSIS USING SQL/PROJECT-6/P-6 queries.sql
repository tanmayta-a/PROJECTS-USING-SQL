CREATE TABLE NETFLIX(
show_id varchar(6),
type varchar(350),
title varchar(150),
director varchar(250),
casts varchar(1000),
country varchar(150),
date_added	varchar(50),
release_year integer,	
rating	varchar(10),
duration varchar(15),
listed_in varchar(300),
description varchar(250)
);
drop table  if exists netflix;

select * from netflix;

select count(*) as total_Content from netflix;


select distinct type from netflix;


--BUSINESS PROBLEMS

--TASK-1 Count the number of movies VS tv shows.

select type,count(*) as counted
from netflix group by type;

--TASK-2 Find the most common rating for movies and TV shows
select type,rating 
from 
(
select type,
       rating,
	   count(*),
	   rank() over (partition by type order by count(*) desc) as ranking
	   from netflix
	   group by  1,2 ) as t1
	   where ranking=1;
	  

--TASK-3 List all movies released in a specific year(e.g.,2020)


select * from netflix;
select *  from netflix where
type='Movie' and release_year=2020; 


--Find the top 5 countries with the most content on netflix

select 
 unnest(string_to_array(country,',')) as new_country,
 count(show_id) as total_content
 from netflix 
 group by 1
 order by 2 desc limit 5;

--Find the longest movie

select * from netflix where type='Movie' and duration=(select max(duration) from netflix);


--TASK-6: Find content added in the last 5 years

select *
FROM netflix
where to_date(date_added, 'Month DD,YYYY') >= current_date - INTERVAL '5 years';

--TASK-7:  Find all the movies/tv shows by director 'Rajiv Chilaka'

SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

--TASK-8: List all tv shows with more than 5 seasons 

select * from netflix
where 
type='TV Show'
and
split_part(duration,' ',1)::numeric >5;

--TASK-9: Count the number of content items in each genre.

select 
unnest(string_to_array(listed_in,',')) as genre,
count(show_id) as total_content
from netflix 
group by 1;


--TASK-10: Find each year and the average numbers of content release by India on netflix
--return top 5 year with highest avg content release

select 
extract(year from to_date(date_added,'Month DD,YYYY')) as year,
count(*)as yearly_content,
round(
count(*)::numeric/(select count(*) from netflix where country ='India')::numeric * 100,2)
as avg_content_per_year
from netflix 
where country='India'
group by 1;

--TASK-11: List all the movies thart are documentaries

select * from netflix where listed_in ilike '%documentaries';


--TASK-12:Find all content without a director

select * from netflix where director is null;

--TASK-13: Find how many movies actor'Salman Khan' appeared in last 10 years

select * from netflix where 
casts ilike '%Salman Khan%' 
AND
release_year > extract (year from current_date) - 10;

--TASK-14: Find the top 10 actors who have appeared in the highest number of movies produced in India.


select 
unnest(string_to_array( casts, ',' )) as actors,
count(*) as total_content
from netflix
where country = 'India'
group by 1
order by 2 desc
limit 10;

/*TASK-15: Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
           the description field. Label content containing these keywords as 'Bad' and all other   
		   content as 'Good'. Count how many items fall into each category.*/



with new_table as 
(select *,
case 
when description ilike '%kill%' or
     description ilike '%violence%' then 'bad content '
else 'good content '
end as category
from netflix)
select category,
       count(*) as content_count 
	   from new_table
group by 1;











