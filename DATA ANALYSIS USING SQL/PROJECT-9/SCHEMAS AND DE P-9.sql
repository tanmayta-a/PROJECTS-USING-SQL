--CREATING TABLE SPOTIFY

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

ALTER TABLE SPOTIFY
alter COLUMN Stream type bigint;


ALTER TABLE SPOTIFY
alter COLUMN Views type bigint;

select * from spotify;



-- Basic EDA

select * from spotify;
select count(*) from spotify;

select count(distinct artist) from spotify;

select count(distinct track) from spotify;

select distinct album from spotify;
select count(distinct album) from spotify;

select count(distinct album_type) from spotify;

select count(distinct title) from spotify;

select distinct channel from spotify;
select count(distinct channel) from spotify;

select count(distinct most_played_on) from spotify;

select min(energy) from spotify;
select max(energy) from spotify;

select min(duration_min) from spotify;
select max(duration_min) from spotify;

select count(*) from spotify where duration_min = 0;
delete from spotify where duration_min = 0


select distinct most_playedon from spotify;









