### 🍿 BigQuery-Based IMDb Data Pipeline for Analytics and ML

## Project Background

In today’s streaming-driven entertainment industry, studios and platforms must make high-stakes content investment decisions amid rising production costs and intense competition.

This project leverages big data analytics and machine learning on **large-scale IMDb data** to transform raw information on movies, cast, crew, and audience feedback into investment-focused insights.

Insights and recommendations are provided across the following key areas:
- **Success drivers:** genre, runtime, release timing
- Audience reception and performance
- **Temporal trends** in ratings and production volume
- **Predictive signals** for content quality
- Data-driven guidance for content investment and greenlight decisions

The SQL queries utilized to load the data and perform initial quality checks can be found [here](https://github.com/kietngwork/imdb-big-data-analytics-ml/blob/main/SQL%20queries/data_loading_and_preprocessing.sql)

The SQL queries utilized to perform exploratory data analysis [here](https://github.com/kietngwork/imdb-big-data-analytics-ml/blob/main/SQL%20queries/eda_movie_reviews.sql)

The SQL queries utilized to The SQL queries utilized to clean, organize and prepare data for the ML model can be found [here](https://github.com/kietngwork/imdb-big-data-analytics-ml/blob/main/SQL%20queries/data_preprocessing.sql)

---

## Data Structure and Intial Checks

IMDb's database structure as seen below consists of 5 tables: name_basics, title_basics, title_crew, title_principles, title_ratings with a total row count of **21+ million records**.

<img width="6000" height="3375" alt="schema" src="https://github.com/user-attachments/assets/86f54802-9e97-4923-8521-0aae6c881b72" />

Prior to beginning the analysis, a variety of checks were conducted for quality control and familiarization with the datasets. The SQL queries utilized to load the data and perform initial quality checks can be found [here](https://github.com/kietngwork/imdb-big-data-analytics-ml/blob/main/SQL%20queries/data_loading_and_preprocessing.sql). 

A detailed description of the data sources, tables, and key fields is provided [here](https://github.com/kietngwork/imdb-big-data-analytics-ml/blob/main/data/data_description.txt).

---
## Executive Summary
