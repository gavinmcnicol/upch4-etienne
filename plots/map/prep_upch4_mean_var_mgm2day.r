n_cores=6
beginCluster(n_cores, type='SOCK')


vdir <- '../output/results/grids/v04/m1/'

# Get data mask; bc oceans are 0s since the replacement
datmask <- stack(paste0(vdir,'stack/upch4_v04_m1_nmolm2sec.nc'), varname='mean_ch4')[[210]]


# /----------------------------------------------------#
#/   Calculate average of member
print('getting avg mean grid')

m1 <- stack(paste0(vdir,'stack/upch4_v04_m1_mgCH4m2day_Aw.nc'), varname='mean_ch4')

# Replace NAs by 0s before averaging
m1_0 <- calc(m1, function(x){ x[is.na(x)] <- 0; return(x) } , progress='text')

# Calculate mean flux of grid with 0s - these are the actual values to map
m1_0_mean <- calc(m1_0, fun=mean, na.rm=T, progress='text')

# Save mean raster - unamsked
writeRaster(m1_0_mean, paste0(vdir,'for_map/upch4_v04_m1_mgCH4m2day_Aw_mean.tif'))


#/  MASK MEAN GRID
#   TODO:  May 7 - update this with a proper landmask
# Get mean of predictions (including NAs) to be used as mask
# m1_mean <- calc(m1, fun=mean, na.rm=T, progress='text')

# Apply mask
m1_0_mean_masked <- mask(m1_0_mean, datmask)

# Save masked mg map as raster
writeRaster(m1_0_mean_masked, paste0(vdir,'for_map/upch4_v04_m1_mgCH4m2day_Aw_mean_msk.tif'))



# /----------------------------------------------------#
#/  MEAN VARIANCE GRID  
print('getting avg variance grid')

#   Calculate average of member
m1 <- stack(paste0(vdir,'stack/upch4_v04_m1_mgCH4m2day_Aw.nc'), varname='var_ch4')

# Replace NAs by 0s before averaging
m1_0 <- calc(m1, function(x){ x[is.na(x)] <- 0; return(x) } , progress='text')

# Calculate mean flux of grid with 0s - these are the actual values to map
m1_0_mean <- calc(m1_0, fun=mean, na.rm=T, progress='text')

# Save mean raster - unamsked
writeRaster(m1_0_mean, paste0(vdir,'for_map/upch4_v04_m1_mgCH4m2day_Aw_var.tif'))

#/  MASK
#   TODO:  May 7 - update this with a proper landmask
# Get mean of predictions (including NAs) to be used as mask
# m1_mean <- calc(m1, fun=mean, na.rm=T, progress='text')

# Apply mask
m1_0_mean_masked <- mask(m1_0_mean, datmask)

# Save masked mg map as raster
writeRaster(m1_0_mean_masked, paste0(vdir,'for_map/upch4_v04_m1_mgCH4m2day_Aw_var_msk.tif'))


print('processed average of mean and var flux')

endCluster()