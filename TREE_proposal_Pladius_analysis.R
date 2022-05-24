
# Project: Polyploidy establishment and reproductive traits

# Title: Examine trait-ploidy correlations from Pladius data for the TREE proposal

# load relevant libraries
library(here)
library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)
library(viridis)

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
View(pdat)


# load the ploidy level data
pdat2 <- read_delim(here("Data/Pladias_ploidy_data.csv"),
                   delim = ",")

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

# remove the NAs in the synoecious column
pdat2 <- 
  pdat2 %>%
  filter(!is.na(synoecious))

# convert the reproductive mode columns into the long format
pdat2 <- 
  pdat2 %>%
  pivot_longer(cols = c("synoecious", "dioecious", "monoecious"),
               names_to = "reproductive_mode",
               values_to = "value") %>%
  filter(value == TRUE) %>%
  select(-value)


# plot ploidy class and reproductive mode
p1 <- 
  pdat2 %>%
  group_by(reproductive_mode, Ploidy_class1) %>%
  summarise(count = n()) %>%
  mutate(count_prop = sum(count)) %>%
  ungroup() %>%
  mutate(proportion = count/count_prop,
         Ploidy_class1 = as.character(Ploidy_class1)) %>%
  ggplot(data = .,
       mapping = aes(x = Ploidy_class1, y = proportion, fill = reproductive_mode)) +
  geom_col(width=0.5,    
           position=position_dodge(0.5), alpha = 0.75) +
  #geom_vline(xintercept = 1, colour = "black", linetype = "dashed") +
  geom_vline(xintercept = mean(pdat2[pdat2$reproductive_mode == "dioecious",]$Ploidy_class1), 
             colour = viridis(n = 1, begin = 0, end = 0)) +
  geom_vline(xintercept = mean(pdat2[pdat2$reproductive_mode == "monoecious",]$Ploidy_class1), 
             colour = viridis(n = 1, begin = 0.45, end = 0.45)) +
  geom_vline(xintercept = mean(pdat2[pdat2$reproductive_mode == "synoecious",]$Ploidy_class1), 
             colour = viridis(n = 1, begin = 0.9, end = 0.9)) +
  scale_fill_viridis_d(end = 0.9, option = "D") +
  xlab("Ploidy level") +
  ylab("Proportion of species") +
  theme_meta() +
  theme(legend.position = "bottom", 
        legend.title = element_blank())
p1

ggsave(filename = here("Figures/fig_1c.png"), 
       plot = p1, width = 12, height = 11, dpi = 300,
       units = "cm")

### END
