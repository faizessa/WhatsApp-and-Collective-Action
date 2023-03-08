# Faiz Essa
# GDELT Data Cleaning
# 01/16/2023

rm(list=ls())

# importing packages
library(tidyverse)
library(haven)
library(lubridate)

# INDIA
# data import 
raw_data <- readRDS("Data/GDELT/raw_gdelt_data.rds")

# renaming variables and fixing dates
gdelt_data_1_16 <- raw_data %>%
  rename(GAULADM2Code = ActionGeo_ADM2Code,
         count = f0_) %>%
  mutate(date = as.Date(as.character(SQLDATE), "%Y%m%d"))

# CONSTRUCTING PANEL

# creates list of dates from 2013-2023
dates <- seq.POSIXt(ISOdate(2013,1,1),ISOdate(2023,1,1), by="day")

# creates list of unique adm2 codes
GAULADM2Code <- gdelt_data_1_16 %>%
  distinct(GAULADM2Code)

# creates list of unique event types
EventCode <- gdelt_data_1_16 %>%
  distinct(EventCode)

# creating `blank` panel
dates <- data.frame(date=dates) %>%
  mutate(date = as.Date(date)) %>%
  crossing(GAULADM2Code) %>%
  crossing(EventCode) %>%
  arrange(GAULADM2Code, EventCode, date)

# merging to add protest counts
gdelt_panel_1_16 <- gdelt_data_1_16 %>%
  select(date, GAULADM2Code, EventCode, count) %>%
  right_join(dates, by = c("date", "GAULADM2Code", "EventCode")) %>%
  mutate(count = ifelse(is.na(count), 0, count))

# formatting as panel
gdelt_panel_1_16 <- gdelt_panel_1_16 %>%
  pivot_wider(names_from = EventCode, values_from = count) %>%
  arrange(GAULADM2Code, date)

# creating variables for analysis
gdelt_panel_1_16 <- gdelt_panel_1_16 %>%
  rename(c141 = "141",
         c145 = "145",
         c143 = "143", 
         c144 = "144",
         c140 = "140",
         c1411 = "1411",
         c142 = "142",
         c1412 = "1412", 
         c1413 = "1413",
         c1431 = "1431",
         c1414 = "1414") %>%
  rowwise() %>%
  mutate(total_protests = sum(c141, c145, c143, c144, c140, c1411,
                              c142, c1412, c1413, c1431, c1414),
         demonstration = sum(c141, c1411, c1412, c1413, c1414),
         hunger_strike = c142,
         strike = sum(c143, c1431),
         violent = c145,
         non_violent = sum(c141, c143, c144, c140, c1411,
                           c142, c1412, c1413, c1431, c1414)) 
gdelt_panel_1_16 <- gdelt_panel_1_16 %>%
  mutate(year = year(date),
         month = month(date))

gdelt_panel_1_16 <- gdelt_panel_1_16 %>%
  mutate(forwarding_rule = ifelse(date >= "2018-07-18", 1, 0))

# file to large to commit to git, stored in dropbox folder
write_csv(gdelt_panel_1_16,
          "Users/faizessa/Dropbox/WhatsApp and Conflict/Data/GDELT/gdelt_panel_1_16.csv", 
          na = "")

# ACROSS COUNTRIES 
rm(list = ls())

# data import 
raw_data <- readRDS("Data/GDELT/raw_gdelt_data_country.rds")

# renaming variables and fixing dates
gdelt_data_1_16 <- raw_data %>%
  rename(country = ActionGeo_CountryCode,
         count = f0_) %>%
  mutate(date = as.Date(as.character(SQLDATE), "%Y%m%d"))

# CONSTRUCTING PANEL

# creates list of dates from 2013-2023
dates <- seq.POSIXt(ISOdate(2013,1,1),ISOdate(2023,1,1), by="day")

# countrycodes
countrycodes <- gdelt_data_1_16 %>%
  distinct(country)

# creates list of unique event types
EventCode <- gdelt_data_1_16 %>%
  distinct(EventCode)

# creating `blank` panel
dates <- data.frame(date=dates) %>%
  mutate(date = as.Date(date)) %>%
  crossing(countrycodes) %>%
  crossing(EventCode) %>%
  arrange(country, EventCode, date)

# merging to add protest counts
gdelt_panel_1_16 <- gdelt_data_1_16 %>%
  select(date, country, EventCode, count) %>%
  right_join(dates, by = c("date", "country", "EventCode")) %>%
  mutate(count = ifelse(is.na(count), 0, count))

# formatting as panel
gdelt_panel_1_16 <- gdelt_panel_1_16 %>%
  pivot_wider(names_from = EventCode, values_from = count) %>%
  arrange(country, date)

# creating variables for analysis
gdelt_panel_1_16 <- gdelt_panel_1_16 %>%
  rename(c141 = "141",
         c145 = "145",
         c143 = "143", 
         c144 = "144",
         c140 = "140",
         c1411 = "1411",
         c142 = "142",
         c1412 = "1412", 
         c1413 = "1413",
         c1431 = "1431",
         c1414 = "1414") %>%
  rowwise() %>%
  mutate(total_protests = sum(c141, c145, c143, c144, c140, c1411,
                              c142, c1412, c1413, c1431, c1414),
         demonstration = sum(c141, c1411, c1412, c1413, c1414),
         hunger_strike = c142,
         strike = sum(c143, c1431),
         violent = c145,
         non_violent = sum(c141, c143, c144, c140, c1411,
                           c142, c1412, c1413, c1431, c1414)) 

gdelt_panel_1_16 <- gdelt_panel_1_16 %>%
  mutate(year = year(date),
         month = month(date))

gdelt_panel_1_16 <- gdelt_panel_1_16 %>%
  mutate(forwarding_rule = ifelse(date >= "2018-07-18", 1, 0))

# file to large to commit to git, stored in dropbox folder
write_csv(gdelt_panel_1_16,
          "Users/faizessa/Dropbox/WhatsApp and Conflict/Data/GDELT/gdelt_panel_countries.csv", 
          na = "")

