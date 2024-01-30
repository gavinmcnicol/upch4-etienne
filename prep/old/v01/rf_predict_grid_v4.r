
# Function that gets MERRA time slice from ncdf file
source("./prep/fcn/fcn_get_timeslice_fromnc.r")

#/     Get random forest model (list of 24 models)
rf_model <- readRDS("../data/random_forest/mar2020/200417_FWET_generic_tune.rds")
# rf[[1]]$finalModel$xNames

# Get list of predictor names 
# 'HD7','sgrid_ph','sgrid_cc','Rpot_LAG30','Rpot_LAG90','Var' ,'HD9','wc7','sin.day','cos.day'
#  tif ,  tif     ,  tif     , nc         ,   nc       , tif  , tif , tif ,  nc   , nc 

dir = "../data/generic_predictors/"


# /----------------------------------------------------------------------------#
#/  Aggregate  Static predictors  
#     Aggregate grids to 0.25 deg



if(1){


  com_ext <- extent(-180, 180,  -56, 85)

  sgrids_cc <- raster(paste0(dir, "sgrids_cc.tif"))
  sgrids_cc <- crop(sgrids_cc, com_ext)
  extent(sgrids_cc) <- com_ext
  sgrids_cc <- aggregate(sgrids_cc, fact=120, fun=mean, na.rm=TRUE)

  sgrids_ph <- raster(paste0(dir, "sgrids_ph.tif"))
  sgrids_ph <- crop(sgrids_ph, com_ext)
  extent(sgrids_ph) <- com_ext
  sgrids_ph <- aggregate(sgrids_ph, fact=120, fun=mean, na.rm=TRUE)   # original res= 0.0020833
  

  Var       <- aggregate(raster(paste0(dir, "Var.tif")) ,     fact=30, fun=mean, na.rm=TRUE)
  HD7       <- aggregate(raster(paste0(dir, "HD7.tif")),      fact=30, fun=mean, na.rm=TRUE)
  HD9       <- aggregate(raster(paste0(dir, "HD9.tif")),      fact=30, fun=mean, na.rm=TRUE)
  wc7       <- aggregate( raster("../data/bioclim/wc2.0_bio_5m_07.tif "),  fact=3, fun=mean, na.rm=TRUE)
  


  writeRaster(sgrids_ph, paste0(dir, 'agg_025/', 'sgrids_ph_025.tif'), overwrite=TRUE)
  writeRaster(sgrids_cc, paste0(dir, 'agg_025/', 'sgrids_cc_025.tif'), overwrite=TRUE)
  writeRaster(Var, paste0(dir, 'agg_025/', 'Var_025.tif'), overwrite=TRUE)
  writeRaster(HD7, paste0(dir, 'agg_025/', 'HD7_025.tif'), overwrite=TRUE)
  writeRaster(HD9, paste0(dir, 'agg_025/', 'HD9_025.tif'), overwrite=TRUE)
  writeRaster(wc7, paste0(dir, 'agg_025/', 'wc7_025.tif'), overwrite=TRUE)
}


# /----------------------------------------------------------------------------#
#/    Read MERRA2 data as raster bricks  

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




# /----------------------------------------------------------------------------#
#/      Make random forest predictions of flux                            ------

library(doParallel)  

# no_cores <- detectCores(3) #- 1  
cl <- makeCluster(3, type="FORK", outfile="par_foreach_log_cl4.txt")  
registerDoParallel(cl)
# cl <- parallel::makeForkCluster(2)
# doParallel::registerDoParallel(cl)

temp_stack <- stack()  # Make empty stack to initialize


# Nested parallelized loops

pred_flux_stack <- 
foreach(i = 13:228, .packages=c("ncdf4",'raster','ranger'), .combine = stack, .init=temp_stack)  %:%
  # No calculation can be between the 2 foreach, so inputs are read at every loop
  foreach(m=1:length(rf_model),.packages=c("ncdf4",'raster','ranger'), .combine = stack, .init=temp_stack) %dopar% { 

  # sink("log.txt", append=TRUE)  #  writes outputs
  print(paste0('i',i,'_','m',m))

  # stack the predictor grids for timestep
  predictor_stack <-stack(HD7, sgrids_ph, sgrids_cc, Rpot[[i-1]], Rpot[[i-3]],
                          Var,  HD9, wc7, sinday[[i]], cosday[[i]] )

  # Rename columns to match training set
  names(predictor_stack) <- c('HD7','sgrids_ph','sgrids_cc','Rpot_LAG30','Rpot_LAG90','Var' ,'HD9','wc7','sin.day','cos.day')

  # predictor_stack_df <- as.data.frame(predictor_stack, xy = F, na.rm = T)

  # /------------------------------------------------------------------------#
  #/    Apply RF directly to stack of predictors (in namoles / m^2 / sec)
  r <- raster::predict( predictor_stack, rf_model[[m]], na.rm=TRUE)  # progress="text", 

  # write name of raster
  names(r) <- paste0('i',i,'_','m',m)
  return(r)
  }



writeRaster(pred_flux_stack, 
            filename="../output/results/grids/v02/pred_flux_stack_v4.tif", 
            overwrite=TRUE)


parallel::stopCluster(cl)

# # assign i number to rasters
# names(temp_stack) <- rep(1:18, each=24) 


# /------------------------------------------------------------------------------------
#/    Convert units predicted flux & mask                                
#     Also saves output to NCDF file
# source("./prep/conv_flux_units.r")
# print( " - Converted units")

# close ncdf files
nc_close(Rpot)
nc_close(sinday)
nc_close(cosday)


# Rpot   <- nc_open(paste0(dir, "Rpot.nc"),    readunlim=FALSE )
# sinday <- nc_open(paste0(dir, "sin_day.nc"), readunlim=FALSE )
# cosday <- nc_open(paste0(dir, "cos_day.nc"), readunlim=FALSE )

  # Get timestep slice
  # Rpot_lag30_sl <- get_tslice(Rpot, i-1)
  # Rpot_lag90_sl <- get_tslice(Rpot, i-3)
  # sinday_sl     <- get_tslice(sinday, i)
  # cosday_sl     <- get_tslice(cosday, i)
  # Rpot_lag30_sl <- crop(Rpot_lag30_sl, com_ext)
  # Rpot_lag90_sl <- crop(Rpot_lag90_sl, com_ext)
  # sinday_sl <- crop(sinday_sl, com_ext)
  # cosday_sl <- crop(cosday_sl, com_ext)


  # Rpot_lag30_sl <- Rpot[[i-1]]
  # Rpot_lag90_sl <- Rpot[[i-3]]
  # sinday_sl     <- sinday[[i]]
  # cosday_sl     <- cosday[[i]]



  # # Get pixel-wise summary of grid; raster::calc is multiprocessor function.
  # r_med <- calc(temp_stack, function(x){median(x)})
  # r_min <- calc(temp_stack, function(x){min(x)})
  # r_max <- calc(temp_stack, function(x){max(x)})

  # # name the output grid name
  # names(r_med) <- names(paste0("t", i))
  # names(r_min) <- names(paste0("t", i))
  # names(r_max) <- names(paste0("t", i))

  
  # # Add output grid to stack
  # if (exist(med_stack)) {med_stack <- stack(med_stack, r_med) } else {med_stack <- r_med}
  # if (exist(max_stack)) {max_stack <- stack(max_stack, r_max) } else {max_stack <- r_max}
  # if (exist(min_stack)) {min_stack <- stack(min_stack, r_min) } else {min_stack <- r_min}

# clean up env
# rm(temp_stack, r_med, r_max, r_min, predictor_stack)