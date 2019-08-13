# Create an additional column that contains attendees name AND title
# Data are in a CSV file located within the project. To reproduce this operation,
# ensure that the CSV file is saved to the appropriate folder

library(tidyverse)

path <- file.path(here::here(), "data")

dat <- read_csv(file.path(path, "arisenigeria-registration-complete.csv"), na = "NA")

newDf <- dat %>% 
  map_df(function(x) ifelse(is.na(x), character(1), x)) %>% 
  mutate(surname = str_to_title(surname)) %>% 
  mutate(other.names = str_to_title(other.names)) %>% 
  mutate(namesModified = paste(title, other.names, surname)) %>% 
  mutate(namesModified = str_squish(namesModified))

write_csv(newDf, file.path(path, "arisenigeria_modifiedNames.csv"), na = character(1))
