#/     Get random forest model (list of 24 models)
rf_model <- readRDS('../data/random_forest/mar2020/200319_FWET_ALL_tune.rds')
# rf[[1]]$finalModel$xNames
#  [1] 'EVI_F_LAG24'  'LSWI_F_LAG16' 'SRWI_F_LAG8'  'aetS_LAG60'   'LAI_F_LEAD24'
#  [6] 'LSWI_F_LAG8'  'LE'           'LE_LAG30'     'soilwaterR'   'RECO_DT'     
# [11] 'sgrids_oc'    'Diss'         'wc7'  


# /----------------------------------------------------------------------------#
#/      Make random forest predictions of flux                            ------

library(doParallel)  

# no_cores <- detectCores(3) #- 1  type='FORK',
cl <- makeCluster(6, type='FORK', outfile='par_foreach_log_cl4_all.txt')  
registerDoParallel(cl)
# cl <- parallel::makeForkCluster(2)
# doParallel::registerDoParallel(cl)

temp_stack <- stack()  # Make empty stack to initialize

# Nested parallelized loops
pred_flux_stack <- 
foreach(i = 1:132, .packages=c('raster','ranger'), .combine=stack, .init=temp_stack)  %:%
  # No calculation can be between the 2 foreach, so inputs are read at every loop
  foreach(m=1:length(rf_model), .packages=c('raster','ranger'), .combine=stack, .init=temp_stack) %dopar% { 

  print(paste0('i',i,'_','m',m))

  # stack the predictor grids for timestep
  predictor_stack <-stack(EVI_F_LAG24[[i]],      # monthly; lag built-in
                          LSWI_F_LAG16[[i]],     # monthly; lag built-in
                          SRWI_F_LAG8[[i]],      # monthly; lag built-in
                          aetS_LAG60[[ifelse(i%%12==0, 12, i%%12)]],   # avg month; get month
                          LAI_F_LEAD24[[i]],     # monthly; lead built-in
                          LSWI_F_LAG8[[i]],      # monthly; lag built-in
                          LE[[i+1]],             # monthly; lag built-in
                          LE[[i]],               # apply 1 month lag
                          soilwaterR[[((i-1)%/%12)+1]],  # yearly; use integer division
                          RECO_DT[[i]],          # monthly
                          sgrids_oc,             # static
                          Diss,                  # static
                          wc7)                   # static

  # Rename columns to match training set
  names(predictor_stack) <- c('EVI_F_LAG24', 'LSWI_F_LAG16', 'SRWI_F_LAG8', 'aetS_LAG60', 'LAI_F_LEAD24', 
                              'LSWI_F_LAG8', 'LE', 'LE_LAG30', 'soilwaterR', 'RECO_DT', 'sgrids_oc', 'Diss','wc7')

  # predictor_stack_df <- as.data.frame(predictor_stack, xy = F, na.rm = T)

  # /------------------------------------------------------------------------#
  #/    Apply RF directly to stack of predictors (in namoles / m^2 / sec)
  r <- raster::predict( predictor_stack, rf_model[[m]], na.rm=TRUE)  # progress='text', 

  # write name of raster
  names(r) <- paste0('i',i,'_','m',m)
  return(r)
  }


writeRaster(pred_flux_stack,  filename='../output/results/grids/v02/all_pred_flux_025deg.tif')

parallel::stopCluster(cl)




# # assign i number to rasters
# names(temp_stack) <- rep(1:18, each=24) 

# /------------------------------------------------------------------------------------
#/    Convert units predicted flux & mask                                
#     Also saves output to NCDF file
# source('./prep/conv_flux_units.r')
# print( ' - Converted units')

# # close ncdf files
# nc_close(Rpot)
# nc_close(sinday)
# nc_close(cosday)
