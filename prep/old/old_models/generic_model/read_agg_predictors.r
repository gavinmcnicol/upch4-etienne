print('Reading agg 0.25deg predictors')


dir = "../data/predictors/generic/"

# Get list of predictor names 
# 'HD7','sgrid_ph','sgrid_cc','Rpot_LAG30','Rpot_LAG90','Var' ,'HD9','wc7','sin.day','cos.day'
#  tif ,  tif     ,  tif     , nc         ,   nc       , tif  , tif , tif ,  nc   , nc 

# /----------------------------------------------------------------------------#
#/    Read aggregated predictors

com_ext <- extent(-180, 180,  -56, 85)

sgrids_ph <- raster(paste0(dir, 'agg_025/', 'sgrids_ph_025.tif'))
sgrids_cc <- raster(paste0(dir, 'agg_025/', 'sgrids_cc_025.tif'))
Var <- raster(paste0(dir, 'agg_025/', 'Var_025.tif'))
HD7 <- raster(paste0(dir, 'agg_025/', 'HD7_025.tif'))
HD9 <- raster(paste0(dir, 'agg_025/', 'HD9_025.tif'))
wc7 <- raster(paste0(dir, 'agg_025/', 'wc7_025.tif'))

# Set extents of stacks
# Set extent to -180, 180,  -56, 85
sgrids_ph <- crop(sgrids_ph, com_ext)
extent(sgrids_ph) <- com_ext


sgrids_cc <- crop(sgrids_cc, com_ext)
extent(sgrids_cc) <- com_ext

Var <- crop(Var, com_ext)
extent(Var) <- com_ext


HD7 <- crop(HD7, com_ext)
HD9 <- crop(HD9, com_ext)
wc7 <- crop(wc7, com_ext)
# 228 months = 19 years
# Jan 2000 to Dec 2018


Rpot   <- stack(paste0(dir, "Rpot.nc"))
sinday <- stack(paste0(dir, "sin_day.nc"))
cosday <- stack(paste0(dir, "cos_day.nc"))

Rpot <- crop(Rpot, com_ext)
sinday <- crop(sinday, com_ext)
cosday <- crop(cosday, com_ext)

