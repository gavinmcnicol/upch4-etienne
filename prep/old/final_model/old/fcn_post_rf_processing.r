
# Convert units from nmol to Tg
conv.units.nmol.to.tg <- function(stack, Aw){
	# NOTE: CHECK THE YEARS- MIGHT BE A MISMATCH BETWEEN FLUX & Fw
	date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = nlayers(stack))  # 216

	# Conv nmol to Tg; assuming 30 day month
	conv <- stack * Aw * 1e-21 * 16.04246 * 2.592e+6
	names(conv) <- date_ls
	return(conv)
	}


# Convert units from nmolCH4 to mgC
conv.units.nmolCH4.to.mgC <- function(stack, Aw){
	# NOTE: CHECK THE YEARS- MIGHT BE A MISMATCH BETWEEN FLUX & Fw
	date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = nlayers(stack))  # 216

	# Conv nmol to Tg; assuming 30 day month
	conv <- stack * Aw / pixarea_m2  #* 1e-21 * 16.04246 * 2.592e+6
	
	# Conver nmol to mol;  now i have mol CH4
	# 1 nmol == 1e-9 mol
	conv = conv *  1e-9
	# convert mol to gC
	conv = conv * 12.0107
	# convert s-1 to day-1
	conv = conv * 86400

	names(conv) <- date_ls
	return(conv)
	}


# Make monthly composite by averages per month
monthly.composite <- function(instack, outname){

	# Make list of month groupings
	date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = nlayers(instack))
	monthly_composite_grp = month(as.Date(date_ls))

	# Take mean, excluding NAs  (should we consider NAs as Zeros?)
	f = function(v){tapply(v, monthly_composite_grp, mean)}
	monthly_mean_composite = calc(instack, f)

	writeRaster(monthly_mean_composite, outname)
	}


# THIS PARALLEL DOESNT WORK YET --- BUT CLOSE TO WORKING;  CURRENTLY NOT USED
# CHECK EXPORT PART OF FUNCTION 
# Get summary (min, mean, max) of RF models per timestep
# https://www.gis-blog.com/increasing-the-speed-of-raster-processing-with-r-part-33-cluster/
# https://stat.ethz.ch/pipermail/r-sig-geo/2013-November/019833.html
# summarize_stack_par <- function(stack, nummodels, summaryfcn, oufilename, ncores){

# 	nlay <- length(names(stack))

# 	# Make group label list; labels rasters from same timestep together
# 	groupn = function(n,m){rep(1:m,rep(n/m,m))}
# 	timestep_grp = groupn(nlay, nlay/nummodels )

# 	# Make function 
# 	f = function(x){tapply(x, timestep_grp, summaryfcn)}
# 	# min_stack = calc(stack, f)

# 	beginCluster(ncores)
# 	summarizedstack <- clusterR(stack, calc, args=list(fun=f, na.rm=TRUE), export=c('timestep_grp','summaryfcn'))
# 	endCluster()

# 	writeRaster(summarizedstack, oufilename)  # paste0(modelname, '_min_unweighted_nmol.tif'))
# 	}


post_rf_processing <- function(stack, modelname){

	# /---------------------------------------------------------------------------#
	#/   Get min, mean, max of models for each month                          -----
	nlay <- length(names(stack))

	# MAke group label list
	groupn = function(n,m){ rep(1:m,rep(n/m,m)) }
	timestep_grp = groupn(nlay, nlay/24 )

	#  Get min of 24 RF model per timestep
	f = function(v){tapply(v, timestep_grp, min)}
	min_stack = calc(stack, f)

	#  Get max of 24 RF model per timestep
	f = function(v, fun){tapply(v, timestep_grp, mean)}
	mean_stack = calc(stack, f)

	#  Get max of 24 RF model per timestep
	f = function(v){tapply(v, timestep_grp, max)}
	max_stack = calc(stack, f)

	# Save mean, min, max time-series
	writeRaster(min_stack, paste0(modelname, '_min_unweighted_nmol.tif'))
	writeRaster(mean_stack,paste0(modelname, '_mean_unweighted_nmol.tif'))
	writeRaster(max_stack, paste0(modelname, '_max_unweighted_nmol.tif'))

	min_stack  <- stack(paste0(modelname, '_min_unweighted_nmol.tif'))
	mean_stack <- stack(paste0(modelname, '_mean_unweighted_nmol.tif'))
	max_stack  <- stack(paste0(modelname, '_max_unweighted_nmol.tif'))


	# summarize_stack_par(stack=stack, 
	# 				nummodels=24, 
	# 				summaryfcn=mean, 
	# 				oufilename=paste0(modelname, '_mean_unweighted_nmol.tif'), 
	# 				ncores=8)

	# /------------------------------------------------------------------------#
	#/     Get wetland area from SWAMPS-GLWD                             -------
	#      Do this out of function to avoid repeat

	f <- '/home/groups/robertj2/upch4/data/wetland_area/wad2m/gcp-ch4_wetlands_2000-2018_025deg.nc'   # 216 long

	# Generic model, limit to 2001-2018
	if(modelname=='gen') {  Fw <- brick(f, varname='Fw')[[13:228]]  }
	# All model, limit to 2003-2013
	if(modelname=='all') {	Fw <- brick(f, varname='Fw')[[37:168]]  }


	# Crop Fw to match the flux prediction grids
	com_ext <- extent(-180, 180,  -56, 85)
	Fw <- crop(Fw, com_ext)
	extent(Fw) <- com_ext

	#   Get pixel area (m^2)
	pixarea_m2 <- area(Fw[[1]]) * 10^6

	Aw = Fw * pixarea_m2 # Convert wetland fraction to  area
	# Fw_mask[Fw_mask == 0] <- NA


	# /--------------------------------------------------------------------------#
	#/     Convert units of grids from nmol m-2 sec-1  to Tg month-1
	#   DO THIS FOR iLAMB COMPARISON
	min_conv <- conv.units.nmolCH4.to.mgC(min_stack,  Aw)
	mean_conv<- conv.units.nmolCH4.to.mgC(mean_stack, Aw)
	max_conv <- conv.units.nmolCH4.to.mgC(max_stack,  Aw)

	writeRaster(min_conv, paste0(modelname, '_min_weighted_mgC.tif'))
	writeRaster(mean_conv,paste0(modelname, '_mean_weighted_mgC.tif'))
	writeRaster(max_conv, paste0(modelname, '_max_weighted_mgC.tif'))



	# /--------------------------------------------------------------------------#
	#/     Convert units of grids from nmol m-2 sec-1  to Tg month-1
	min_conv <- conv.units.nmol.to.tg(min_stack,  Aw)
	mean_conv<- conv.units.nmol.to.tg(mean_stack, Aw)
	max_conv <- conv.units.nmol.to.tg(max_stack,  Aw)

	writeRaster(min_conv, paste0(modelname, '_min_weighted_tg.tif'))
	writeRaster(mean_conv,paste0(modelname, '_mean_weighted_tg.tif'))
	writeRaster(max_conv, paste0(modelname, '_max_weighted_tg.tif'))


	# /---------------------------------------------------------------------#
	#/      Make TOTAL sums                                            ------
	min_sum <- as.data.frame(cellStats(min_conv, sum))
	mean_sum<- as.data.frame(cellStats(mean_conv, sum))
	max_sum <- as.data.frame(cellStats(max_conv, sum))

	# Combine to single df
	date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = nlayers(mean_conv))
	sum_df <- bind_cols(data.frame(date_ls), min_sum, mean_sum, max_sum)
	names(sum_df) <- c('date','min','mean','max')

	# Save to CSV file
	write.csv(sum_df, paste0('../../sums/', modelname, '_tg_sum.csv'))


	# /------------------------------------------------------------------------#
	#/   Unweighted monthly composite of unweighted nmol                ------- 
	monthly.composite(mean_stack, paste0(modelname, '_mean_unweighted_nmol_mcomp.tif'))
	#/   Weighted monthly composite for GIF: of Tg month-1
	monthly.composite(mean_conv, paste0(modelname, '_mean_weighted_tg_mcomp.tif'))
	

	# /------------------------------------------------------------------------#
	#/   Make monthly composite for GIF: of mg m^2 day                   -------
	#  scaled with wetland, then divided by pixel area

	mean_comp_tg_month <- brick(paste0(modelname, '_mean_unweighted_nmol_mcomp.tif'))

	pixarea_m2 <- area(mean_comp_tg_month[[1]]) * 10^6  	#   Get pixel area (m^2)
	mean_comp_mg_m2_day <- mean_comp_tg_month * 1e+15 / pixarea_m2 / 30

	writeRaster(mean_comp_mg_m2_day, paste0(modelname, '_mean_weighted_mg_mcomp.tif'))


	# /------------------------------------------------------------------------#
	#/  Average map in   mgCH4 m-2 day-1                                -------
	#  scaled with wetland, then divided by pixel area
	mean_comp_mg_m2_day <- mean_conv * 1e+15 / pixarea_m2 / 30

	# Average the stack, considering NAs as 0s; gives lower values
	avg_mg_m2_day <- calc(mean_comp_mg_m2_day, sum, na.rm=TRUE) / nlayers(mean_conv)

	writeRaster(avg_mg_m2_day, paste0(modelname, '_mean_weighted_mg_avg.tif'))

	}




# Get wetland-weighted Tg 
# mean_conv <- brick('rf_mean_ch4_monthly_2001_2018_tg_month.tif')
#   Get pixel area (m^2)
# pixarea_m2 <- area(mean_conv[[1]]) * 10^6
# mean_conv <- brick(paste0(modelname, '_mean_weighted_tg.tif'))  # Get Tg grids

# monthly_composite_grp = month(as.Date(date_ls))  # Make list of month groupings

# #  Average per month, across years
# f = function(v){tapply(v, monthly_composite_grp, mean)}
# monthly_mean_composite = calc(mean_conv, f)

# writeRaster(monthly_mean_composite, 'rf_mean_ch4_monthly_2001_2018_tg_month_composite.tif')


# min_stack <- brick('rf_min_ch4_monthly_2001_2018.tif')
# mean_stack<- brick(paste0(modelname, '_mean_unweighted_nmol.tif'))
# max_stack <- brick('rf_max_ch4_monthly_2001_2018.tif')