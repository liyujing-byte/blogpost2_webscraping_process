# Blog Post 2: Web Scraping for Actionable Insights
# Technical Skills in Data-Related Job Postings

library(rvest)
library(dplyr)
library(ggplot2)


# --------------------------------------------------
# 1. Function to scrape a job description
# --------------------------------------------------

get_description <- function(url) {
  Sys.sleep(1)
  
  read_html(url) %>%
    html_elements("main") %>%
    html_text2()
}


# --------------------------------------------------
# 2. Greenhouse job boards
# --------------------------------------------------

garner_url <- "https://job-boards.greenhouse.io/garnerhealth"
affirm_url <- "https://job-boards.greenhouse.io/affirm"
arcana_url <- "https://job-boards.greenhouse.io/arcanaanalytics"
scale_url <- "https://job-boards.greenhouse.io/scaleai"


# --------------------------------------------------
# 3. Function to collect job titles and links
# --------------------------------------------------

get_job_links <- function(board_url) {
  page <- read_html(board_url)
  
  links <- page %>%
    html_elements("a")
  
  data.frame(
    job_title = links %>% html_text2(),
    url = links %>% html_attr("href"),
    stringsAsFactors = FALSE
  )
}


# Collect listings from the four job boards

garner_jobs <- get_job_links(garner_url)
affirm_jobs <- get_job_links(affirm_url)
arcana_jobs <- get_job_links(arcana_url)
scale_jobs  <- get_job_links(scale_url)

# Remove location information from job titles

garner_jobs$clean_title <- sub("\\n.*", "", garner_jobs$job_title)
affirm_jobs$clean_title <- sub("\\n.*", "", affirm_jobs$job_title)
arcana_jobs$clean_title <- sub("\\n.*", "", arcana_jobs$job_title)
scale_jobs$clean_title  <- sub("\\n.*", "", scale_jobs$job_title)


# --------------------------------------------------
# 4. Select data-related job postings
# --------------------------------------------------

garner_titles <- c(
  "Data Engineer III",
  "Senior Data Engineer",
  "Staff Machine Learning Operations Engineer",
  "Senior Data Analyst, Business Insights",
  "Data Analyst II, Business Insights",
  "Data Analyst III, Reporting & Analytics",
  "Senior Data Analyst, Reporting"
)

garner_sample <- garner_jobs %>%
  filter(
    grepl(
      "^(Data Engineer III|Senior Data Engineer|Staff Machine Learning Operations Engineer|Senior Data Analyst, Business Insights|Data Analyst II, Business Insights|Data Analyst III, Reporting & Analytics|Senior Data Analyst, Reporting)",
      job_title
    )
  )


# Affirm: select the relevant postings

affirm_sample <- affirm_jobs %>%
  filter(
    grepl(
      "^(Quantitative Analyst II \\(Capital Structuring & Analytics\\)|Machine Learning Engineer II \\(Underwriting ML\\)|Senior Machine Learning Engineer \\(Fraud\\))",
      job_title
    )
  )


# Remove duplicate US/Canada versions of the same role

affirm_sample$clean_title <- sub("\\n.*", "", affirm_sample$job_title)

affirm_clean <- affirm_sample %>%
  distinct(clean_title, .keep_all = TRUE)


# Arcana Analytics: select the relevant postings

arcana_sample <- arcana_jobs %>%
  filter(
    grepl(
      "^(Senior Data Engineer|Senior Data Scientist|Staff Software Engineer \\(Data Platform\\)|Data Analyst|Data Associate|Portfolio Data Analyst)",
      job_title
    )
  )


# Scale AI: select the relevant postings

scale_sample <- scale_jobs %>%
  filter(
    grepl(
      "^(Machine Learning Engineer, Platform|Senior/Staff Machine Learning Research Engineer, General Agents, Enterprise GenAI|Staff/Senior Machine Learning Research Engineer, Intelligent Systems)",
      job_title
    )
  )


# --------------------------------------------------
# 5. Combine the selected job postings
# --------------------------------------------------

garner_sample$company <- "Garner Health"
affirm_clean$company <- "Affirm"
arcana_sample$company <- "Arcana Analytics"
scale_sample$company <- "Scale AI"

jobs_clean <- bind_rows(
  garner_sample %>% select(job_title, url, company),
  affirm_clean %>% select(job_title, url, company),
  arcana_sample %>% select(job_title, url, company),
  scale_sample %>% select(job_title, url, company)
)


# --------------------------------------------------
# 6. Scrape job descriptions
# --------------------------------------------------

jobs_clean$description <- sapply(
  jobs_clean$url,
  get_description
)


# --------------------------------------------------
# 7. Save the cleaned job data
# --------------------------------------------------

write.csv(
  jobs_clean,
  "data/jobs_clean.csv",
  row.names = FALSE
)


# --------------------------------------------------
# 8. Detect technical skills
# --------------------------------------------------

jobs_clean$SQL <- grepl("\\bSQL\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$Python <- grepl("\\bPython\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$R <- grepl("\\bR\\b", jobs_clean$description)
jobs_clean$Excel <- grepl("\\bExcel\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$Tableau <- grepl("\\bTableau\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$PowerBI <- grepl("\\bPower\\s*BI\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$Snowflake <- grepl("\\bSnowflake\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$dbt <- grepl("\\bdbt\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$AWS <- grepl("\\bAWS\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$Azure <- grepl("\\bAzure\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$GCP <- grepl("\\bGCP\\b|Google Cloud", jobs_clean$description, ignore.case = TRUE)
jobs_clean$Git <- grepl("\\bGit\\b", jobs_clean$description, ignore.case = TRUE)
jobs_clean$MachineLearning <- grepl("machine learning", jobs_clean$description, ignore.case = TRUE)
jobs_clean$Cpp <- grepl("C++", jobs_clean$description, fixed = TRUE)


# --------------------------------------------------
# 9. Create skill summary
# --------------------------------------------------

skill_names <- c(
  "SQL", "Python", "R", "Excel",
  "Tableau", "PowerBI", "Snowflake", "dbt",
  "AWS", "Azure", "GCP", "Git",
  "MachineLearning", "Cpp"
)

skill_counts <- colSums(jobs_clean[, skill_names])

skill_summary_final <- data.frame(
  Skill = skill_names,
  Count = as.numeric(skill_counts)
)

skill_summary_final$Percentage <-
  skill_summary_final$Count / nrow(jobs_clean) * 100

skill_summary_final <- skill_summary_final %>%
  arrange(desc(Percentage))

write.csv(
  skill_summary_final,
  "data/skill_summary.csv",
  row.names = FALSE
)


# --------------------------------------------------
# 10. Create and save figure
# --------------------------------------------------

skill_summary_final$Skill_label <- skill_summary_final$Skill

skill_summary_final$Skill_label[
  skill_summary_final$Skill_label == "PowerBI"
] <- "Power BI"

skill_summary_final$Skill_label[
  skill_summary_final$Skill_label == "MachineLearning"
] <- "Machine Learning"

skill_summary_final$Skill_label[
  skill_summary_final$Skill_label == "Cpp"
] <- "C++"

skills_plot <- ggplot(
  skill_summary_final,
  aes(x = reorder(Skill_label, Percentage),
      y = Percentage)
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Technical Skills Mentioned in Data-Related Job Postings",
    subtitle = "19 unique roles across Garner Health, Affirm, Arcana Analytics, and Scale AI",
    x = NULL,
    y = "Percentage of Job Postings (%)",
    caption = "Source: Public Greenhouse job postings; duplicate regional listings removed."
  ) +
  ylim(0, 70) +
  theme_minimal()

skills_plot

ggsave(
  "figures/skills_plot.png",
  plot = skills_plot,
  width = 10,
  height = 6,
  dpi = 300
)