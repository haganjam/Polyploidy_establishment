
# Combine Fig. 3a and Fig. 3b

# load relevant libraries
library(tidyverse)
library(here)
library(ggplot2)
library(ggpubr)

# remotes::install_version(package = "ggplot2", version = "3.4.4")

# check ggplot2 version
packageVersion("ggplot2")

# load the plot data
load(here("figures_tables", "fig3a.RData"))
load(here("figures_tables", "fig3b.RData"))

# change the title of p1
p1 <-
  p1 +
  ylab("Minority cytotype frequency")

# combine these figures using ggarrange
p12 <- 
  ggarrange(p1, p2, ncol = 2, nrow = 1,
            labels = c("a.", "b."), 
            font.label = list(size = 14, face = "plain"),
            vjust = 1)
p12

# export this figure
ggsave( filename = here("figures_tables/fig3.png"), 
       plot = p12, width = 20, height = 10.5, dpi = 400,
       units = "cm")

ggsave( filename = here("figures_tables/fig3.tiff"), 
        plot = p12, width = 20, height = 10.5, dpi = 800,
        units = "cm")

ggsave( filename = here("figures_tables/fig3.pdf"), 
        plot = p12, width = 20, height = 10.5,
        units = "cm")

### END
