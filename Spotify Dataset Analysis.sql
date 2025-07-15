-- Spotify Project Dataset

-- Creating Table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA on Dataset

SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT MIN(duration_min) FROM spotify;

-- Deleting Songs with Duration = 0

SELECT * FROM spotify 
WHERE duration_min = 0;

DELETE FROM spotify WHERE duration_min = 0;

SELECT COUNT(*) FROM spotify;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;

--------------------------------------------------------------------------
-- Data Analysis : Easy Category
--------------------------------------------------------------------------

-- Q1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify 
WHERE stream > 1000000000;

-- Q2. List all albums along with their respective artists.

SELECT DISTINCT album, artist FROM spotify;

-- Q3. Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(comments) AS total_comments 
FROM spotify WHERE licensed = true;

-- Q4. Find all tracks that belong to the album type single.

SELECT * FROM spotify WHERE album_type = 'single';

-- Q5. Count the total number of tracks by each artist.

SELECT artist, COUNT(track) AS num_tracks FROM spotify 
GROUP BY artist;

--------------------------------------------------------------------------
-- Data Analysis : Medium Category
--------------------------------------------------------------------------

-- Q6. Calculate the average danceability of tracks in each album.

SELECT album, AVG(danceability) FROM spotify 
GROUP BY album;

-- Q7. Find the top 5 tracks with the highest energy values.

SELECT track, MAX(energy) AS highest_energy 
FROM spotify 
GROUP BY track 
ORDER BY highest_energy DESC LIMIT 5;

-- Q8. List all tracks along with their views and likes where official_video = TRUE.

SELECT 
	track, 
	SUM(views) AS total_views, 
	SUM(likes) AS total_likes 
FROM spotify 
WHERE official_video = true 
GROUP BY track;

-- Q9. For each album, calculate the total views of all associated tracks.

SELECT album, track, SUM(views) AS total_views 
FROM spotify 
GROUP BY 1, 2;

-- Q10. Retrieve the track names that have been streamed on Spotify more than YouTube.

WITH T1 AS 
(SELECT 
	track, 
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) 
	AS streamed_on_spotify, 
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) 
	AS streamed_on_youtube 
FROM spotify 
GROUP BY 1
)

SELECT * FROM T1 
WHERE streamed_on_spotify > streamed_on_youtube 
AND streamed_on_youtube <> 0;

--------------------------------------------------------------------------
-- Data Analysis : Hard Category
--------------------------------------------------------------------------

-- Q11. Find the top 3 most-viewed tracks for each artist using window functions.

SELECT *
FROM 
(
	SELECT 
        artist, 
        track, 
        SUM(views), 
        DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS Rank 
    FROM spotify 
	GROUP BY 1, 2 
	ORDER BY 1, 3 DESC 
) AS ranked_tracks 
WHERE Rank <=3;

-- Q12. Write a query to find tracks where the liveness score is above the average.

SELECT track, liveness FROM spotify 
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- Q13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH CTE AS 
(SELECT 
	album, 
	MAX(energy) AS highest_energy, 
	MIN(energy) AS lowest_energy 
FROM spotify 
GROUP BY album) 

SELECT album, (highest_energy - lowest_energy) 
AS energy_difference FROM CTE 
ORDER BY 2 DESC;


