# /----------------------------------------------------------------------------#
#/    Run all script
#     This script produces the CH4 upscaling v0.3.
#     The outputs are monhtly maps at 0.5deg.
#     Authors: Etienne Fluet-Chouinard & Gavin McNichol
#              Stanford University, 2019

ptm <- proc.time()  # Start the clock!

# set working directory on cluster
setwd("/home/groups/robertj2/ch4_upscaling")


# /----------------------------------------------------------------------------#
#/     install packages
source("./scripts/cluster_install_packages.r")



# /----------------------------------------------------------------------------#
#/    Open data files                                                   -------

# 
# source("./scripts/cluster_prep_predictor_grids.r")
# 
# 
# 
# # /----------------------------------------------------------------------------#
# #/        Apply random forestto predictor grid                         ---------
# #
# source("./scripts/cluster_rf_predict_grid.r")
# 
# 
# 
# #==============================================================================#
# ###        Compare upscaled grid to LPJ output      ----------------------------
# #==============================================================================#
# 
# ###     - compare fluxes  (g / m^2 / month)
# source("./compare_ch4flux_upscaled_vs_lpj.r")
# 
# 
# ###     - compare total emissions (Tg / month)
# 
# 
# #==============================================================================#
# ###        Make plots / GIFs of output                                ----------
# source("./plots/gif/gif_Fw.r")
# source("./plots/gif/gif_flux_predictions.r")
# 
# 


proc.time() - ptm  # Stop the clock