### 🍿 BigQuery-Based IMDb Data Pipeline for Analytics and ML

<img width="575" height="290" alt="image" src="https://github.com/user-attachments/assets/94acaa29-96da-4856-9f47-6d96545b468a" />

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

**Key Findings**

- Runtime and quality are positively related: Films with runtimes between **120–150 minutes** achieve average ratings of approximately **8.0–9.0**, compared to ~6.0–7.0 for shorter films (<100 minutes). Longer films also appear more frequently in the “successful” category.
- Genre concentration matters: **Drama** (~2,800 films), **Comedy** (~2,500 films), and **Action** (~1,800 films) dominate the success landscape, while genres such as Sci-Fi (~700 films) and Animation (~800 films) contribute significantly fewer high-performing titles, indicating an uneven distribution of success across genres.
- Success rates fluctuate over time but **trend upward**: The percentage of successful films ranges from ~21% to ~30% between 2000 and 2022, with noticeable cyclical dips and peaks, but **an overall upward trajectory of roughly +8–9 percentage points over the period**.
- Seasonality influences outcomes: **Summer and Fall** releases achieve success rates of approximately **27–28%**, compared to ~22–24% for Spring and Winter releases, highlighting the commercial advantage of peak viewing seasons.
- Release window has a strong impact: Films released during **blockbuster windows (~34%**) and **award seasons (~33%)** significantly outperform off-season releases (~15–18%), demonstrating that timing alone can nearly double the likelihood of success.
- Director track record is a strong signal: Directors with **historical success rates above 70–80%** consistently produce films with **average ratings above 8.5–9.0**, while directors below 30% historical success average closer to 6.0–6.5 in ratings.
- Franchise advantage is substantial: Franchise films achieve a **48%** success rate, compared to just 19% for original films, more than a 2× increase—underscoring the strong commercial value of established intellectual property.

<img width="6000" height="2787" alt="imdb_findings" src="https://github.com/user-attachments/assets/f8c8c535-e30c-4844-aa5b-b852ec672583" />

Collectively, these findings highlight the importance of building a predictive model capable of estimating the success rate of upcoming films, enabling investors to make informed, data-driven decisions and manage financial risk before committing capital.

