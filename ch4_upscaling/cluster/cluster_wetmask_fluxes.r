
# /----------------------------------------------------------------------------#
#/            Mask flux predictions to wetland area                      -------


# read the netcdf
f <- '../../data/wetmap/gcp-ch4_wetlands_2000-2017_025deg.nc'

# open netcdf file
wo <- nc_open(f)
# read wet fraction as raster brick
Fw <-brick(f, varname="Fw")


crs(output_stack) <- crs(Fw)

# create empty stack
masked_flux_stack <- stack()


# /----------------------------------------------------------------------------#
#/     loop through each grid in stack
for (i in seq(1, length(names(LST_Day_CMG_stack)))) {
  
  print(i)
  
  # mask fluxes in pixels below a certain wetland area 
  Fw_mask <- Fw[[1+i]]
  
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



# save masked flux to file
saveRDS(masked_flux_stack, '../../output/results/upscaled_stack_flux_g_m2_month.rds')