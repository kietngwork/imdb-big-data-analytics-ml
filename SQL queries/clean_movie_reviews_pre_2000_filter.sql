CREATE OR REPLACE TABLE `movie-review-project-466218.movie_dataset.imdb_prepared_clean` AS
SELECT *
FROM `movie-review-project-466218.movie_dataset.imdb_prepared`
WHERE 
  tconst IS NOT NULL
  AND title_type IS NOT NULL
  AND genres IS NOT NULL
  AND start_year IS NOT NULL
  AND start_year BETWEEN 1900 AND 2025  
  AND average_rating IS NOT NULL
  AND runtime_minutes IS NOT NULL
  AND runtime_minutes BETWEEN 1 AND 400;  

SELECT 
  COUNT(*) AS total_rows,
  COUNT(DISTINCT TO_JSON_STRING(t)) AS unique_rows,
  COUNT(*) - COUNT(DISTINCT TO_JSON_STRING(t)) AS duplicate_count
FROM `movie-review-project-466218.movie_dataset.imdb_prepared_clean` AS t;

SELECT
  *,
  COUNT(*) AS duplicate_count
FROM `movie-review-project-466218.movie_dataset.imdb_prepared_clean`
GROUP BY
  tconst, title_type, primary_title, genres, start_year, runtime_minutes,
  average_rating, num_votes, directors, writers,
  nconst, category, job, characters,
  primary_name, primary_profession, birth_year, death_year
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 1000;

CREATE OR REPLACE TABLE `movie-review-project-466218.movie_dataset.imdb_prepared_clean` AS
SELECT DISTINCT *
FROM `movie-review-project-466218.movie_dataset.imdb_prepared_clean`;


