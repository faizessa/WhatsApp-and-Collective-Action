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
raw_data <- readRDS("Data/GDELT/RawGDELT_IndiaStates.rds")
WhatsAppInterest <- read_csv("Data/WhatsAppInterest.csv")

# renaming variables and fixing dates
gdelt_data <- raw_data %>%
  rename(GAULADM1Code = ActionGeo_ADM1Code,
         count = f0_) %>%
  mutate(date = as.Date(as.character(SQLDATE), "%Y%m%d")) %>%
  select(!SQLDATE)

# CONSTRUCTING PANEL

# creates list of dates from 2013-2023
dates <- seq.POSIXt(ISOdate(2015,1,1),ISOdate(2023,1,1), by="day")

# creates list of unique adm2 codes
GAULADM1Code <- gdelt_data %>%
  distinct(GAULADM1Code)

# creating `blank` panel
dates <- data.frame(date=dates) %>%
  mutate(date = as.Date(date)) %>%
  crossing(GAULADM1Code) %>%
  arrange(GAULADM1Code, date)

# merging to add protest counts
gdelt_panel <- gdelt_data %>%
  right_join(dates, by = c("date", "GAULADM1Code")) %>%
  mutate(count = ifelse(is.na(count), 0, count)) %>%
  relocate(date, .before = "count") %>%
  arrange(GAULADM1Code, date)

# aggregate panel to week level
gdelt_panel_weekly <- gdelt_panel %>%
  mutate(week = week(date), year = year(date)) %>%
  group_by(GAULADM1Code, year, week) %>%
  summarize(protest_count = sum(count)) %>%
  ungroup() %>%
  group_by(year, week) %>%
  mutate(time = cur_group_id()) %>%
  ungroup() %>% 
  relocate(time, .before = "protest_count")

# merging in whatsapp data
gtrends_es_panel <- WhatsAppInterest %>%
  select(GAULADM1Code, WhatsAppInterest) %>%
  right_join(gdelt_panel_weekly, by = "GAULADM1Code") %>%
  filter(!is.na(WhatsAppInterest))

# saving data 
write_csv(gtrends_es_panel, "Data/GDELT/gtrends_es_panel.csv")

# clearing
rm(list=ls())
