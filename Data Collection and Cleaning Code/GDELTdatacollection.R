# Faiz Essa
# GDELT Data Collection
# 03/08/2023

# importing packages
library(tidyverse)
library(bigrquery)

# bigrquery setup
# authorize bigquery below if not authorized
# bq_auth(email = "faiz.essa@gmail.com")
billing <- "whatsappgdelt"

# INDIA 
# We would like to construct a panel of collective action events daily across
# indian districts. We will focus on ``protest" events.
# SQL query
sql <- 
  "SELECT ActionGeo_ADM1Code, EventRootCode, SQLDATE, COUNT(*) 
FROM `gdelt-bq.gdeltv2.events` 
WHERE (EventRootCode = '14' OR EventRootCode = '18' OR EventRootCode = '19')
AND (ActionGeo_CountryCode = 'IN')
AND Year >= 2015
GROUP BY ActionGeo_ADM1Code, EventRootCode, SQLDATE
"

# data import
gdelt.data <- bq_project_query(billing, sql)
gdelt.table <- bq_table_download(gdelt.data)

# 23.11 gb, 1TB limit per month  (for free)

# save raw data
write_rds(gdelt.table, "Data/GDELT/RawGDELT_IndiaStates.rds")

# clear data 
rm(list=ls())




