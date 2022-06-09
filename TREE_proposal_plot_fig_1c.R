
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
yval <- rep(seq(yval[1], yval[2], l = 50))

# set-up the x-values
xval <- range(fdat$o.seeds_mean)
xval <- rep(seq(xval[1], xval[2], l = 50))

# create a data.frame
df.int <- 
  expand.grid(fit_diff = yval,
              o.seeds_mean = xval)
head(df.int)

df.int$thresh <- predict(object = lm.x, df.int)
head(df.int)

zval <- ifelse(df.int$thresh < 0, 0, df.int$thresh)
zval <- ifelse(zval > 1, 1, zval)

brks <- seq(0, 1, length.out = 51)

grps <- cut(zval, brks, include.lowest = TRUE)
levels(grps) <- brks

df.int$zval <- as.numeric(as.character(grps))

ggplot(data = df.int,
       mapping = aes(x = o.seeds_mean, y = fit_diff,
                     fill = zval)) +
  geom_tile() +
  scale_fill_viridis_c(alpha = 0.7, end = 0.9) +
  ylab("Fitness difference") +
  xlab("Outcrossed seed proportion") +
  guides(fill = guide_colourbar(title.position = "top", 
                                title.vjust = 1,
                                frame.colour = "black", 
                                ticks.colour = NA,
                                barwidth = 10,
                                barheight = 0.5)) +
  labs(fill = "Polyploid persistence") +
  geom_hline(yintercept = 0, colour = "white", linetype = "dashed") +
  theme_meta() +
  theme(legend.position = "top",
        legend.direction="horizontal",
        legend.justification=c(0.1), 
        legend.key.width=unit(1, "lines"),
        legend.text = element_text(size = 9),
        legend.title = element_text(size = 10),
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(0,0,-5,0))

### END
