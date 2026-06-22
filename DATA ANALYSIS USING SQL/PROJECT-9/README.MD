# Spotify Advanced SQL Project and Query Optimization P-6
Project Category: Advanced
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

![Spotify Logo](https://github.com/tanmayta-a/PROJECTS-USING-SQL/blob/main/DATA%20ANALYSIS%20USING%20SQL/PROJECT-9/spotify.png)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql

DROP TABLE IF EXISTS spotify;

CREATE TABLE SPOTIFY(
Artist VARCHAR (200),
Track VARCHAR(200),
AlbuM VARCHAR(200),
Album_type VARCHAR(100),
Danceability FLOAT,
Energy FLOAT,
Loudness FLOAT,
Speechiness FLOAT,
Acousticness FLOAT,
Instrumentalness FLOAT,
Liveness FLOAT,
Valence FLOAT,	
Tempo FLOAT,
Duration_min FLOAT,
Title VARCHAR(200),
Channel VARCHAR(200),
Views INT,
Likes INT,
Comments INT,
Licensed BOOL,
official_video BOOL,
Stream BIGINT,
EnergyLiveness FLOAT,
most_playedon VARCHAR(200)
);
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 2. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 3. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 Practice Questions

### Easy Level

1. Retrieve the names of all tracks that have more than 1 billion streams.

```sql
select track from spotify where stream>1000000000;
```
2. List all albums along with their respective artists.

```sql
select   distinct album,artist from spotify;

```
3. Get the total number of comments for tracks where `licensed = TRUE`.

```sql
select sum(comments) from spotify where licensed = 'true'

```
4. Find all tracks that belong to the album type `single`.

```sql
SELECT TRACK FROM SPOTIFY WHERE ALBUM_TYPE='single'
```
5. Count the total number of tracks by each artist.

```sql
select artist,count(*) from spotify group by 1 order by 2 desc;

```

### Medium Level

6. Calculate the average danceability of tracks in each album.

```sql
select album, avg(danceability) from spotify group by 1 order by 2 desc;

```

7. Find the top 5 tracks with the highest energy values.

```sql
select track,max(energy) from spotify  group by 1 order by 2 desc limit 5;

```
8. List all tracks along with their views and likes where `official_video = TRUE`.

```sql
select track,
        sum(views) as total_views,
        sum(likes) as total_likes 
		from spotify where official_video='true'
		group by 1
		order by 1,2;
```

9. For each album, calculate the total views of all associated tracks.

```sql
select  album,track,
       sum(views) as total_views
	   from spotify 
	   group by 1,2
	   order by 3 desc
```
10. Retrieve the track names that have been streamed on Spotify more than YouTube.

```sql 
select * from 
(select track ,
coalesce(sum(case when most_playedon='Spotify' then stream end),0) as streamed_on_spotify,
coalesce(sum(case when most_playedon='Youtube' then stream end),0) as streamed_on_youtube
from spotify 
group by 1)as t1
where streamed_on_spotify > streamed_on_youtube
and streamed_on_youtube <>0

```
### Advanced Level

11. Find the top 3 most-viewed tracks for each artist using window functions.

```sql
with most_viewed_tracks as
(select artist,track,
sum(views) as most_viewed,
dense_rank() over(partition by artist order by sum(views) desc) as rank
from spotify 
group by 1,2
order by 1,3 desc
)
select * from most_viewed_tracks where rank<=3

```
12. Write a query to find tracks where the liveness score is above the average.

```sql
select track,artist,liveness from spotify where liveness>(select avg(liveness) from spotify);

```
13. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**

```sql
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC
```
   
14. Find tracks where the energy-to-liveness ratio is greater than 1.2.

```sql
select track,energy/liveness as energy_to_liveness_ratio 
from spotify where energy/liveness>1.2

```

15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

```sql
 select track,views,likes,
 sum(likes)  over (order by views desc)as cum_sum
from spotify
```

---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7.404 ms**
        - Planning time (P.T.): **1.016 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/tanmayta-a/PROJECTS-USING-SQL/blob/main/DATA%20ANALYSIS%20USING%20SQL/PROJECT-9/query%20plan%20before.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.115 ms**
        - Planning time (P.T.): **0.167 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/tanmayta-a/PROJECTS-USING-SQL/blob/main/DATA%20ANALYSIS%20USING%20SQL/PROJECT-9/query%20plan%20after.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/tanmayta-a/PROJECTS-USING-SQL/blob/main/DATA%20ANALYSIS%20USING%20SQL/PROJECT-9/graph%20view%201.png)
      ![Performance Graph](https://github.com/tanmayta-a/PROJECTS-USING-SQL/blob/main/DATA%20ANALYSIS%20USING%20SQL/PROJECT-9/graph-before.png)
      ![Performance Graph](https://github.com/tanmayta-a/PROJECTS-USING-SQL/blob/main/DATA%20ANALYSIS%20USING%20SQL/PROJECT-9/graph-after.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL (via Homebrew, Docker, or direct installation)





