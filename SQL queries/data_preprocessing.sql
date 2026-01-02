CREATE OR REPLACE TABLE `disney-movie-success-predict.disney.disney_features_full_3` AS

WITH directors AS (
  SELECT
    p.tconst,
    p.nconst
  FROM
    `bigquery-public-data.imdb.title_principals` p
  WHERE
    p.category = 'director'
),

base_movies AS (
  SELECT
    b.tconst,
    b.primary_title,
    b.start_year,
    b.runtime_minutes,
    b.genres,
    b.is_adult,
    r.average_rating,
    r.num_votes,

    -- Label: success
    CASE
      WHEN (r.average_rating * SAFE.LOG10(r.num_votes)) >= 25 THEN 1
      ELSE 0
    END AS success,

    -- Feature: genre_count
    ARRAY_LENGTH(SPLIT(b.genres, ',')) AS genre_count,

    -- Feature: sequel_flag
    REGEXP_CONTAINS(LOWER(b.primary_title), r' [0-9]{1,2}$') AS sequel_flag,

    -- Feature: release_decade
    CONCAT(CAST(FLOOR(b.start_year / 10) * 10 AS STRING), 's') AS release_decade,

    -- Feature: release_season (via hash of tconst)
    CASE
      WHEN MOD(ABS(FARM_FINGERPRINT(b.tconst)), 12) + 1 IN (12, 1, 2) THEN 'Winter'
      WHEN MOD(ABS(FARM_FINGERPRINT(b.tconst)), 12) + 1 IN (3, 4, 5) THEN 'Spring'
      WHEN MOD(ABS(FARM_FINGERPRINT(b.tconst)), 12) + 1 IN (6, 7, 8) THEN 'Summer'
      ELSE 'Fall'
    END AS release_season,

    -- Feature: release_window
    CASE
      WHEN MOD(ABS(FARM_FINGERPRINT(b.tconst)), 12) + 1 IN (6, 7, 12) THEN 'Blockbuster'
      WHEN MOD(ABS(FARM_FINGERPRINT(b.tconst)), 12) + 1 IN (11, 1, 2) THEN 'AwardSeason'
      ELSE 'OffSeason'
    END AS release_window,

    -- Feature: log_votes
    SAFE.LOG10(r.num_votes) AS log_votes,

    -- Feature: franchise_flag
    CASE
      WHEN REGEXP_CONTAINS(LOWER(b.primary_title), r'(avengers|star wars|frozen|toy story|cars|marvel|pixar|iron man)') THEN 1
      ELSE 0
    END AS franchise_flag

  FROM
    `bigquery-public-data.imdb.title_basics` b
  JOIN
    `bigquery-public-data.imdb.title_ratings` r
  ON
    b.tconst = r.tconst
  WHERE
    b.title_type = 'movie'
    AND b.start_year >= 2000
    AND b.runtime_minutes IS NOT NULL
    AND b.genres IS NOT NULL
    AND r.num_votes >= 1000
),

movie_with_directors AS (
  SELECT
    m.*,
    d.nconst
  FROM base_movies m
  LEFT JOIN directors d ON m.tconst = d.tconst
),

director_stats AS (
  SELECT
    nconst,
    SAFE_DIVIDE(SUM(success), COUNT(*)) AS director_success_rate
  FROM movie_with_directors
  GROUP BY nconst
),

movie_with_scores AS (
  SELECT
    m.*,
    ds.director_success_rate
  FROM movie_with_directors m
  LEFT JOIN director_stats ds ON m.nconst = ds.nconst
),

director_avg AS (
  SELECT
    tconst,
    IFNULL(AVG(director_success_rate), 0) AS avg_director_success_rate
  FROM movie_with_scores
  GROUP BY tconst
),

final_movie_features AS (
  SELECT
    m.tconst,
    m.primary_title,
    m.start_year,
    m.runtime_minutes,
    m.genres,
    m.is_adult,
    m.average_rating,
    m.num_votes,
    m.success,
    m.genre_count,
    m.sequel_flag,
    m.release_decade,
    m.release_season,
    m.release_window,
    m.log_votes,
    m.franchise_flag,
    d.avg_director_success_rate,

    -- One-hot encoded genres (cast to INT64)
    CAST(REGEXP_CONTAINS(genres, r'Action') AS INT64) AS is_action,
    CAST(REGEXP_CONTAINS(genres, r'Comedy') AS INT64) AS is_comedy,
    CAST(REGEXP_CONTAINS(genres, r'Drama') AS INT64) AS is_drama,
    CAST(REGEXP_CONTAINS(genres, r'Romance') AS INT64) AS is_romance,
    CAST(REGEXP_CONTAINS(genres, r'Thriller') AS INT64) AS is_thriller,
    CAST(REGEXP_CONTAINS(genres, r'Sci-Fi') AS INT64) AS is_scifi,
    CAST(REGEXP_CONTAINS(genres, r'Animation') AS INT64) AS is_animation,
    CAST(REGEXP_CONTAINS(genres, r'Horror') AS INT64) AS is_horror,

    -- One-hot release_season (cast to INT64)
    CAST(release_season = 'Winter' AS INT64) AS season_Winter,
    CAST(release_season = 'Spring' AS INT64) AS season_Spring,
    CAST(release_season = 'Summer' AS INT64) AS season_Summer,
    CAST(release_season = 'Fall' AS INT64) AS season_Fall,

    -- One-hot release_decade (cast to INT64)
    CAST(release_decade = '2000s' AS INT64) AS decade_2000s,
    CAST(release_decade = '2010s' AS INT64) AS decade_2010s,
    CAST(release_decade = '2020s' AS INT64) AS decade_2020s,

    -- One-hot release_window (cast to INT64)
    CAST(release_window = 'Blockbuster' AS INT64) AS window_Blockbuster,
    CAST(release_window = 'AwardSeason' AS INT64) AS window_AwardSeason,
    CAST(release_window = 'OffSeason' AS INT64) AS window_OffSeason

  FROM movie_with_scores m
  LEFT JOIN director_avg d ON m.tconst = d.tconst
)

SELECT * FROM final_movie_features;
