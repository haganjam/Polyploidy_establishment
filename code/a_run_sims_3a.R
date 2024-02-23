#'
#' @project: Polyploidy establishment and reproductive traits
#'
#' @title: Run simulations and plot fig. 3a
#'

# load relevant libraries
library(here)
library(dplyr)
library(ggplot2)

# load the relevant functions
source(here("code/model.R"))
source(here("code/helper_plotting_theme.R"))

# check that we have a figures folder
if(! dir.exists(here("figures_tables"))){
  dir.create(here("figures_tables"))
}

# set the number of simulation replicates
nreps <- 100

# sites and number of time-steps are fixed
sites <- 100
ts <- 500
death_prop <- 0.10

# frequency of the majority cytotype
X_pol <- c(0.10, 0.90)
P_D <- c(0.95)
pol_eff <- c(0.80)
self <- c(0.80)
seedP <- NA
seedD <- c(8)

# create a parameter set
df <- expand.grid(nreps = 1:nreps, 
                  sites = sites, ts = ts, death_prop = death_prop, pol_eff = pol_eff,
                  X_pol = X_pol, P_D = P_D, self = self, seedP = seedP, seedD = seedD
)
df$modid <- as.character(1:nrow(df))
dim(df)
head(df)

# set-up an output list
modlist <- vector("list", length = nrow(df))

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
  
  modlist[[i]] <- x
  
}
# close the progress bar
close(pb)

# bind the rows of the model output
modlist <- dplyr::bind_rows(modlist, .id = "modid")

# bind the model output to the parameters
modlist <- dplyr::full_join(df, modlist, by = "modid")

# check the data
summary(modlist)

# make a minority cytotype advantage variable
modlist <- 
  modlist %>%
  mutate(MC_ad = if_else(near(seedD, seedP), 0, 1),
         self = as.character(self))

# take the average per time
modlist.sum <- 
  modlist %>%
  group_by(self, X_pol, time) %>%
  summarise(prop_P.m = mean(prop_P),
            n = n(), .groups = "drop")

# visualise the results
names(modlist)

p1 <- 
  ggplot() +
  geom_line(data = modlist %>% 
              mutate(X_pol = as.character(X_pol)), 
            mapping = aes(x = time, y = prop_P, group = modid, colour = X_pol), 
            size = 0.1, alpha = 0.4) +
  geom_line(data = modlist.sum %>%
              mutate(X_pol = as.character(X_pol)),
            mapping = aes(x = time, y = prop_P.m, colour = X_pol),
            size = 1, alpha = 1) +
  geom_hline(yintercept = 0.1, colour = "black", linetype = "dashed") +
  scale_y_continuous(limits = c(0, 1)) +
  ylab("Minority cytotype freq.") +
  xlab("Generations") +
  # ggtitle("Selfing rate = 0.8") +
  guides(colour = guide_legend(title = "Outcross probability",
                               override.aes = list(size = 1.5,
                                                   alpha = 1))) +
  scale_colour_viridis_d(end = 0.95, option = "E", direction = 1) +
  theme_meta() +
  theme(axis.text = element_text(colour = "black"),
        legend.position = "top",
        legend.key = element_rect(fill = NA, color = NA),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 11),
        legend.margin=margin(1,0,6.5,0),
        legend.box.margin=margin(0,0,-5,0))
plot(p1)

# export the figure
save("p1", file = here("figures_tables", "fig3a.RData"))

### END
