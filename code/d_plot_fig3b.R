#'
#' @project: Polyploidy establishment and reproductive traits
#'
#' @title: Plot simulations for fig. 3b
#'

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

# model thresh as a function of X_pol and self for interpolation
summary(fdat)

# fit the beta regression model
beta_mod <- 
  betareg::betareg(formula = thresh ~ X_pol*self, data = dplyr::mutate(fdat, thresh=(thresh+0.0001)))

# check the model
summary(beta_mod)

# use the model to interpolate to a finer grain
pred <- expand.grid(X_pol = seq(0.05, 0.95, 0.005), 
                    self = seq(0.05, 0.95, 0.005))

# get the predictions from the model
pred$thresh <- predict(beta_mod, pred)

# set zeros for very low values
pred$thresh <- ifelse(pred$thresh <= 0.001, 0, pred$thresh)

# check the summary
summary(pred)

p2 <- 
  ggplot(data = pred,
       mapping = aes(x = X_pol, y = self, fill = thresh, colour=thresh)) +
  geom_tile(linewidth = 1) +
  scale_fill_viridis_c(begin = 0,end = 0.9, option= "E", direction = -1) +
  scale_colour_viridis_c(begin = 0,end = 0.9, option= "E", direction = -1) +
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
                                label.vjust = 3),
         colour = "none") +
  labs(fill = "Establishment") +
  theme_meta() +
  scale_x_continuous(expand = c(0, 0), limits=c(0, 1), breaks = seq(0, 1, 0.25)) +
  scale_y_continuous(expand = c(0, 0), limits=c(0, 1.005), breaks = seq(0, 1, 0.25)) +
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
