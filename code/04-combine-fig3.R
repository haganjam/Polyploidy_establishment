
# Combine Fig. 2a and Fig. 2b

# load relevant libraries
library(here)
library(ggplot2)
library(ggpubr)

# load the plot data
load(here("figures-tables", "fig3a.RData"))
load(here("figures-tables", "fig3b.RData"))

# combine these figures using ggarrange
p12 <- 
  ggarrange(p1, p2, ncol = 2, nrow = 1,
            labels = c("a.", "b."), 
            font.label = list(size = 14, face = "plain"),
            vjust = 1)
p12

# export this figure
ggsave( filename = here("figures-tables/Fig_2.png"), 
       plot = p12, width = 20, height = 10.5, dpi = 300,
       units = "cm")

### END
