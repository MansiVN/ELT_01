Drop TABLE [dbo].[netflix_titles]

Create TABLE [dbo].[netflix_titles](
[show_id] [varchar](10) primary key,
[type] [varchar](10) null,
[title] [nvarchar](500) null,
[director] [varchar](250) null,
[cast] [varchar](1000) null,
[country] [varchar](150) null,
[date_added] [varchar](20) null,
[release_year] [int] null,
[rating] [varchar](10) null,
[duration] [varchar](10) null,
[listed_in] [varchar](100) null,
[description] [varchar](500) null,
)

-- removing duplicates in case any 
SELECT count(show_id)  FROM netflix_titles
group by show_id
having count(show_id)>1;

SELECT * from netflix_titles where title in (
SELECT title  FROM netflix_titles
group by title, type
having count(title)>1) 
order by title;

-- Found 5 duplicates from above query, hence considering only 1 appearance of each. 
--Earlier line count - 8807, post removing duplicates line count- 8802
-- Data type Conversion for date_added column
-- Null duration case handelled during final table creation in below query 
--FINAL TABLE

WITH CTE AS (
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY TITLE , TYPE ORDER BY SHOW_ID) AS RN 
FROM netflix_titles
)
SELECT Show_id, type, title, cast(date_added as date) as date_added, release_year, rating, 
case when duration is null then rating else duration end as duration, description
into Netflix_final
FROM CTE ;


Select * from netflix_final;


--NEW table for columns haing multiple commas separated values  ( Cast, country, directors, genre)

SELECT show_id, trim(value) as director
into netflix_directors 
from netflix_titles
cross apply string_split(director, ',');

SELECT show_id, trim(value) as Country
into netflix_countaries
from netflix_titles
cross apply string_split(Country, ',');

SELECT show_id, trim(value) as Genre
into netflix_genre
from netflix_titles
cross apply string_split(listed_in, ',');

SELECT show_id, trim(value) as cast
into netflix_cast
from netflix_titles
cross apply string_split(cast, ',');


-- Populate missing values in country , duration column

Insert into netflix_countaries 
select show_id, map.country from 
netflix_titles nt 
inner join 
(Select director, country from 
netflix_directors nd
inner join 
netflix_countaries nc
on nd.show_id=nc.show_id) map
on nt.director=map.director
where nt.country is null;

--------------------------




