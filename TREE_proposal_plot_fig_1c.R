
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

# fit a model of thresh using outcrossing and fitness difference
lm.x <- lm(thresh ~ X_pol*self, data = fdat)

# use this model to interpolate unknown, missing values

# set-up the y-values
yval <- range(fdat$self)
yval <- rep(seq(yval[1], yval[2], l = 50))

# set-up the x-values
xval <- range(fdat$X_pol)
xval <- rep(seq(xval[1], xval[2], l = 50))

# create a data.frame
df.int <- 
  expand.grid(self = yval,
              X_pol = xval)
head(df.int)

df.int$thresh <- predict(object = lm.x, df.int)
head(df.int)

zval <- ifelse(df.int$thresh < 0, 0, df.int$thresh)
zval <- ifelse(zval > 1, 1, zval)

brks <- seq(0, 1, length.out = 51)

grps <- cut(zval, brks, include.lowest = TRUE)
levels(grps) <- brks

df.int$zval <- as.numeric(as.character(grps))

p1 <- 
  ggplot(data = df.int,
       mapping = aes(x = X_pol, y = self,
                     fill = zval)) +
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
p1

# export this figure
ggsave(filename = here("Figures/fig_1c.png"), 
       plot = p1, width = 12, height = 11, dpi = 300,
       units = "cm")

### END
