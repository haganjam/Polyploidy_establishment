
# Project: Polyploidy establishment and reproductive traits

# Title: Plot simulation results for fig. 1c

# load relevant libraries
library(here)
library(dplyr)
library(ggplot2)
library(readr)

# load the relevant functions
source(here("Function_plotting_theme.R"))

# check that we have a figures folder
if(! dir.exists(here("Figures"))){
  dir.create(here("Figures"))
}

# read the simulation data
fdat <- read_csv(here("Data/fig_1c_data.csv"))
head(fdat)

# remove the first column
fdat <- fdat[, -1]
head(fdat)
summary(fdat)

# plot the data
ggplot(data = fdat, 
       mapping = aes(x = o.seeds_mean, y = fit_diff, colour = thresh)) +
  geom_point() +
  theme_meta()

# fit a model of thresh using outcrossing and fitness difference
lm.x <- lm(thresh ~ fit_diff*o.seeds_mean, data = fdat)

# use this model to interpolate unknown, missing values

# set-up the y-values
yval <- range(fdat$fit_diff)
yval <- rep(seq(yval[1], yval[2], l = 20))

# set-up the x-values
xval <- range(fdat$o.seeds_mean)
xval <- rep(seq(xval[1], xval[2], l = 20))

# create a data.frame
df.int <- 
  expand.grid(fit_diff = yval,
              o.seeds_mean = xval)
head(df.int)

df.int$thresh <- predict(object = lm.x, df.int)
head(df.int)

ggplot(data = df.int,
       mapping = aes(x = o.seeds_mean, y = fit_diff,
                     fill = thresh, colour = thresh)) +
  geom_tile() +
  scale_fill_viridis_c() +
  scale_colour_viridis_c() + 
  theme_meta()






