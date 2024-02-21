#'
#' @project: Polyploidy establishment and reproductive traits
#'
#' @title: Run the set of simulations used to plot fig. 3b
#'
#' @description: These simulations were run on the Albiorix (https://albiorix.bioenv.gu.se/)
#' computer cluster because the code is too slow on a regular desktop computer.
#' Thus, the paths that access the model function and output the data are
#' customised for the directories on the computer cluster. If you want to 
#' run this code on a normal desktop computer, then you need to modify the
#' paths appropriately.
#' 

# load relevant libraries
library(here)
library(dplyr)
library(foreach)
library(doParallel)

# load the relevant functions
source(here("Polyploidy_establishment/code/model.R"))

# set the number of simulation replicates
nreps <- 10

# sites and number of time-steps are fixed
sites <- 100
ts <- 500
death_prop <- 0.10

# frequency of the majority cytotype
P_D <- c(0.95)
X_pol <- seq(0.05, 0.95, 0.1)
pol_eff <- 0.8
self <- seq(0.05, 0.95, 0.1)
seedP <- NA
seedD <- c(8)

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

# reorder the columns
df <- 
  df %>%
  select(mod_group, modid, nreps, sites, ts, death_prop, pol_eff,
         X_pol, P_D, self, seedP, seedD)

# choose the threshold of persistence
thresh_p <- 0.5

# set-up a parallel for-loop
n.cores <- 10

#create the cluster
my.cluster <- parallel::makeCluster(
  n.cores, 
  type = "PSOCK"
)

#register it to be used by %dopar%
doParallel::registerDoParallel(cl = my.cluster)

# pb <- txtProgressBar(min = 0, max = nrow(df), initial = 0)
modlist <- foreach(
  i = 1:nrow(df)
  ) %dopar% {
  
  x <- Minority_cyto_model(ts = df$ts[i], sites = df$sites[i], P_D = df$P_D[i], X_pol = df$X_pol[i],
                           pol_eff = df$pol_eff[i], self = df$self[i], 
                           seedP = df$seedP[i], seedD = df$seedD[i], 
                           fit_ran = TRUE, fit_ran.m = 0, fit_ran.sd = 3,
                           death_prop = df$death_prop[i],
                           plot = FALSE)
  
  y <- data.frame(time = max(x$time),
                  fit_diff = unique(x$seedPx)-df$seedD[i],
                  o.seeds_mean = mean(x$o.seeds[-1], na.rm = TRUE),
                  prop_P = x$prop_P[nrow(x)])
  
  y$thresh <- ifelse(unique(y$prop_P) > thresh_p, 1, 0)
  
  return(y)
  
}

# bind the rows of the model output
modlist <- dplyr::bind_rows(modlist, .id = "modid")

# bind the model output to the parameters
modlist <- dplyr::full_join(df, modlist, by = "modid")

# summarise these data per parameter set
modlist <- 
  modlist %>%
  group_by(mod_group, sites, ts, death_prop, pol_eff, X_pol, P_D, self, seedP, seedD) %>%
  summarise(fit_diff = mean(fit_diff),
            o.seeds_mean = mean(o.seeds_mean),
            prop_P = mean(prop_P),
            thresh = sum(thresh)/n()) %>%
  ungroup()

# check that we have a figures folder
if(! dir.exists(here("Polyploidy_establishment/data"))){
  dir.create(here("Polyploidy_establishment/data"))
}

# write the output to a .csv file
write.csv(x = modlist, here("Polyploidy_establishment/data/sim_data.csv"))

### END
