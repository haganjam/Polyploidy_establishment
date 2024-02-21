
# Project: Polyploidy establishment and reproductive traits

# Title: Plot simulation results for fig. 3b

# load relevant libraries
library(here)
library(dplyr)
library(ggplot2)
library(readr)

# load the relevant functions
source(here("code/helper_plotting_theme.R"))

# check that we have a figures folder
if(! dir.exists(here("figures_tables"))){
  dir.create(here("figures_tables"))
}

# read the simulation data
fdat <- read_csv(here("data/sim_data.csv"))
head(fdat)
dim(fdat)

# remove the first column
fdat <- fdat[, -1]
head(fdat)
summary(fdat)

# plot the data
ggplot(data = fdat, 
       mapping = aes(x = X_pol, y = self, colour = thresh)) +
  geom_point() +
  theme_meta()

p2 <- 
  ggplot(data = fdat,
       mapping = aes(x = X_pol, y = self,
                     fill = thresh)) +
  geom_tile() +
  scale_fill_viridis_c(alpha = 0.7, end = 0.9) +
  ylab("Selfing ability") +
  xlab("Outcross probability") +
  guides(fill = guide_colourbar(title.position = "left", 
                                title.vjust = 0.9,
                                title.hjust = 5,
                                frame.colour = "black", 
                                ticks.colour = NA,
                                barwidth = 8,
                                barheight = 0.7,
                                label.hjust = 0.3,
                                label.vjust = 3)) +
  labs(fill = "Establishment") +
  theme_meta() +
  theme(legend.position = "top",
        legend.direction="horizontal",
        legend.justification=c(0.35), 
        legend.key.width=unit(1, "lines"),
        legend.text = element_text(size = 9),
        legend.title = element_text(size = 12),
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(0,0,-5,0),
        legend.spacing.x = unit(0.6, "cm"))
plot(p2)
save("p2", file = here("figures_tables", "fig3b.RData"))

### END
