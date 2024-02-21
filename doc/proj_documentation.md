Polyploidy establishment: Project documentation
================

# Project goals

The goal of this project is to understand factors that influence the
establishment of polyploids. In particular, how polyploids are able to
avoid minority cytotype exclusion from the perspective of reproductive
ecology.

To do this, we will use several different sources of evidence including
conceptual models, agent-based simulation models and empirical
trait-ploidy correlations.

## Agent-based polyploid establishment model

To test how rate of outcrossing, polyploid fitness and selfing interact
to affect the probability of minority cytotype exclusion, we developed a
spatially implicit, agent-based model of interacting cytotypes.

We initialise a set of sites (i.e. *sites* parameter), each of which is
occupied by an individual plant. We then assign these plants to one of
two cytotypes, namely: diploid (D) or polyploid (P, in this case a
tetraploid for simplicity). In this way, we assume the polyploid (P) is
the minority cytotype as this is the most likely case. However, if the
polyploid were the majority cytotype, the results would change.

The proportion of plants being assigned a diploid cytotype is set by the
*P_D* parameter.

Next, we randomly select X individuals that are pollinated. The number
of individuals is determined by the *X_pol* parameter i.e. the
proportion of plants that get pollinated. Therefore, the total number of
pollinated plants is set as the rounded down value of (*X_pol x sites*).

For each individual that is chosen to be pollinated, we randomly draw an
individual from the remaining community to pollinate it. Thus, if there
are more **D cytotypes** in the community then, on average, more
individuals will be pollinated by **D cytotypes**.

If the pollinated individuals are pollinated by the same cytotype, then
the number of same cytotype seeds is controlled by the fitness
parameters (*seedD or seedP*) and the pollinator effectiveness parameter
(*pol_eff*). For example, if a D individual is pollinated by another D
individual, the seed set is calculated as (*seedD x pol_eff*) where
seedD is a positive integer specifying the potential seed set and
pol_eff is a proportion of that potential seed set.

There are two options for setting the fitness parameters (*seedD or
seedP*). First, you can provide two different integers for *seedD* and
*seedP*. Or, you can provide an integer for seedD and then set *fit_ran
= TRUE*. By doing this, the function will draw a number from a normal
distribution with mean = *fit_ran.m* and sd = *fit_ran.sd*. Then seedP
is calculated as: *seedD + rnorm(n = 1, mean = fit_ran.m, sd =
fit_ran.sd)*. Therefore, we simulate the case where polyploids get some
random fitness change after polyploidisation.

In addition, if there is selfing, then we add the number of selfed
seeds. For example, if the selfing parameter: *self* is greater than 0,
then we calculated the selfed seed set as *seedD x self*. This selfed
seed set is added to the outcrossed seed set. However, the total seed
set (i.e. selfed + outcrossed seed set) for an individual cannot exceed
*seedD* (or *seedP* in the case of a polyploid).

For non-pollinated individuals, we use the same procedure but only
consider the selfed seed set. Therefore, for a P cytotype individual
that does not get pollinated, we calculate the seed set as *self x
seedP*.

Once all individuals in the population have set seed either through
outcrossing, selfing or both, all the produced seeds make it into a
global seed pool. Next, we choose some number of plants to die. The
number is the rounded value of (*death_prop x sites*). These are
replaced by random draws from the global seed pool. Thus, the model
implicitly assumes zero-sum dynamics whereby every individual that dies
is replaced by a new individual whilst total community size remains
constant (as per Hubbell 2001).

Once the dead plants have been replaced, we start the cycle again. Using
this model, we can track the proportion of D and P cytotypes through
time. By varying the different parameters for outcrossing, fitness and
selfing, we can determine which factors are most important for reducing
minority cytotype exclusion. The number of time-steps is set by the *ts*
parameter.
