#load library
library(tidyverse)
library(reshape2)

####################################
#311 data
####################################
#load data
#https://data.cityofchicago.org/Service-Requests/311-Service-Requests/v6vf-nfxy
df <- read.csv("C:/Users/bebut/Downloads/311_Service_Requests.csv")

#311 data cleaning
df = df %>%
  mutate(
    YEAR = as.numeric(substr(CREATED_DATE,7,10)),
    ZIP = as.numeric(ZIP_CODE)
  ) %>% 
  filter(STATUS == "Completed" &
           !is.na(ZIP) &
           !is.na(LATITUDE) &
           !is.na(LONGITUDE) &
           YEAR %in% 2019 
  ) %>% select(
    SR_NUMBER,SR_TYPE, OWNER_DEPARTMENT,CREATED_DATE,CLOSED_DATE,ZIP,YEAR,
    CREATED_HOUR,CREATED_DAY_OF_WEEK,CREATED_MONTH
    #X_COORDINATE,Y_COORDINATE,LATITUDE,LONGITUDE
  )

#write save data 
save(df,   file = "data/Chicago_311_clean.Rdata")

####################################
#Merge 311 data with ACS data
####################################
#load 311 data 
load("data/Chicago_311_clean.Rdata")

#acs data 
acs = read.csv("data/Chicago_zcta_subset_acs2019_clean.csv")

#merge 311 data and acs data 
dfacs = df %>% left_join(acs,by=c("ZIP"="GEOID")) %>% na.omit()
 
#write save data 
#save(dfacs,file = "data/Chicago_311_clean_merge.Rdata")
