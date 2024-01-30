

# Function that gets MERRA time slice from ncdf file
source("./prep/fcn/fcn_get_merra2_tslice.r")


# /----------------------------------------------------------------------------#
#/     Get random forest model
#      This is a list of random forest models.
rf_model <- readRDS("../data/random_forest/june2019/190530_rf_wetlands_monthly_MET_subset.rds")


# /----------------------------------------------------------------------------#
#/    Read MERRA2 data as raster bricks  

dir = "../data/merra2/monthly/"

dlwrf <- nc_open(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"), readunlim=FALSE )
dswrf <- nc_open(paste0(dir, "merra2.0.5d.dswrf.monthly.nc"), readunlim=FALSE )
pre   <- nc_open(paste0(dir, "merra2.0.5d.pre.monthly.nc"),   readunlim=FALSE )
pres  <- nc_open(paste0(dir, "merra2.0.5d.pres.monthly.nc"),  readunlim=FALSE )
spfh  <- nc_open(paste0(dir, "merra2.0.5d.spfh.monthly.nc"),  readunlim=FALSE )
tmp   <- nc_open(paste0(dir, "merra2.0.5d.tmp.monthly.nc"),   readunlim=FALSE )
print(" - Opened MERRA2 NetCDFs")

# print(dlwrf)

# /----------------------------------------------------------------------------#
#/     Get list of time dimension
#      Time dimension of MERRA2: minutes since 1980-1-1 00:30:00"
t <- nc_open(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"))
minutes_since1980 <- c(t$dim$time$vals)
nc_close(t)

# convert time since 1980 to dates (YYYY-MM)
parseddates <- ymd_hms("1980-1-1 00:30:00") + minutes(minutes_since1980) # %m+%
parseddates <- as.Date(parseddates)

# subset to list starting in 2000-01
parseddatessubset <- parseddates[241:length(parseddates)]

# Save list
saveRDS(parseddates, '../output/results/parsed_dates.rds')


# /----------------------------------------------------------------------------#
#/    Get BioClim data open  

dir = "../data/bioclim/"
bioclim_01   <- raster(paste0(dir, "wc2.0_bio_5m_01.tif")) # BIO1 = Annual Mean Temperature
bioclim_05   <- raster(paste0(dir, "wc2.0_bio_5m_05.tif")) # BIO5 = Max Temp. of Warmest Month
bioclim_06   <- raster(paste0(dir, "wc2.0_bio_5m_06.tif")) # BIO6 = Min Temp. of Coldest Month
bioclim_10   <- raster(paste0(dir, "wc2.0_bio_5m_10.tif")) # BIO10 = Mean Temp. of Warmest Quarter
bioclim_11   <- raster(paste0(dir, "wc2.0_bio_5m_11.tif")) # BIO11 = Mean Temp. of Coldest Quarter


# Aggregate grids to 0.5 deg
bioclim_01   <- aggregate(bioclim_01, fact=6, fun=mean)
bioclim_05   <- aggregate(bioclim_05, fact=6, fun=mean)
bioclim_06   <- aggregate(bioclim_06, fact=6, fun=mean)
bioclim_10   <- aggregate(bioclim_10, fact=6, fun=mean)
bioclim_11   <- aggregate(bioclim_11, fact=6, fun=mean)
print(" - Aggregated BioClim grids")


# /----------------------------------------------------------------------------#
#/      Make random forest predictions of flux                            ------


### THESE ARE CONTROLLED THROUGH : RUNALL input ~~~~~
# foreach(i = 1:length(parseddates[indx_date_start:indx_date_end]), .packages="ncdf4") %dopar% {
# loop through timesteps
for (i in 1:length(parseddates[indx_date_start:indx_date_end])) {  
#   indx_date_start = 1
#   indx_date_end =length(parseddates)
#   Loop through each time step 

# to modify align indices with those of MERRA2, not of 
  i = i + 240
  
  print(paste0("Loop for:  ", parseddates[i], "  at index: ", i))

  dlwrf_sl <- get_merra_tslice(dlwrf,i)
  dswrf_sl <- get_merra_tslice(dswrf,i)
  pre_sl   <- get_merra_tslice(pre,  i)
  pres_sl  <- get_merra_tslice(pres, i)
  spfh_sl  <- get_merra_tslice(spfh, i)
  tmp_sl   <- get_merra_tslice(tmp,  i)


  # stack the predictor grids for timestep
  predictor_stack <-stack(dlwrf_sl, dswrf_sl, pre_sl, pres_sl, spfh_sl, tmp_sl, 
                          bioclim_01, bioclim_05, bioclim_06, bioclim_10, bioclim_11)

  # Rename columns to match training set
  names(predictor_stack) <- c("LW_M","SW_M","P_M", "PA_M", "RH_M", "TA_M",
                              "bio1", "bio5", "bio6", "bio10", "bio11")

  # /------------------------------------------------------------------------#
  #/    Apply RF directly to stack of predictors (in namoles / m^2 / sec)

  # Make empty stack to initialize
  temp_stack <- stack()

  # Loop through RF models; applying them in parallel; 
  temp_stack <- foreach(m = 1:2, #length(rf_model), 
                      .combine=stack, .init=temp_stack, .packages="raster") %dopar%{
    # Run random forest predictions
    raster::predict(predictor_stack, rf_model[[m]], progress="text", na.rm=TRUE)     
    }

  # Get pixel-wise summary of grid; raster::calc is multiprocessor function.
  r_med <- calc(temp_stack, function(x){median(x)})
  r_min <- calc(temp_stack, function(x){min(x)})
  r_max <- calc(temp_stack, function(x){max(x)})

  # name the output grid name
  names(r_med) <- names(paste0("t", i))
  names(r_min) <- names(paste0("t", i))
  names(r_max) <- names(paste0("t", i))

  
  # Add output grid to stack
  if (exist(med_stack)) {med_stack <- stack(med_stack, r_med) } else {med_stack <- r_med}
  if (exist(max_stack)) {max_stack <- stack(max_stack, r_max) } else {max_stack <- r_max}
  if (exist(min_stack)) {min_stack <- stack(min_stack, r_min) } else {min_stack <- r_min}
  
  }


# clean up env
rm(temp_stack, r_med, r_max, r_min, predictor_stack)


# close ncdf files
nc_close(dlwrf)
nc_close(dswrf)
nc_close(pre)
nc_close(pres)
nc_close(spfh)
nc_close(tmp)

# /------------------------------------------------------------------------------------
#/    Convert units predicted flux & mask                                
#     Also saves output to NCDF file
source("./prep/conv_flux_units.r")
print( " - Converted units")


  ### Parallelize predict?  Doesn't some 
  # beginCluster(4)
  # preds_rf<- clusterR(predictor_stack, raster::predict, 
  #                     args = list(model = rf_model), 
  #                     progress="text", overwrite=TRUE)  #  type="response")
  # endCluster()
