# Get grid stack of variables
# 1 to 5, to exclude radiation
vars <- stack('../output/results/grids/representativeness_vars/subset_vars_4preds.tif')# [[1:5]]

# name the images in stack
varnames <- c('EVI_F_LAG24m', 'SRWI_F_LAG8m', 'LEm', 'mat')
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

if(1){ write.csv(towers_vars, '../output/results/towers_vars_forSI.csv') }

# /------------------------------------------------------------------------------------
#/ Reproject Vars to Robin for maps
crs(vars_msk) <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0' 
vars_msk_robin <- projectRaster(vars_msk, crs=CRS('+proj=robin'), method='ngb', over=TRUE)
vars_msk_robin_df <- as(vars_msk_robin, 'SpatialPixelsDataFrame')
vars_msk_robin_df <- as.data.frame(vars_msk_robin_df)

# pass off the robin version so that the x&y are robin
vars_msk_df = vars_msk_robin_df


#### 
# In WGS84 for the latitudinal barplot
vars_msk_wgs84_df <- as(vars_msk, 'SpatialPixelsDataFrame')
vars_msk_wgs84_df <- as.data.frame(vars_msk_wgs84_df)

