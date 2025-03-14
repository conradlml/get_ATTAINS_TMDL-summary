
################################################################################
# Direct ATTAINS query for TMDLs in Idaho. 
# 
# Lily Conrad, IDEQ State Office
# last update: 3/14/2025
#
# Package citation: 
# Schramm, Michael (2021). rATTAINS: Access EPA 'ATTAINS' Data. R
# package version 1.0.0. doi:10.5281/zenodo.5469911
# https://CRAN.R-project.org/package=rATTAINS
################################################################################

# To get started, provide the user inputs below following the outlined format.


### User inputs ----------------------------------------------------------------

# Run these lines of code to load packages, libraries, and allowable values (might 
# take a minute or so to run). 
my_packages <- c("tidyr", "xlsx", "rATTAINS", "dplyr")
install.packages(my_packages, repos = "http://cran.rstudio.com")

library(tidyr)
library(xlsx)
library(rATTAINS)
library(dplyr)

TMDL_parameters <- actions(organization_id = "IDEQ")$actions %>%
  unnest(parameters, 
         names_repair = "check_unique", 
         keep_empty = TRUE) %>%
  select(parameters_name) %>% 
  unique() 

# You should see an item appear with the name "TMDL_parameters" under your Global
# Environment (top right window). Click on it to open it in a new tab to take a
# closer look. This is the list of pollutants that TMDLs have been written for in
# Idaho and are considered 'allowable values' for the user input below. 

# Enter your pollutant of interest based on the allowable values in the 
# TMDL_parameters data frame. Entries are case sensitive. All entries should be
# in quotation marks inside the parentheses. If you want to enter multiple
# pollutants, separate them by a comma inside the parentheses. 
parameter <- c("TEMPERATURE", "TEMPERATURE, WATER")

# Enter your username (the name at the beginning of your computer's file explorer
# path) in quotations.
my_name <- "jdoe"


# Now that you've entered the values above, click on "Source" and watch
# your console for errors. If the script ran successfully, there will be a new
# Excel file for each pollutant in your Downloads folder. 


################################################################################
#                                 START
################################################################################

### Retrieve the ATTAINS data --------------------------------------------------

# Data query for all TMDLs in Idaho that are written for the parameter(s) provided 
# above with a loop.     
parameter_list <- parameter
for (i in parameter_list) {
  # Dataframe with TMDL document names and information based on parameter of
  # interest.
  TMDLs.temp <- actions(organization_id = "IDEQ",
                 parameter_name = i)
  
  # Pull out documentation metadata. 
  TMDLDocs.temp <- TMDLs.temp$documents %>% 
    select(organization_identifier, 
           action_type_code, 
           action_identifier, 
           action_name,
           action_status_code, 
           completion_date, 
           TMDL_date,
           document_type_code, 
           document_name, 
           document_url) %>% 
    rename(approval_date = TMDL_date)
  
  # Dataframe with more details about the TMDL: AUs, parameter, if point or  
  # nonpoint sources were included. 
  TMDLActs.temp <- TMDLs.temp$actions %>% 
    unnest(parameters, 
           names_repair = "check_unique", 
           keep_empty = TRUE) %>%
    select(action_identifier, 
           asessment_unit_identifier, 
           parameters_name,
           pollutant_source_type_code) %>% 
    filter(parameters_name == i) %>% 
    rename(assessment_unit_identifier = asessment_unit_identifier)
  
  # Tie in AU status (retired/active) into the list of AUs. 
  AUs.temp <- assessment_units(organization_id = "IDEQ", tidy = TRUE, .unnest = TRUE) 
  
  AUs.temp <- AUs.temp %>% 
    select(assessment_unit_identifier, 
           status_indicator) %>% 
    rename(AU_status = status_indicator)
  
  TMDLActs.temp <- merge(x = TMDLActs.temp, 
                         y = AUs.temp, 
                         by = "assessment_unit_identifier", 
                         all.x = TRUE)
  
  TMDLActs.temp <- TMDLActs.temp %>%
    mutate(AU_status = ifelse(AU_status == "R",
                                  "Retired",
                                  ifelse(AU_status == "A",
                                         "Active",
                                         AU_status)))
  
  # Merge TMDL information into AU dataframe. 
  TMDLActs.temp <- merge(x = TMDLActs.temp, 
                         y = TMDLDocs.temp, 
                         by = "action_identifier", 
                         all.x = TRUE)
  
  # compile all dataframes into a spreadsheet with multiple tabs. 
  write.xlsx(TMDLDocs.temp, 
             file = paste0("C:/Users/",my_name,"/Downloads/",Sys.Date(),"_ATTAINS_TMDLs_",i,".xlsx"), 
             sheetName = "All TMDLs")
  write.xlsx(TMDLActs.temp, 
             file = paste0("C:/Users/",my_name,"/Downloads/",Sys.Date(),"_ATTAINS_TMDLs_",i,".xlsx"), 
             sheetName = "All TMDLs + AUs", 
             append = TRUE)
}


################################################################################
#                                 END
################################################################################