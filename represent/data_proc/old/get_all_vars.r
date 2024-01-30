
# Get grid stack of variables
# 1 to 5, to exclude radiation
vars <- stack('../output/results/grids/representativeness_vars/subset_vars.tif')[[1:5]]

# name the images in stack
varnames <-  c('LAI_F_LEAD24m', 'SRWI_F_LAG8m', 'LEm', 'RECO_DTm', 'mat') #, 'Rpotm')
names(vars) <- varnames 

# apply wetland mask
Fw_mean_mask[Fw_mean_mask<0.05] <- NA
vars_msk <- mask(vars, Fw_mean_mask)

wet_area <- Fw_mean_mask * raster::area(Fw_mean_mask)
names(wet_area) <- c('wet_area')
vars_msk <- stack(vars_msk, wet_area)



# Reformat the rasters in df so for use with ggplot
# This now get replaced by the robin version
# vars_msk_df <- as.data.frame(as(vars_msk, "SpatialPixelsDataFrame"))
# vars_msk_df <- vars_msk_df %>% dplyr::select(-x, -y)


# /---------------------------------------------------------------------------------
#/  Extract vars at tower sites
#   done on  unmasked grids (bc some sites are in low wetland regions)
towers_vars <- cbind(towers_wet_pts@data, data.frame(raster::extract(vars, towers_wet_pts)))


# /------------------------------------------------------------------------------------
#/ Reproject Vars to Robin for maps
crs(vars_msk) <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0' 
vars_msk_robin <- projectRaster(vars_msk, crs=CRS('+proj=robin'), method='ngb', over=TRUE)
vars_msk_robin_df <- as(vars_msk_robin, 'SpatialPixelsDataFrame')
vars_msk_robin_df <- as.data.frame(vars_msk_robin_df)

# pass off the robin version so that the x&y are robin
vars_msk_df = vars_msk_robin_df


# glimpse(vars_msk_df)




#===================================================================================================
# # Normalize the climatic variable between 0 and 1
# rescale01 <- function(x) { 
#   r_min = cellStats(x, stat = 'min')
#   r_max = cellStats(x, stat = 'max')
#   range = r_max - r_min
#   rescaled = (x - r_min) / range 
#   return(rescaled)
#   }

# # apply to 
# vars_sc <- rescale01(vars)
# vars_msk_sc <- rescale01(vars_msk)

# names(vars_msk_robin_df) <- c('layer', 'x', 'y')

# towers_vars <- data.frame(raster::extract(vars_sc, towers_wet_pts))

# vars_msk_robin_df <- vars_msk_robin_df[complete.cases(vars_msk_robin_df), ]

# # apply to 
# vars_sc <- rescale01(vars)
# vars_msk_sc <- rescale01(vars_msk)

# # Reformat the rasters so for use with ggplot
# vars_msk_sc_df <- as.data.frame(as(vars_msk_sc, "SpatialPixelsDataFrame"))
# vars_msk_sc_df <- vars_msk_sc_df %>% select(-x, -y)

# # /---------------------------------------------------------------------------------
# #/  Extract tower points from unmasked grids (bc some sites are in low wetland regions)
# # towers_vars <- data.frame(raster::extract(vars_sc, towers_wet_pts))
# towers_vars <- cbind(towers_wet_pts@data, data.frame(raster::extract(vars_sc, towers_wet_pts)))