
# Project: Polyploidy establishment and reproductive traits

# Title: Examine trait-ploidy correlations from Pladius data for the TREE proposal

# load relevant libraries
library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)

# load the relevant functions
source("Function_plotting_theme.R")

# load the Pladius data
pdat <- read_delim("Data/2022-01-16-Pladias-trait-export-for-Wilhelm-Osterman.csv",
                   delim = ";", skip = 4)
head(pdat)

# get the relevant columns
names(pdat)
pdat <- 
  pdat %>%
  select(lat_name, pladias_id, lft, rgt, rank, 
         synoecious, monoecious, dioecious, gynomonoecious, andromonoecious,
         gynodioecious, androdioecious, trioecious, trimonoecious) %>%
  filter(rank == "Species")

# convert to the long-format
pdat <- 
  pdat %>%
  pivot_longer(cols = contains("ecious"),
               names_to = "sexual_system",
               values_to = "TF")

# check if any species have all FALSE sexual systems
pdat <- 
  pdat %>%
  group_by(lat_name, pladias_id, lft, rgt, rank) %>%
  mutate(sum_TF = sum(TF)) %>%
  ungroup() %>%
  filter(!is.na(sum_TF)) %>%
  select(-sum_TF)

# convert back to wide format now that we're sure we removed all NA vals
pdat <- 
  pdat %>%
  pivot_wider(names_from = "sexual_system",
              values_from = "TF")

# get a matrix of true false values for the sexual systems
pdat_sex <- pdat[, -c(1:5)]

# get the identifier matrix
pdat <- pdat[, c(1:5)]

# calculate the number of sexual systems
n_sex <- rowSums(pdat_sex)

# make an output vector to collec the sexual systems
output_sex <- vector(length = length(n_sex))
for(i in 1:length(n_sex)) {

  # get the correct row
  y <- pdat_sex[i,]
  
  # decide on the sexual systems
  output_sex[i] <- ifelse(n_sex[i] == 1, names(y[, which(y == TRUE)]), "variable")
  
}

# add the data together again
pdat <- tibble( cbind(pdat, pdat_sex) )

# add the new variables
pdat$sexual_system <- output_sex
pdat$n_sexual_system <- n_sex

# load the ploidy level data
pdat2 <- read_delim("Data/Pladias_ploidy_data.csv", delim = ",")

# rename the first column
pdat2 <- 
  pdat2 %>%
  rename(lat_name = `Species name`)

# remove the NA's in the polyploid_yes_no column
pdat2 <- 
  pdat2 %>%
  filter(!is.na(Polyploidy_yes_no) )

# join the ploidy data to the trait data
pdat2 <- left_join(pdat2, pdat, by = c("lat_name", "pladias_id"))
head(pdat2)

# remove the NAs the dataset where we couldn't classify a sexual system
pdat2 <- 
  pdat2 %>%
  filter(!is.na(sexual_system))

# check which types of species are left
unique(pdat2$`Origin in the Czech Republic`)
sum(is.na(pdat2$`Origin in the Czech Republic`))

# remove the species with unknown origin
pdat2 <- 
  pdat2 %>%
  filter(!is.na(`Origin in the Czech Republic`))

# reorganise the columns
names(pdat2)
pdat2 <- 
  pdat2 %>%
  rename(ploidy_level_x = Ploidy_level_x,
         ploidy_max = Ploidy_max,
         ploidy_class_1 = Ploidy_class1,
         polyploidy_yn = Polyploidy_yes_no,
         origin = `Origin in the Czech Republic`,
         pollination_syndrome = Pollination_syndrom_grouped) %>%
  select(lat_name, pladias_id, lft, rgt, rank, 
         ploidy_level_x, ploidy_max, ploidy_class_1, polyploidy_yn,
         origin, pollination_syndrome,
         contains("ecious"),
         sexual_system, n_sexual_system) %>%
  arrange(lat_name)

# write this into a .csv file
write_csv(x = pdat2, file = "Data/pladias_sexual_ploidy_data.csv")

### END
