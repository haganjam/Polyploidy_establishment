## Polyploidy_establishment

This project focuses on understanding factors that affect the ability of newly evolved polyploids to establish themselves in a population. This repository documents all the simulations and analysis used for this project.

**Participants:** Wilhelm Osterman, James G. Hagan, Jeanette Whitton and Anne Bjorkman.

To reproduce the analysis reported in the publication, download the repository (see instructions below). You can do this via git (i.e. cloning) or by downloading it as a zip file.

*Agent-based simulation model*

Details of how the simulation model works can be found in the *doc* folder:

+ proj_documentation.md

To reproduce the Fig. 3a in the manucsript, run the following script in the *code* folder. This script can be run on a regular desktop computer in a few minutes (maximum 20 minutes). The script runs a simulation varying the probability of outcrossing and exports an .RData file.

+ a_run_sims_3a.R

To reproduce Fig. 3b, you will need three scripts from the *code* folder. First, the following scripts run the set of simulations associated with Fig. 3b. This code will take a long time to run on a regular desktop computer. Therefore, we ran it on the Albiorix computer cluster using 10 cores (http://mtop.github.io/albiorix/site/manual.html). Because we ran the this script on a computer cluster, the file paths are not relative to the directory. So, if you wish to try and run this script on your own computer, you will have to alter the file paths.

+ b_run_sims_3b.R

The next script simply exports the simulation results to my local computer from the computer cluster. This script is run directly from the terminal.

+ c_export_sims.txt

Using the exported data, we can plot Fig. 3b:

+ d_plot_fig3b

Finally, we combine Fig. 3a and Fig. 3b into a single plot that is reported in the paper:

+ e_combine_fig3.R

The code for the model itself is available in this script from the *code* folder:

+ model.R

As mentioned previously, a detailed description of the model can be found in the *doc* folder.

For all the plots, we use a custom plotting theme:

+ helper_plotting_theme.R

Any questions regarding the analysis can be directed to: james_hagan@outlook.com.

