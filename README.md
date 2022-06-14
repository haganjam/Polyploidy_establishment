# Polyploidy_establishment
This project focuses on understanding factors that affect the ability of newly evolved polyploids to establish themselves in a population. This repository documents all the simulations and analysis used for this project.

**Participants:** Wilhelm Osterman, James G. Hagan, Jeanette Whitton and Anne Bjorkman.

## TREE proposal

To reproduce the analysis reported in the *Trends in Ecology and Evolution* proposal, download the repository (see instructions below). 

*Agent-based simulation model*

Details of how the simulation model works can be found in the following file:

+ "Project_documentation.Rmd"

To reproduce Fig. 2a, run the script called:

+ "TREE_proposal_simulations_fig_1b.R"

This script runs a simulation varying the probability of outcrossing, plots and exports the plot as a .png file and as an .RData file.

To reproduce Fig. 2b, you will need two scripts:

+ "TREE_proposal_simulations_fig_1c.R"
+ "TREE_proposal_plot_fig_1c.R"

This code, however, will take a long time to run on a regular desktop computer. The simulations were run on the Albiorix computer cluster using 10 cores (http://mtop.github.io/albiorix/site/manual.html).

Then, the second script takes the output of this model and plots it as a .png file and as an .RData file.

Once these scripts have been run, the following script merges the two figures and outputs the complete Fig. 2 as a .png file:

+ TREE_proposal_comb_fig_2ab.R

*Trait-ploidy correlations*

This script compares the proportion of polyploids between monoecious, dioecious and synoecious species in the Czech flora using data from the PLADIAS database (https://pladias.cz/en/). However, the data cannot be shared here yet but the code can be viewed:

+ "TREE_proposal_Pladius_analysis.R"


### Instruction to download a Github repo

#### with git

in the Terminal:

```cd path/to/local/folder``` 

(on your computer - the folder were you want the repository to live) command on Windows might differ. 


```git clone https://github.com/FabianRoger/Bacteria_BEF_Scale.git```

This should download the directory. 

#### without git
If you don't have git installed, you can download the repository as zip file and save it locally. 

--> Clone or download (green button top right)
--> Download Zip

then save and extract the zip where you want the director to live. 