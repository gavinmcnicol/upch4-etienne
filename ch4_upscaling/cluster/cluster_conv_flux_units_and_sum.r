
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

# save converted flux unit grids
saveRDS(upscaled_stack, '../../output/results/upscaled_stack_mmech4.rds')








#==============================================================================#
### make raster sum function (shorten) -----------------------------------------
#==============================================================================#

# this is thee function
sum_raster <- function(raster){sum(cellStats(raster, stat="sum"))}

# read the grid
upscaled_stack_tg_month <- readRDS('../../output/results/upscaled_stack_tg_permonth.rds')


for (i in seq(1, length(names(upscaled_stack)))){
  
  
  data.frame(names(upscaled_stack)[i],
             sum_raster(upscaled_stack_tg_month[[i]])),
  
}
