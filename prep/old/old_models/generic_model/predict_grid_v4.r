
# Function that gets MERRA time slice from ncdf file
source("./prep/fcn/fcn_get_timeslice_fromnc.r")

#/     Get random forest model (list of 24 models)
rf_model <- readRDS("../data/random_forest/mar2020/200417_FWET_generic_tune.rds")
# rf[[1]]$finalModel$xNames


# /----------------------------------------------------------------------------#
#/      Make random forest predictions of flux                            ------

library(doParallel)  

# no_cores <- detectCores(3) #- 1  
cl <- makeCluster(3, type="FORK", outfile="par_foreach_log_generic_cl4.txt")  
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

  # /------------------------------------------------------------------------#
  #/    Apply RF directly to stack of predictors (in namoles / m^2 / sec)
  r <- raster::predict( predictor_stack, rf_model[[m]], na.rm=TRUE)  # progress="text", 

  # write name of raster
  names(r) <- paste0('i',i,'_','m',m)
  return(r)
  }

writeRaster(pred_flux_stack, "../output/results/grids/v02/generic_pred_flux_stack_v4.tif")


parallel::stopCluster(cl)


# close ncdf files
nc_close(Rpot)
nc_close(sinday)
nc_close(cosday)



# predictor_stack_df <- as.data.frame(predictor_stack, xy = F, na.rm = T)



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