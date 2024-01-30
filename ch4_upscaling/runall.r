 
library(ncdf4)
library(R.utils)
library(raster)
library(gridExtra)
library(latticeExtra) 
library(grid) 
library(ggplot2)
library(animation)
library(maptools)
library(animation)
library(lubridate)
library(stringr)
library(rgdal)
library(here)
here::here()


ptm <- proc.time()  # Start the clock!
#==============================================================================#
###    Download and prep MODIS data             --------------------------------
#==============================================================================#

source("./get_modis_data.r")


proc.time() - ptm  # Stop the clock



#==============================================================================#
###        Apply random forest (from Gavin) to predictor grid       ------------
#==============================================================================#

source("./rf_predict_grid.r")



#==============================================================================#
###        Compare upscaled grid to LPJ output      ----------------------------
#==============================================================================#

###     - compare fluxes  (g / m^2 / month)
source("./compare_ch4flux_upscaled_vs_lpj.r")


###     - compare total emissions (Tg / month)


#==============================================================================#
###        Make GIF plots                    -----------------------------------
#==============================================================================#
source("./plots/gif/gif_Fw.r")
source("./plots/gif/gif_flux_predictions.r")