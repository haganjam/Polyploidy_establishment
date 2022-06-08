
# Project: Polyploidy establishment and reproductive traits

# Title: Run simulations for TREE proposal

# load relevant libraries
library(here)
library(dplyr)
library(ggplot2)

# load the relevant functions
source(here("Agent_based_polyploid_establishment_model.R"))
source(here("Function_plotting_theme.R"))

# check that we have a figures folder
if(! dir.exists(here("Figures"))){
  dir.create(here("Figures"))
}

# fig. 1c

# set the number of simulation replicates
nreps <- 2

# sites and number of time-steps are fixed
sites <- 100
ts <- 500
death_prop <- 0.10

# frequency of the majority cytotype
P_D <- c(0.95)
X_pol <- seq(0.10, 0.90, 0.20)
pol_eff <- seq(0.40, 0.90, 0.20)
self <- seq(0.10, 0.90, 0.20)
seedP <- NA
seedD <- c(5)

# create a parameter set
df <- expand.grid(nreps = 1:nreps, 
                  sites = sites, ts = ts, death_prop = death_prop, pol_eff = pol_eff,
                  X_pol = X_pol, P_D = P_D, self = self, seedP = seedP, seedD = seedD
)

mod_group <- 
  df %>%
  group_by(sites, ts, death_prop, pol_eff, X_pol, P_D, self, seedP, seedD) %>%
  group_keys() %>%
  ungroup() %>%
  mutate(mod_group = 1:n()) %>%
  pull(mod_group)

mod_group <- rep(mod_group, each = nreps)

# make a unique id for each model
df$modid <- as.character(1:nrow(df))

# make a unique id for each model group
df$mod_group <- mod_group

# check the dimensions
dim(df)
head(df)

# reorder the columns
df <- 
  df %>%
  select(mod_group, modid, nreps, sites, ts, death_prop, pol_eff,
         X_pol, P_D, self, seedP, seedD)

# set-up an output list
modlist <- vector("list", length = nrow(df))

# choose the threshold of persistence
thresh_p <- 0.5

pb <- txtProgressBar(min = 0, max = nrow(df), initial = 0)
for(i in 1:nrow(df)) {
  
  # update the progress bar
  setTxtProgressBar(pb,i)
  
  x <- Minority_cyto_model(ts = df$ts[i], sites = df$sites[i], P_D = df$P_D[i], X_pol = df$X_pol[i],
                           pol_eff = df$pol_eff[i], self = df$self[i], 
                           seedP = df$seedP[i], seedD = df$seedD[i], 
                           fit_ran = TRUE, fit_ran.m = 0, fit_ran.sd = 2.5,
                           death_prop = df$death_prop[i],
                           plot = FALSE)
  
  y <- data.frame(time = max(x$time),
                  fit_diff = unique(x$seedPx)-df$seedD[i],
                  o.seeds_mean = mean(x$o.seeds[-1], na.rm = TRUE),
                  prop_P = x$prop_P[nrow(x)])
  
  y$thresh <- ifelse(unique(y$prop_P) > thresh_p, 1, 0)
  
  modlist[[i]] <- y
  
}
# close the progress bar
close(pb)

# bind the rows of the model output
modlist <- dplyr::bind_rows(modlist, .id = "modid")

# bind the model output to the parameters
modlist <- dplyr::full_join(df, modlist, by = "modid")

# check the data
summary(modlist)

# summarise these data per parameter set
modlist %>%
  group_by(mod_group, sites, ts, death_prop, pol_eff, X_pol, P_D, self, seedP, seedD) %>%
  summarise(fit_diff = mean(fit_diff),
            o.seeds_mean = mean(o.seeds_mean),
            prop_P = mean(prop_P),
            thresh = sum(thresh)/n())

### END
