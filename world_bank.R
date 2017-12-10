# load required packages
library(WDI)
library(stringr)
library(dplyr)
library(readr)

# list of indicators
indic_list <- c("NE.EXP.GNFS.ZS","NY.GDP.MKTP.CD")

# get data from World Bank API
indicators <- WDI(indicator=indic_list, country="all", start=1960, end=2016, extra=T, cache=NULL)

# filter for countries only
indicators <- indicators %>%
  filter(income != "Aggregates") %>%
  mutate(year = as.integer(year)) %>%
  arrange(country, year)

# some cleaning
indicators$region <- gsub("all income levels","", indicators$region)
indicators$region <- gsub("\\(|\\)","", indicators$region)
indicators$region <- str_trim(indicators$region)
indicators$income <- gsub(": nonOECD","", indicators$income)
indicators$income <- gsub(": OECD","", indicators$income)

# rename variables
indicators <- indicators %>%
  rename(exports_pc_gdp = NE.EXP.GNFS.ZS,
         gdp = NY.GDP.MKTP.CD) %>%
  mutate(id_3char = tolower(iso3c))

# write csv
write_csv(indicators,"processed_data/indicators.csv", na="")


