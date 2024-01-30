#  Extend  timeseries, make a lineplot of global Teragrams per month
#  use all 35 models & plot the median value at each pixel (or random subset of models)




# /----------------------------------------------------------------------------#
#/       create function that tests if object exists                      ------
exist <- function(x) { return(exists(deparse(substitute(x))))}


# /----------------------------------------------------------------------------#
#/     Get random forest model
rf_model <- readRDS("../data/random_forest/june2019/190530_rf_wetlands_monthly_MET_subset.rds")


# /----------------------------------------------------------------------------#
#/    Read MERRA2 data as raster bricks  

dir = "../data/merra2/monthly/"

dlwrf <- nc_open(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"), readunlim=FALSE )
dswrf <- nc_open(paste0(dir, "merra2.0.5d.dswrf.monthly.nc"), readunlim=FALSE )
pre   <- nc_open(paste0(dir, "merra2.0.5d.pre.monthly.nc"),   readunlim=FALSE )
pres  <- nc_open(paste0(dir, "merra2.0.5d.pres.monthly.nc"),  readunlim=FALSE )
spfh <- nc_open(paste0(dir, "merra2.0.5d.spfh.monthly.nc"),   readunlim=FALSE )
tmp <- nc_open(paste0(dir, "merra2.0.5d.tmp.monthly.nc"),     readunlim=FALSE )
print(" - Opened MERRA2 NetCDFs")

# Get list of 
# Time dimension of MERRA2: minutes since 1980-1-1 00:30:00"
# 999999986991104
t <- nc_open(paste0(dir, "merra2.0.5d.dlwrf.monthly.nc"))
min_since1980 <- t$dim$time$vals
nc_close(t)
# parse_date_time("1860-1-1", "ymd")  %m+% months(e$dim$time$vals)




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

# create empty raster stack
output_stack <- stack()


# loop through each time step 
for (i in seq(1, length(min_since1980[1:4]))) {
  print(paste0("Loop #:  ", i))


  dlwrf_sl <- get_merra_tslice(dlwrf, i)
  dswrf_sl <- get_merra_tslice(dswrf, i)
  pre_sl   <- get_merra_tslice(pre, i)
  pres_sl  <- get_merra_tslice(pres, i)
  spfh_sl  <- get_merra_tslice(spfh, i)
  tmp_sl   <- get_merra_tslice(tmp, i)

  # stack the predictor grids for timestep
  predictor_stack <-stack(dlwrf_sl, dswrf_sl, pre_sl, 
                          pres_sl, spfh_sl, tmp_sl, 
                          bioclim_01, bioclim_05, bioclim_06,
                          bioclim_10, bioclim_11)

  # Rename columns to match training set
  names(predictor_stack) <- c("LW_M","SW_M","P_M", "PA_M", "RH_M", "TA_M",
                              "bio1", "bio5", "bio6", "bio10", "bio11")
  
  # TODO: decide whether to mask the grid 
  # mask(lat, LST_Day_CMG_stack[[i]])

  # Apply RF directly to stack of predictors
  # predictions are in nanomoles / m^2 / sec

  z <- raster::predict(predictor_stack, rf_model[[1]], progress="text", na.rm=T)
  print("predicted grid")
  ## to parallelize
  # beginCluster()
  # preds_rf<- clusterR(rast, raster::predict, args = list(model = model))
  # endCluster()

  # name the output grid
  names(z) <- names(paste0("t", i))
  
  # Add output grid to stack
  if (exist(output_stack)) { output_stack <- stack(output_stack, z)
    } else { output_stack <- z }

  
  }

nc_close(dlwrf)
nc_close(dswrf)
nc_close(pre)
nc_close(pres)
nc_close(spfh)
nc_close(tmp)


# Save predictions as RDS
# it can then be visualized locally on laptop
saveRDS(output_stack, '../output/results/upscaling/upscaledch4_nmolm2sec.rds')
