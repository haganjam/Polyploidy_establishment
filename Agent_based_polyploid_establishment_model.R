
#' @title Minority_cyto_model()
#' 
#' @description Agent-based model of polyploid assessment
#' 
#' @details For model details, see the 'Project_documentation.Rmd' folder in the repository
#' 
#' @author James G. Hagan (james_hagan(at)outlook.com)
#' 
#' Session information
#' R version 4.1.2 (2021-11-01)
#' Platform: x86_64-w64-mingw32/x64 (64-bit)
#' Running under: Windows 10 x64 (build 19043)
#' Matrix products: default
#' 
#' attached base packages: stats, graphics, grDevices, utils, datasets, methods, base
#' other attached packages: ggplot2_3.3.5, dplyr_1.0.7 
#' 
#' @param ts - number of timesteps to simulate
#' @param sites - number of patches to model (each patch is occupied by one individual plant)
#' @param P_D - probability of diploidy i.e. probability of each patch being occupied by a diploid
#' @param X_pol - probability of pollination i.e. probability of each plant getting pollinated
#' @param pol_eff - pollinator efficiency i.e. if a plant is pollinated, how much of the realised seed set does it result in 
#' @param self - rate of selfing i.e. the proportion of the realised set that a plant can set via selfing 
#' @param seedP - seed production potential of polyploids (i.e. fitness)
#' @param seedD - seed production potential of diploids (i.e. fitness)
#' @param fit_ran - whether to randomise the fitness value of the polyploid (TRUE or FALSE)
#' @param fit_ran.m - mean deviation of the polyploid fitness from the seedD parameter (Normal distribution)
#' @param fit_ran.sd - standard deviation of the deviation of the polyploid fitness from the seedD parameter (Normal distribution)
#' @param death_prop - the probability of a plant dying at each time step and being replaced from produced seed
#' @param plot - TRUE/FALSE to plot the proportion of polyploids through time 
#' 
#' @return data.frame with two columns: time-step and proportion of polyploids
#' 

Minority_cyto_model <- function(ts = 100, sites = 100, P_D = 0.9, X_pol = 0.5,
                                pol_eff = 0.80, self = 0.5, 
                                seedP = 5, seedD = 5, 
                                fit_ran = TRUE,
                                fit_ran.m = 0.5, 
                                fit_ran.sd = 2.5, death_prop = 0.10,
                                plot = TRUE) {
  
  
  # if fit_ran is true then we add a random deviation
  if(fit_ran) {
    seedPx <- round(seedD + rnorm(n = 1, mean = fit_ran.m, sd = fit_ran.sd), 0)
    seedPx <- ifelse(seedPx < 1, 1, seedPx)
  } else {seedPx <- seedP}
  
  # set the output list
  output <- vector("list", length = ts)
  
  # draw a vector of polyploid or diploid individuals
  v <- c( rep("D", round(sites*P_D, 0)), rep("P", sites - round(sites*P_D, 0)) )
  
  # randomise the vector
  output[[1]] <- v[sample(1:length(v), length(v), replace = FALSE)]
  
  # get vector for proportion of outcrossed seeds
  o.seeds <- vector(length = length(ts-1))
  o.seeds[1] <- 0
  
  # loop over temporally
  for (i in 2:ts) {
    
    # set the output i-1 to m to run the simulation
    m <- output[[i-1]]
    
    # choose randomly selected individuals to get pollinated
    m.p <- sample(1:length(m), size = floor(length(m)*X_pol), replace = FALSE )
    
    n <- 
      sapply(m.p, function(x) {
        
        # sample an individual randomly that is not itself
        sample(m[-x], size = 1, replace = FALSE)
        
      })
    
    # get the seed pool for the next time-step from outcrossing
    oc_tn <- 
      mapply(function(x, y) {
        
        # which is the starting number
        if (x == "D") {
          u <- seedD
        } else {u <- seedPx}
        
        # if the cytotypes are different, then assign TRIP to pol_eff
        if (x != y) {
          TRIP <- round(u*pol_eff, 0)
          a <- round(u*self, 0)
          o.a <- 0
          assign(x = x, value = ifelse( (a + TRIP) > u, (u - TRIP), a ) )
        }
        
        # if the cytotype is equal to the randomly drawn pollinator
        # triploids are zero and the seed-set
        if (x == y) {
          TRIP <- 0
          a <- round(u*self, 0)
          o.a <- round(pol_eff*u, 0)
          assign(x = x, value = ifelse( (o.a + a) > u, u, (o.a + a) ) )
        }
        
        # assign the other cytotype zero
        b <- c("D", "P")
        assign(x = b[b != x], 0)
        
        # create an object to output
        out <- rep( c("T", "D", "P"), c(TRIP, D, P))
        
        # add an attribute to the object
        attr(out, "o.seeds") <- o.a
        
        # create a pool of seeds
        return(out)
        
      },  m[m.p], n, SIMPLIFY = FALSE, USE.NAMES = FALSE)
    
    # get the number of non-triploid seeds that are outcrossed
    o.seedsx <- sum(unlist( lapply(oc_tn, function(z) { attr(z, "o.seeds") }) ))
    
    # convert the oc_tn list into a vector
    oc_tn <- unlist(oc_tn)
    
    # get rid of the triploids
    oc_tn <- oc_tn[oc_tn != "T"]
    
    # get the seed pool from selfing
    self_tn <- 
      lapply(m[-m.p], function(x) {
        
        S <- 
          if (x == "D") {
            round(seedD*self, 0)
          } else {round(seedPx*self,0) }
        
        return(rep(x, S))
        
      })
    
    # convert self_tn into a vector
    self_tn <- unlist(self_tn)
    
    # get rid of the triploids
    self_tn <- self_tn[self_tn != "T"]
    
    # combine the seed sets
    disp <- c(oc_tn, self_tn)
    
    # calculate the proportion of seeds due to outcrossing
    o.seeds[i] <- o.seedsx/length(disp)
    
    # implement death and recolonisation from the seed pool
    death <- round(death_prop*length(m), 0)
    
    death_id <- sample(1:length(m), size = death, replace = FALSE)
    m_tn <- m
    m_tn[death_id] <- sample(disp, death, replace = TRUE)
    
    # write the output into the output list
    output[[i]] <- m_tn
    
  }
  
  # plot the proportion of polyploids through time
  if (plot) {
    plot(1:ts, lapply(output, function(x) sum(x == "P")/length(x)),
         ylim = c(0, 1), xlab = "time", ylab = "proportion polyploid")
  }
  
  # summarise the output
  dfx <- data.frame(time = 1:ts)
  
  # add the fitness of the polyploid if fit.ran == TRUE
  if (fit_ran) {
    dfx$seedPx <- seedPx
  }
  
  # add the proportion of outcrossing seeds
  dfx$o.seeds <- o.seeds
  
  # add proportion of polyploids through time
  dfx$prop_P <- unlist(lapply(output, function(y) sum(y == "P")/length(y)))
  
  # return the output
  return(dfx)
  
}

# test the model
# Minority_cyto_model(ts = 100, sites = 100, P_D = 0.9, X_pol = 0.9,
                    # pol_eff = 0.8, self = 0.5, 
                    # seedP = NA, seedD = 5, 
                    # fit_ran = TRUE, fit_ran.m = 0, fit_ran.sd = 2.5,
                    # death_prop = 0.10,
                    # plot = TRUE) 

### END
