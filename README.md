# Web Scraping for Actionable Insights

## Project Overview

This repository contains the code, data, and figure used for my second blog post, which examines technical skills mentioned in data-related job postings.

The analysis uses the `rvest` package in R to scrape publicly available job postings from the Greenhouse career pages of four companies:

- Garner Health
- Affirm
- Arcana Analytics
- Scale AI

The final sample contains 19 unique data-related job postings. The analysis identifies how frequently technical skills such as SQL, Python, Snowflake, dbt, AWS, Tableau, Power BI, and machine learning are mentioned in these postings.

## Repository Structure

- `code/analysis.R` — complete R code for web scraping, data cleaning, skill detection, analysis, and figure generation.
- `data/jobs_clean.csv` — cleaned dataset containing the 19 unique job postings and their descriptions.
- `data/skill_summary.csv` — summary of technical skill frequencies and percentages.
- `figures/skills_plot.png` — final figure showing the percentage of job postings mentioning each technical skill.

## Reproducing the Analysis

The analysis requires R and the following packages:

- `rvest`
- `dplyr`
- `ggplot2`

To reproduce the results, open the R project and run:

`code/analysis.R`

The script collects the job postings, removes duplicate regional listings, extracts job descriptions, identifies technical skill mentions, calculates skill frequencies, and generates the final figure.

Because the data are scraped from live job boards, the available postings may change over time. Therefore, rerunning the scraping code in the future may produce different results.

## Data Source

Job postings were collected from publicly accessible Greenhouse career pages. The scraping process does not bypass logins, CAPTCHAs, paywalls, or other access restrictions. A one-second delay is included between requests to individual job pages.

## Main Finding

In this sample, SQL and Python were the most frequently mentioned technical skills, each appearing in 12 of the 19 unique job postings (63.2%). Snowflake appeared in 36.8% of postings, while dbt and machine learning were each mentioned in 31.6%.