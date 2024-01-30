#  Extend  timeseries, make a lineplot of global Teragrams per month
#  use all 35 models & plot the median value at each pixel (or random subset of models)
#  make clean gifs of flux and emission


# Ask sarah & bn for the model 
#    time series vs LSM
#    make a map of the spatial differences




library(caret)
library(ranger)
library(stats)
library(raster)
library(scales)



# read the raster stacks
LST_Day_CMG_stack <- readRDS("../../data/modis_processed/LST_Day_CMG_stack.rds")
LST_Night_CMG_stack <- readRDS("../../data/modis_processed/LST_Night_CMG_stack.rds")
lat <- readRDS("../../data/modis_processed/lat_grid.rds")




# get Random forest model
agu_rf_model <- readRDS("../../data/random_forest/agu_rf_model.rds")




#==============================================================================#
###            Make random forest predictions of flux           ----------------
#==============================================================================#

# create empty stack
output_stack <- stack()


# loop through each raster (timestep)
for (i in seq(1, length(names(LST_Day_CMG_stack)))){
  
  print(i)
  
  # stack a temporary predictors
  temp <-stack(LST_Day_CMG_stack[[i]] + 273,
               LST_Night_CMG_stack[[i]] + 273,
               mask(lat, LST_Day_CMG_stack[[i]]))  # masking the lat grid

  # rename columns
  names(temp) <- c("LSTN","LSTD","Latitude")
  
  # predictions are in nanomoles / m^2 / sec
  z <- raster::predict(temp, agu_rf_model[[1]], progress="text", na.rm=T)
  # raster::
  
  names(z) <- names(LST_Day_CMG_stack[[i]])
  
  output_stack <- stack(output_stack, z)
  }






#==============================================================================#
###            Mask flux predictions to wetland area           -----------------
#==============================================================================#

# read the netcdf
f <- '../../data/wetmap/gcp-ch4_wetlands_2000-2017_025deg.nc'
# open netcdf file
wo <- nc_open(f)
# read wet fraction as raster brick
Fw <-brick(f, varname="Fw")


crs(output_stack) <- crs(Fw)

# create empty stack
masked_flux_stack <- stack()

for (i in seq(1, length(names(LST_Day_CMG_stack)))) {
  
  print(i)
  
  # mask fluxes in pixels below a certain wetland area 
  Fw_mask <- Fw[[1+i]]
  
  #Fw_mask[Fw_mask < 0.05] <- NA
  Fw_mask[Fw_mask == 0] <- NA
  
  
  temp_masked <- mask(output_stack[[i]], Fw_mask)
  
  names(temp_masked) <- names(output_stack[[i]])
  
  # add to stack
  masked_flux_stack <- stack(masked_flux_stack, temp_masked)
  }

# conv from nmol to g  of CH4 
# 1 nanomol ch4  = 16.04246 g ch4   /  1e+9

masked_flux_stack <- masked_flux_stack / 1e+9 * 16.04246

# conv from sec to month
masked_flux_stack <- masked_flux_stack * 2.628e+6

saveRDS(masked_flux_stack, '../../output/results/upscaled_stack_flux_g_m2_month.rds')


#==============================================================================#
###         Convert flux from nanomol m^2 sec^-1  to Teragrams      ------------
#==============================================================================#

## TO DO LIST:   Tg CH4 per month
# 1 nanomol ch4  = 16.04246 g ch4   /  1e+9
# 1 nanomol ch4  = 1e-21 TeraG
# 1 m^2  -->  1e-6 km^2
# 1 sec --> 3.80517e-7 month


# calculate area of gridcell
pixarea <- area(output_stack[[1]])

library(ncdf4)
# read the netcdf
f <- '../../data/wetmap/gcp-ch4_wetlands_2000-2017_025deg.nc'
# open netcdf file
wo <- nc_open(f)
# read wet fraction as raster brick
Fw <-brick(f, varname="Fw")
Aw <- Fw * pixarea





upscaled_stack <- stack()

for (i in seq(1, length(names(LST_Day_CMG_stack)))){

  print(i)
  
  
  # multiply by area
  # this is in nanomoles per km2   multiplied by area (km2
  # result is  total nanomales per second)
  temp_upscaled <- output_stack[[i]] * 10^6 * Aw[[1+i]]
  
  # converting nanomoles/sec  to  Teragrams per sec;  16.04 moles of methane per grams of methane
  temp_upscaled <- temp_upscaled  * 1e-21 *  16.04246

  # converting teragrams/sec  to  Teragrams per month
  temp_upscaled <- temp_upscaled  * 2.628e+6
  
  names(temp_upscaled) <- names(output_stack[[i]])
  
  upscaled_stack <- stack(upscaled_stack, temp_upscaled)
  
    
  }


saveRDS(upscaled_stack, '../../output/results/upscaled_stack_tg_permonth.rds')








#==============================================================================#
###         Convert flux to  g m^2 sec^-1 ; scaled over entire pixel area      ------------
#==============================================================================#


## TO DO LIST:   Tg CH4 per month
# 1 nanomol ch4  = 16.04246 g ch4   /  1e+9
# 1 nanomol ch4  = 1e-21 TeraG
# 1 m^2  -->  1e-6 km^2
# 1 sec --> 3.80517e-7 month


# calculate area of gridcell
pixarea <- area(output_stack[[1]])

library(ncdf4)
# read the netcdf
f <- '../../data/wetmap/gcp-ch4_wetlands_2000-2017_025deg.nc'
# open netcdf file
wo <- nc_open(f)
# read wet fraction as raster brick
Fw <-brick(f, varname="Fw")
Aw <- Fw * pixarea





upscaled_stack <- stack()

for (i in seq(1, length(names(LST_Day_CMG_stack)))){
  
  print(i)
  
  # multiply by wetland area
  # this is in nanomoles per km2   multiplied by area (m2)
  # result is  total nanomales per second)
  temp_upscaled <- output_stack[[i]] * (10^6 * Aw[[1+i]])
  
  # converting nanomoles/sec  to grams per sec;  16.04 moles of methane per grams of methane
  temp_upscaled <- temp_upscaled  * 1e-9 *  16.04246
  
  # converting teragrams/sec  to  grams per month
  temp_upscaled <- temp_upscaled  * 2.628e+6
  
  # divide by whole pixel area
  temp_upscaled <- temp_upscaled / (pixarea * 10^6) 
  
  names(temp_upscaled) <- names(output_stack[[i]])
  
  upscaled_stack <- stack(upscaled_stack, temp_upscaled)
  
  
}


saveRDS(upscaled_stack, '../../output/results/upscaled_stack_mmech4.rds')








#==============================================================================#
### make raster sum function (shorten) -----------------------------------------
#==============================================================================#


sum_raster <- function(raster){sum(cellStats(raster, stat="sum"))}


upscaled_stack_tg_month <- readRDS('../../output/results/upscaled_stack_tg_permonth.rds')


for (i in seq(1, length(names(upscaled_stack)))){
  
  
  data.frame(names(upscaled_stack)[i],
             sum_raster(upscaled_stack_tg_month[[i]])),
  
}
