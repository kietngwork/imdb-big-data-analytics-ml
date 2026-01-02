-- Show All Columns for All Tables
SELECT 
  table_name,
  column_name
FROM 
  `bigquery-public-data.imdb.INFORMATION_SCHEMA.COLUMNS`
ORDER BY 
  column_name;

-- Find Shared Columns Across Multiple Tables
SELECT 
  column_name,
  COUNT(DISTINCT table_name) AS table_count,
  ARRAY_AGG(DISTINCT table_name) AS tables_with_column
FROM 
  `bigquery-public-data.imdb.INFORMATION_SCHEMA.COLUMNS`
GROUP BY 
  column_name
HAVING 
  COUNT(DISTINCT table_name) >= 1
ORDER BY 
  table_count DESC;

  -- Preview data
SELECT * FROM `movie-review-project-466218.movie_dataset.imdb_prepared` LIMIT 100;

-- Pivot-Like View of Columns per Table
SELECT
  column_name,
  MAX(CASE WHEN table_name = 'title_basics' THEN 1 ELSE 0 END) AS title_basics,
  MAX(CASE WHEN table_name = 'title_ratings' THEN 1 ELSE 0 END) AS title_ratings,
  MAX(CASE WHEN table_name = 'title_akas' THEN 1 ELSE 0 END) AS title_akas,
  MAX(CASE WHEN table_name = 'title_episode' THEN 1 ELSE 0 END) AS title_episode,
  MAX(CASE WHEN table_name = 'title_crew' THEN 1 ELSE 0 END) AS title_crew,
  MAX(CASE WHEN table_name = 'title_principals' THEN 1 ELSE 0 END) AS title_principals,
  MAX(CASE WHEN table_name = 'name_basics' THEN 1 ELSE 0 END) AS name_basics,
  MAX(CASE WHEN table_name = 'reviews' THEN 1 ELSE 0 END) AS reviews,
  COUNT(DISTINCT table_name) AS table_count
FROM 
  `bigquery-public-data.imdb.INFORMATION_SCHEMA.COLUMNS`
GROUP BY 
  column_name
ORDER BY 
  table_count DESC;

  #Sample Data Exploration-all
SELECT table_name, column_name
FROM `bigquery-public-data.imdb.INFORMATION_SCHEMA.COLUMNS`
WHERE table_schema = 'imdb'
ORDER BY table_name;


-- Sample Exploration-each table
SELECT * FROM `bigquery-public-data.imdb.title_basics` LIMIT 5;
SELECT * FROM `bigquery-public-data.imdb.title_ratings` LIMIT 5;
SELECT * FROM `bigquery-public-data.imdb.title_crew` LIMIT 5;
SELECT * FROM `bigquery-public-data.imdb.title_principals` LIMIT 5;
SELECT * FROM `bigquery-public-data.imdb.name_basics` LIMIT 5;

-- Filtered Schema View-5 tables
SELECT 
  table_name, 
  column_name
FROM 
  `bigquery-public-data.imdb.INFORMATION_SCHEMA.COLUMNS`
WHERE 
  table_schema = 'imdb'
  AND table_name IN (
    'title_basics', 
    'title_ratings', 
    'title_crew', 
    'title_principals', 
    'name_basics'
  )
ORDER BY 
  table_name, 
  column_name;

-- Create imdb_prepared table by joining the 5 ERD tables
CREATE OR REPLACE TABLE `movie-review-project-466218.movie_dataset.imdb_prepared` AS
SELECT
  b.tconst,
  b.primary_title,
  b.title_type,
  b.genres,
  b.start_year,
  b.runtime_minutes,
  r.average_rating,
  r.num_votes,
  c.directors,
  c.writers,
  p.nconst,
  p.category,
  p.job,
  p.characters,
  n.primary_name,
  n.primary_profession,
  n.birth_year,
  n.death_year
FROM
  `bigquery-public-data.imdb.title_basics` AS b
LEFT JOIN
  `bigquery-public-data.imdb.title_ratings` AS r ON b.tconst = r.tconst
LEFT JOIN
  `bigquery-public-data.imdb.title_crew` AS c ON b.tconst = c.tconst
LEFT JOIN
  `bigquery-public-data.imdb.title_principals` AS p ON b.tconst = p.tconst
LEFT JOIN
  `bigquery-public-data.imdb.name_basics` AS n ON p.nconst = n.nconst;

  -- Overview
SELECT * FROM `movie-review-project-466218.movie_dataset.imdb_prepared` LIMIT 5;

-- Count rows and columns
--Rows
SELECT COUNT(*) AS total_rows FROM `movie-review-project-466218.movie_dataset.imdb_prepared`;
--Columns
SELECT COUNT(*) AS total_columns
FROM `movie-review-project-466218.movie_dataset.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'imdb_prepared';

# the frequency of each genre
SELECT 
  genres,
  COUNT(*) AS count
FROM 
  `movie-review-project-466218.movie_dataset.imdb_prepared`
GROUP BY 
  genres
ORDER BY 
  count DESC;

-- Which genres have the highest average ratings (Excel-style summary)
WITH exploded_genres AS (
  SELECT
    tconst,
    average_rating,
    TRIM(genre) AS genre
  FROM
    `movie-review-project-466218.movie_dataset.imdb_prepared`,
    UNNEST(SPLIT(genres, ',')) AS genre
)
SELECT
  genre,
  COUNT(*) AS num_titles,
  ROUND(AVG(average_rating), 2) AS avg_rating
FROM
  exploded_genres
WHERE
  average_rating IS NOT NULL AND genre IS NOT NULL
GROUP BY
  genre
ORDER BY
  avg_rating DESC
LIMIT 20;


-- Which movie types (title_type) are rated 5 the most?
SELECT
  title_type,
  COUNT(*) AS count_rated_5
FROM
  `movie-review-project-466218.movie_dataset.imdb_prepared`
WHERE
  average_rating = 5
GROUP BY
  title_type
ORDER BY
  count_rated_5 DESC;


-- Is there a correlation between runtime and rating?
SELECT
  runtime_minutes,
  AVG(average_rating) AS avg_rating,
  COUNT(*) AS num_titles
FROM
  `movie-review-project-466218.movie_dataset.imdb_prepared`
WHERE
  runtime_minutes IS NOT NULL
  AND runtime_minutes > 0
  AND average_rating IS NOT NULL
GROUP BY
  runtime_minutes
ORDER BY
  runtime_minutes;


-- Plot average rating by runtime bin
SELECT
  CASE
    WHEN runtime_minutes BETWEEN 0 AND 60 THEN '0-60'
    WHEN runtime_minutes BETWEEN 61 AND 90 THEN '61-90'
    WHEN runtime_minutes BETWEEN 91 AND 120 THEN '91-120'
    WHEN runtime_minutes BETWEEN 121 AND 150 THEN '121-150'
    WHEN runtime_minutes BETWEEN 151 AND 180 THEN '151-180'
    ELSE '180+'
  END AS runtime_bin,
  ROUND(AVG(average_rating), 2) AS avg_rating,
  COUNT(*) AS title_count
FROM
  `movie-review-project-466218.movie_dataset.imdb_prepared`
WHERE
  average_rating IS NOT NULL
  AND runtime_minutes IS NOT NULL
GROUP BY
  runtime_bin
ORDER BY
  runtime_bin;


# Crew & Cast Impact: Director Ratings
    # Aggregate average rating by director:
    SELECT
  c.directors,
  COUNT(*) AS num_movies,
  ROUND(AVG(r.average_rating), 2) AS avg_director_rating
FROM
  `bigquery-public-data.imdb.title_crew` AS c
JOIN
  `bigquery-public-data.imdb.title_ratings` AS r
ON
  c.tconst = r.tconst
WHERE
  c.directors IS NOT NULL
GROUP BY
  c.directors
HAVING
  num_movies >= 5
ORDER BY
  avg_director_rating DESC
LIMIT 10;


-- Step 1: Get top-rated directors (5+ movies)
WITH top_directors AS (
  SELECT
    c.directors,
    ROUND(AVG(r.average_rating), 2) AS avg_director_rating,
    COUNT(*) AS movie_count
  FROM
    `bigquery-public-data.imdb.title_crew` AS c
  JOIN
    `bigquery-public-data.imdb.title_ratings` AS r
  ON
    c.tconst = r.tconst
  WHERE
    c.directors IS NOT NULL
  GROUP BY
    c.directors
  HAVING
    movie_count >= 5
),

-- Step 2: Join with imdb_prepared and classify
movies_with_director_quality AS (
  SELECT
    m.tconst,
    m.primary_title,
    m.genres,
    m.average_rating,
    m.num_votes,
    td.avg_director_rating,
    CASE
      WHEN td.avg_director_rating >= 7.5 THEN 'Top-rated'
      ELSE 'Other'
    END AS director_quality
  FROM
    `movie-review-project-466218.movie_dataset.imdb_prepared` AS m
  LEFT JOIN
    top_directors AS td
  ON
    m.directors = td.directors
  WHERE
    m.average_rating IS NOT NULL
)

-- Step 3: Compare ratings
SELECT
  director_quality,
  COUNT(*) AS num_movies,
  ROUND(AVG(average_rating), 2) AS avg_rating
FROM
  movies_with_director_quality
GROUP BY
  director_quality;


#Do famous actors relate to better r
-- Step 1: Identify famous actors
WITH famous_actors AS (
  SELECT
    p.nconst,
    ROUND(AVG(r.average_rating), 2) AS avg_actor_rating,
    COUNT(*) AS movie_count
  FROM
    `bigquery-public-data.imdb.title_principals` AS p
  JOIN
    `bigquery-public-data.imdb.title_ratings` AS r
  ON
    p.tconst = r.tconst
  WHERE
    p.category IN ('actor', 'actress')
  GROUP BY
    p.nconst
  HAVING
    movie_count >= 10 AND avg_actor_rating >= 7.5
),

-- Step 2: Join with imdb_prepared and classify movies
movies_with_actor_quality AS (
  SELECT
    ip.tconst,
    ip.average_rating,
    CASE
      WHEN fa.nconst IS NOT NULL THEN 'Famous actor'
      ELSE 'Other'
    END AS actor_quality
  FROM
    `movie-review-project-466218.movie_dataset.imdb_prepared` AS ip
  LEFT JOIN
    `bigquery-public-data.imdb.title_principals` AS p
  ON
    ip.tconst = p.tconst
  LEFT JOIN
    famous_actors AS fa
  ON
    p.nconst = fa.nconst
)

-- Step 3: Aggregate result
SELECT
  actor_quality,
  COUNT(*) AS num_movies,
  ROUND(AVG(average_rating), 2) AS avg_rating
FROM
  movies_with_actor_quality
WHERE
  average_rating IS NOT NULL
GROUP BY
  actor_quality
ORDER BY
  avg_rating DESC;



#Temporal Trends – How have ratings changed over decades?
SELECT
  CONCAT(CAST(FLOOR(start_year / 10) * 10 AS STRING), 's') AS decade,
  COUNT(*) AS num_movies,
  ROUND(AVG(average_rating), 2) AS avg_rating
FROM
  `movie-review-project-466218.movie_dataset.imdb_prepared`
WHERE
  start_year IS NOT NULL
  AND average_rating IS NOT NULL
GROUP BY
  decade
ORDER BY
  decade;



SELECT
  MIN(average_rating) AS lowest_rating,
  MAX(average_rating) AS highest_rating
FROM
  `movie-review-project-466218.movie_dataset.imdb_prepared`
WHERE
  average_rating IS NOT NULL;
# Compare history genre vs movies genre 
SELECT
  comparison_group,
  COUNT(*) AS num_titles,
  SUM(num_votes) AS total_ratings,
  ROUND(AVG(average_rating), 2) AS avg_rating
FROM (
  SELECT
    *,
    CASE
      WHEN genres LIKE '%History%' THEN 'History Genre'
      WHEN title_type = 'movie' THEN 'Movie Type'
      ELSE 'Other'
    END AS comparison_group
  FROM
    `movie-review-project-466218.movie_dataset.imdb_prepared`
  WHERE
    average_rating IS NOT NULL
    AND num_votes IS NOT NULL
)
WHERE comparison_group IN ('History Genre', 'Movie Type')
GROUP BY comparison_group
ORDER BY avg_rating DESC;



