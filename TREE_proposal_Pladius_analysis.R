
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

# collapse the 6 and 7 ploidy levels with the 5 level
pdat2$Ploidy_class1 <- ifelse(pdat2$Ploidy_class1 %in% c(5, 6, 7), 5, pdat2$Ploidy_class1)

# re-level the factors
pdat2$Ploidy_class_fac <- factor(pdat2$Ploidy_class1)
levels(pdat2$Ploidy_class_fac) <- paste(1:5, "x", sep = "")

pdat2 <- 
  pdat2 %>%
  group_by(reproductive_mode) %>%
  summarise(proportion = sum(Polyploidy_yes_no)/n(),
            n = n(), 
            .groups = "drop")

p1 <- 
  ggplot(data = pdat2,
         mapping = aes(x = reproductive_mode, y = proportion)) +
  geom_col(width = 0.2, colour = viridis(n = 1, begin = 0.5, end = 0.5),
           fill = viridis(n = 1, begin = 0.5, end = 0.5)) +
  scale_y_continuous(limits = c(0, 0.55), breaks = c(0.1, 0.2, 0.3, 0.4, 0.5)) +
  annotate(geom = "text", label = paste("N = ", pdat2$n[1], sep = "" ),
           x = 1, y = 0.35) + 
  annotate(geom = "text", label = paste("N = ", pdat2$n[2], sep = "" ),
           x = 2, y = 0.21) +
  annotate(geom = "text", label = paste("N = ", pdat2$n[3], sep = "" ),
           x = 3, y = 0.52) + 
  xlab("Reproductive mode") +
  ylab("Polyploid species prop.") +
  theme_meta()
  
p1

ggsave(filename = here("Figures/fig_1c.png"), 
       plot = p1, width = 12, height = 11, dpi = 300,
       units = "cm")

### END
