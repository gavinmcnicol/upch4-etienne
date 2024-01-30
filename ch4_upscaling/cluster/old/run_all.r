# set home dir
setwd("/home/groups/robertj2/ch4_upscaling")

# import libraries

source("scripts/import_libs.r")
source("scripts/import_libs.r")



#==============================================================================#
###    Download and prep MODIS data

# download modis data
ptm <- proc.time()  # Start the clock!
source("./get_modis_data.r")
proc.time() - ptm  # Stop the clock



### Apply random forest (from Gavin) to predictor grid  ------------------------
source("./rf_predict_grid.r")


###  Compare upscaled grid to LPJ outpu    -------------------------------------

#compare fluxes  (g / m^2 / month)
source("./compare_ch4flux_upscaled_vs_lpj.r")


###     - compare total emissions (Tg / month)


#==============================================================================#
###        Make GIF plots                    -----------------------------------
#==============================================================================#

# make gif of wetland fraction
source("./plots/gif/gif_Fw.r")

# make gif of upscaled CH4 flux
source("./plots/gif/gif_flux_predictions.r")