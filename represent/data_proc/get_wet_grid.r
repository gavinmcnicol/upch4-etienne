
f <- '/home/groups/robertj2/upch4/data/wetland_area/wad2m/gcp-ch4_wetlands_2000-2018_025deg.nc'   # 216 long

# All model, limit to 2003-2013
Fw <- stack(f, varname='Fw')[[37:168]]

com_ext <- extent(-180, 180,  -56, 85)

# Crop Fw to match the flux prediction grids
Fw_mean <- calc(Fw, mean, na.rm=T) %>% crop(com_ext)
# extent(Fw) <- com_ext

#   Get pixel area (m^2)
pixarea_m2 <- raster::area(Fw_mean) * 10^6
Aw = Fw_mean * pixarea_m2 # Convert wetland fraction to  area

# Make mask
Fw_mean_mask <- Fw_mean
Fw_mean_mask[Fw_mean_mask < 0.01] <- NA







# # Read wetland map
# # Fw = fraction wetland
# Fw_max <- raster('data/Wetland Map/Fw_max.tif')

# # Exclude pixels 
# Fw_max[Fw_max < 0.025] <- NA

# # Crop out Antartica, not relevant to the Area Of Interest (aoi)
# aoi = extent(c(xmin = -180, xmax = 180, ymin = -58, ymax = 90))
# bioclim_stack <- crop(bioclim_stack, aoi)
# Fw_max <- crop(Fw_max, aoi)

# # Create mask
# bioclim_stack <- mask(bioclim_stack, Fw_max)
# bioclim_stack_df <- as.data.frame(as(bioclim_stack, "SpatialPixelsDataFrame"))
# Fw_max_df <- as.data.frame(as(Fw_max, "SpatialPixelsDataFrame"))



# # Cropping and masking for individual climatic variables that I chose
# tmp_stack <- crop(tmp_stack, aoi)
# pre_stack <- crop(pre_stack, aoi)
# tmp_stack <- mask(tmp_stack, Fw_max)
# pre_stack <- mask(pre_stack, Fw_max)
# tmp_df <- as.data.frame(as(tmp_stack, "SpatialPixelsDataFrame"))
# pre_df <- as.data.frame(as(pre_stack, "SpatialPixelsDataFrame"))

# # Times 12 as current dataset is average monthly precipitation
# pre_df$pre_avg <- pre_df$pre_avg * 12
