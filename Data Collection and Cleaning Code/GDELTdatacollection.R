# Faiz Essa
# GDELT Data Collection
# 01/26/2023

# importing packages
library(tidyverse)
library(bigrquery)

# bigrquery setup
bq_auth(email = "faiz.essa@gmail.com")
billing <- "whatsappgdelt"


# COUNTRIES
# We would like to construct a panel of collective action events daily across
# COUNTRIES We will focus on ``protest" events.
# SQL query
sql <- 
  "SELECT ActionGeo_CountryCode, SQLDATE, EventCode, COUNT(*) 
FROM `gdelt-bq.gdeltv2.events` 
WHERE EventRootCode = '14' 
AND Year >= 2013
GROUP BY ActionGeo_CountryCode, SQLDATE, EventCode
"
# data import
gdelt.data <- bq_project_query(billing, sql)
gdelt.table <- bq_table_download(gdelt.data)

# 21.73 gb, 1TB limit per month  (for free)
# w/ the last query 2(21.73 gb have been used total)

# save raw data
write_rds(gdelt.table, "Data/GDELT/raw_gdelt_data_country.rds")

rm(list=ls())

# INDIA 
billing <- "whatsappgdelt"
# We would like to construct a panel of collective action events daily across
# indian districts. We will focus on ``protest" events.
# SQL query
sql <- 
  "SELECT ActionGeo_ADM2Code, SQLDATE, EventCode, COUNT(*) 
FROM `gdelt-bq.gdeltv2.events` 
WHERE EventRootCode = '14' 
AND ActionGeo_CountryCode = 'IN'
AND Year >= 2013
GROUP BY ActionGeo_ADM2Code, SQLDATE, EventCode
"

# data import
gdelt.data <- bq_project_query(billing, sql)
gdelt.table <- bq_table_download(gdelt.data)

# 21.73 gb, 1TB limit per month  (for free)

# save raw data
write_rds(gdelt.table, "Data/GDELT/raw_gdelt_data.rds")


