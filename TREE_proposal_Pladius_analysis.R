
# Project: Polyploidy establishment and reproductive traits

# Title: Examine trait-ploidy correlations from Pladius data for the TREE proposal

# load relevant libraries
library(here)
library(dplyr)
library(ggplot2)
library(readr)

# load the relevant functions
source(here("Function_plotting_theme.R"))

# load the Pladius data
pdat <- read_delim(here("Data/2022-01-16-Pladias-trait-export-for-Wilhelm-Osterman.csv"),
                   delim = ";", skip = 4)
View(pdat)

# get the relevant columns
pdat <- 
  pdat %>%
  select(lat_name, pladias_id, lft, rgt, rank, synoecious, monoecious, dioecious) %>%
  filter(!is.na(synoecious)) %>%
  filter(rank == "Species")

# how many synoecious, monoecious and dioecious taxa?
lapply(pdat[, c("synoecious", "monoecious", "dioecious")], function(x) sum(x))


