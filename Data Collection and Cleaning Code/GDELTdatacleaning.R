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

# list of event codes 
event_codes <- raw_data %>%
  distinct(EventRootCode)

# creates list of unique adm2 codes
GAULADM1Code <- gdelt_data %>%
  distinct(GAULADM1Code)

# creating `blank` panel
dates <- data.frame(date=dates) %>%
  mutate(date = as.Date(date)) %>%
  crossing(GAULADM1Code) %>%
  crossing(event_codes) %>%
  arrange(GAULADM1Code, EventRootCode, date)

# merging to add protest counts
gdelt_panel <- gdelt_data %>%
  right_join(dates, by = c("date", "EventRootCode", "GAULADM1Code")) %>%
  mutate(count = ifelse(is.na(count), 0, count)) %>%
  relocate(date, .before = "count") %>%
  arrange(GAULADM1Code, EventRootCode, date) %>%
  pivot_wider(names_from = EventRootCode, values_from = count) %>%
  rename(protest_count = "14", assault_count = "18", fight_count = "19")

# aggregate panel to week level
gdelt_panel_weekly <- gdelt_panel %>%
  mutate(week = week(date), year = year(date)) %>%
  group_by(GAULADM1Code, year, week) %>%
  summarize(protest_count = sum(protest_count),
            assault_count = sum(assault_count),
            fight_count = sum(fight_count)) %>%
  ungroup() %>%
  group_by(year, week) %>%
  mutate(time = cur_group_id()) %>%
  ungroup() %>% 
  mutate(protest_indicator = ifelse(protest_count > 0, 1, 0),
         assault_indicator = ifelse(assault_count > 0, 1, 0),
         fight_indicator = ifelse(fight_count > 0, 1, 0),
         log_protests = log(protest_count + 1),
         log_assaults = log(assault_count + 1),
         log_fights = log(fight_count + 1)) %>%
  relocate(time, .before = "protest_count")

# merging in whatsapp data
gtrends_es_panel <- WhatsAppInterest %>%
  select(GAULADM1Code, WhatsAppInterest) %>%
  right_join(gdelt_panel_weekly, by = "GAULADM1Code", multiple = "all") %>%
  filter(!is.na(WhatsAppInterest))

# aggregate panel to month level
gdelt_panel_monthly <- gdelt_panel %>%
  mutate(month = month(date), year = year(date)) %>%
  group_by(GAULADM1Code, year, month) %>%
  summarize(protest_count = sum(protest_count),
            assault_count = sum(assault_count),
            fight_count = sum(fight_count)) %>%
  ungroup() %>%
  group_by(year, month) %>%
  mutate(time = cur_group_id()) %>%
  ungroup() %>% 
  mutate(protest_indicator = ifelse(protest_count > 0, 1, 0),
         assault_indicator = ifelse(assault_count > 0, 1, 0),
         fight_indicator = ifelse(fight_count > 0, 1, 0),
         log_protests = log(protest_count + 1),
         log_assaults = log(assault_count + 1),
         log_fights = log(fight_count + 1)) %>%
  relocate(time, .before = "protest_count")

# merging in whatsapp data
gtrends_es_panel_monthly <- WhatsAppInterest %>%
  select(GAULADM1Code, WhatsAppInterest) %>%
  right_join(gdelt_panel_monthly, by = "GAULADM1Code", multiple = "all") %>%
  filter(!is.na(WhatsAppInterest))

# saving data 
write_csv(gtrends_es_panel, "Data/GDELT/gtrends_es_panel.csv")
write_csv(gtrends_es_panel_monthly, "Data/GDELT/gtrends_es_panel.csv")

# clearing
rm(list=ls())
