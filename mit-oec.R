# load required packages
library(readr)
library(dplyr)
library(jsonlite)

# load country, product (https://en.wikipedia.org/wiki/Standard_International_Trade_Classification) data
# source:
# http://atlas.media.mit.edu/en/resources/data/

countries <- read_tsv("raw_data/country_names.tsv")
products <- read_tsv("raw_data/products_sitc_rev2.tsv")

######################
# use http://atlas.media.mit.edu/en/ API to download data for total Mexico exports and imports by year, SITC

# years
years <- c(1962:2016)

# data frome to hold data
mexico_sitc <- data_frame()

# loop through years and countries
for (y in years) {
  print(y)
  tmp <- fromJSON(paste0("http://atlas.media.mit.edu/sitc/export/",y,"/mex/all/show/?output_depth=sitc_id_len.6"))
  tmp <- tmp$data
  mexico_sitc <- bind_rows(mexico_sitc,tmp)
}
rm(y,tmp)

# join to product names and BEC categories, rename product variable
mexico_sitc <- left_join(mexico_sitc,products, by=c("sitc_id"="id")) %>%
  rename(product = name) 

# write to csv
write_csv(mexico_sitc,"processed_data/mexico_sitc.csv",na="")

######################
# scrape data for Mexico exports by country and year, SITC

# data frome to hold data
mexico_country_sitc <- data_frame()

# loop through years and countries
for (y in years) {
  for (c in countries$id_3char) {
    print(paste0(y, " ", c))
    tmp <- fromJSON(paste0("http://atlas.media.mit.edu/sitc/export/",y,"/mex/",c,"/show/?output_depth=sitc_id_len.6"))
    tmp <- tmp$data
    mexico_country_sitc <- bind_rows(mexico_country_sitc,tmp)
    }
}
rm(c,y,tmp)

# join to product and country names, rename product and country variables
mexico_country_sitc <- left_join(mexico_country_sitc,products, by=c("sitc_id"="id"))
mexico_country_sitc <- left_join(mexico_country_sitc,countries, by=c("dest_id"="id")) %>%
  rename(product = name.x,
         country = name.y)

# filter out data for country "World"
mexico_country_sitc <- mexico_country_sitc %>%
  filter(country != "World")

# write to csv
write_csv(mexico_country_sitc,"processed_data/mexico_country_sitc.csv",na="")

# list of products
product_list <- mexico_country_sitc %>%
  select(product) %>%
  unique()

# write to csv
write_csv(product_list,"processed_data/product_list.csv",na="")

# save environment
save.image("mit-oec.RData")

