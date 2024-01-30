#  Extend  timeseries, make a lineplot of global Teragrams per month
#  use all 35 models & plot the median value at each pixel (or random subset of models)
#  make clean gifs of flux and emission


# Ask sarah & bn for the model 
#    time series vs LSM
#    make a map of the spatial differences




#

# get Random forest model
rf_model <- readRDS(".data/random_forest/june2019/190530_rf_wetlands_monthly_MET_subset.rds")


# /----------------------------------------------------------------------------#
#/    get MERRA2 data open  

# get list of compressed files
dir = "./data/merra2/monthly/"
merra2 <- list.files(dir, pattern = ".nc.gz")

print(merra2)

for(m in merra2){
  
  untar(paste0(dis, m))
  
}



# /----------------------------------------------------------------------------#
#/    get BioClim data open  

# get list of compressed files
dir = "./data/merra2/monthly/"
merra2 <- list.files(dir, pattern = ".nc.gz")

print(merra2)

for(m in merra2){
  
  untar(paste0(dis, m))
  
}





# /----------------------------------------------------------------------------#
#/      Make random forest predictions of flux                   ---------

# create empty raster stack
pred_stack <- stack()


# loop through each time step 
for (i in seq(1, length(names(LST_Day_CMG_stack)))){
  
  
  # extract the MERRA2 grid at specific index of Ncdf
  
  # extract the BioClim grids at specific index of Ncdf
  
  # stack the predictor grids

  # TODO: decide whether to mask the grid 
  # mask(lat, LST_Day_CMG_stack[[i]])
  

  # predictions are in nanomoles / m^2 / sec
  z <- raster::predict(temp, agu_rf_model[[1]], progress="text", na.rm=T)
  # raster::
  
  names(z) <- names(LST_Day_CMG_stack[[i]])
  
  output_stack <- stack(output_stack, z)
  
  }
