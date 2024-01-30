# PARALLEL 
# # Get summary (min, mean, max) of RF models per timestep
# # https://www.gis-blog.com/increasing-the-speed-of-raster-processing-with-r-part-33-cluster/
# # https://stat.ethz.ch/pipermail/r-sig-geo/2013-November/019833.html

# Loop through members
# 	Read the ncdf
# 	Convert nmolCH4m2sec.to.gCm2day

# 4 versions of the upscaling that we need to produce:
# 1.  Raw predictions:       nmol m-2 sec-1      (unscaled)
# 2.  For iLAMB:             gC m-2 day-1        (unscaled)
# 3.  For Sanois-type map:   mgCH4 -m2 -day-1    (scaled) & for comparison vs Peltola
# 4.  For total emissions:   Tg month-1          (scaled)


beginCluster(n_cores, type='SOCK')

# Set common extent to crop with
com_ext <- extent(-180, 180,  -56, 85)


# Loop through 8 ensembles
for (m in c(start_members:n_members)){

	print(paste0('m:',m))

	### READ INPUTS
	nc_filename  <- paste0('../output/results/grids/v03/pred_v03_nmolm2sec_m', m, '.nc')

	# Read the inputs
	mean_stack <- stack(nc_filename, varname='mean_ch4')
	sd_stack   <- stack(nc_filename, varname='sd_ch4')
	var_stack  <- stack(nc_filename, varname='var_ch4')

	# Crop to same extent as WAD2M
	mean_stack <- crop(mean_stack, com_ext)
	sd_stack   <- crop(sd_stack, com_ext)
	var_stack <- crop(var_stack, com_ext)


	# /-----------------------------------------------------------------------------#
	#/  2 - For iLAMB: gC m-2 day-1  (unscaled)
	#   Read the nmol m-2 sec-1 inputs:  mean, sd, var

	# Convert to gCm2day
	nmolCH4m2sec.to.gCm2day <- function(x){ x *1e-9 *12.0107 *86400 }

	mean_gCm2day <- calc(mean_stack, fun=nmolCH4m2sec.to.gCm2day)
	sd_gCm2day   <- calc(sd_stack,  fun=nmolCH4m2sec.to.gCm2day)
	var_gCm2day  <- calc(var_stack, fun=nmolCH4m2sec.to.gCm2day)
	
	# Save to ncdf
	nc_filename <- paste0('../output/results/grids/v03/upch4_v03_m', m, '_gCm2day.nc')
	save.as.ncdf(nc_filename, 'gC m^2 day^-1', mean_gCm2day, sd_gCm2day, var_gCm2day)

	# Clean up workspace
	rm(mean_gCm2day, sd_gCm2day, var_gCm2day)



	# /-----------------------------------------------------------------------------#
	#/  3- For Sanois-type map:  mgCH4 -m2 -day-1   (scaled) & for comparison vs Peltola
	# 	Per m^2 of cell area (unscaled flux * wetland area / pixel area)
	#   1 nmol = mol 1e-9   ;   1molCH4 = 16.04246 g  ;    1g = 1000mg    ;  1 day =  2.592e+6  seconds

	# one mole of methane is 16.043 grams
	nmolCH4m2sec.to.mgCH4m2day <- function(x){ x *1e-9 * 16.04246 * 1000 *86400 }

	# Apply unit conv &  Scale by wetland area
	run.nmolCH4m2sec.to.mgCH4m2day.and.scaling <- function(instack){ 
		stack_mgCH4m2day <- calc(instack, fun=nmolCH4m2sec.to.mgCH4m2day)
		stack_mgCH4m2day <- overlay(stack_mgCH4m2day, Aw_m2, pixarea_m2, fun=function(s, Aw_m2, pixa) s * Aw_m2 / pixa )
		return(stack_mgCH4m2day) }

	mean_mgCH4m2day<- run.nmolCH4m2sec.to.mgCH4m2day.and.scaling(mean_stack)
	sd_mgCH4m2day  <- run.nmolCH4m2sec.to.mgCH4m2day.and.scaling(sd_stack)
	var_mgCH4m2day <- run.nmolCH4m2sec.to.mgCH4m2day.and.scaling(var_stack)

	# Save to ncdf
	nc_filename <- paste0('../output/results/grids/v03/upch4_v03_m', m, '_mgCH4m2day_Aw.nc')
	save.as.ncdf(nc_filename, 'mgCH4 m^2 day^-1', mean_mgCH4m2day, sd_mgCH4m2day, var_mgCH4m2day)

	# Clean up workspace
	rm(mean_mgCH4m2day, sd_mgCH4m2day, var_mgCH4m2day)



	# /-----------------------------------------------------------------------------#
	#/  4-  For total emissions:     TgCH4 month-1    (scaled) & for global sums
	#   old: 1e-21
	#   1 nmol = mol 1e-9   ;   1molCH4 = 16.04246 g  ;    1g = 1e-12 Tg    ;  1 month =  2.592e+6  seconds
	nmolCH4m2sec.to.TgCH4month <- function(x){ x * 1e-9 * 16.04246 * 1e-12 * 2.592e+6 }

	# Apply unit conv &  Scale by wetland area
	run.nmolCH4m2sec.to.TgCH4month.and.scaling <- function(instack){ 
		stack_TgCH4month <- calc(instack, fun=nmolCH4m2sec.to.TgCH4month)
		stack_TgCH4month <- overlay(stack_TgCH4month, Aw_m2, fun=function(s, Aw_m2) s * Aw_m2)
		return(stack_TgCH4month) }

	mean_TgCH4month<- run.nmolCH4m2sec.to.TgCH4month.and.scaling(mean_stack)
	sd_TgCH4month  <- run.nmolCH4m2sec.to.TgCH4month.and.scaling(sd_stack)
	var_TgCH4month <- run.nmolCH4m2sec.to.TgCH4month.and.scaling(var_stack)

	nc_filename <- paste0('../output/results/grids/v03/upch4_v03_m', m, '_TgCH4month_Aw.nc')
	save.as.ncdf(nc_filename, 'TgCH4 month^-1 pixel^-1', mean_TgCH4month, sd_TgCH4month, var_TgCH4month)

	# Clean up workspace
	rm(mean_TgCH4month, sd_TgCH4month, var_TgCH4month)

	}

endCluster()



# # Apply unit conv &  Scale by wetland area
# mean_mgCH4m2day <- calc(mean_stack, fun=nmolCH4m2sec.to.gCm2day)
# mean_mgCH4m2day <- overlay(mean_mgCH4m2day, Aw, pixarea_m2, fun=function(s, Aw, pixa) s * Aw / pixa )

# # Apply unit conv &  Scale by wetland area
# mean_mgCH4m2day <- calc(mean_stack, fun=nmolCH4m2sec.to.gCm2day)
# mean_mgCH4m2day <- overlay(mean_mgCH4m2day, Aw, pixarea_m2, fun=function(s, Aw, pixa) s * Aw / pixa )


# # /-----------------------------------------------------------------------------#
# #/  Run post processing                            

# # get rf output from all model; one file per ensemble member
# fname = paste0('pred_v03_nmolm2sec_m', n_members, '_t', n_timesteps, '_b', n_bootstraps, '.tif')
# stack <- brick(fname) 

# #--------------------------------------------------------------------------------
# # Make group label list; labels rasters from same timestep together
# groupn = function(n,m){rep(1:m,rep(n/m,m))}

# nlay <- length(names(stack))

# # Make list of group labels
# timestep_grp = groupn(nlay, nlay/n_bootstraps )

# f = function(x){tapply(x, timestep_grp, summaryfcn)}

# ###############################################################################
# # library(doParallel)  
# # cl <- makeCluster(1, type='FORK', outfile='par_foreach_log_finalmodel.txt')  
# # registerDoParallel(cl)
# beginCluster(n_cores, type='SOCK')

# # outstack <- stack()  # Make empty stack to initialize
# summary_stats = c('mean', 'sd', 'var') # 'median', 'min', 'max', 'sd')

# # NOTE: CHECK THE YEARS- MIGHT BE A MISMATCH BETWEEN FLUX & Fw
# date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = n_timesteps) #nlayers(stack))  # 216

# print('starting summary stats loop')

# #  COULDN'T GET THE clusterR inside dopar  to work...
# for (s in 1:length(summary_stats)) { 

# 	# Get summary stat string
# 	summaryfcn = summary_stats[s]
# 	print(summaryfcn)

# 	# RUN SUMMARY CALC - PARALLELIZED 
# 	summary_nmolm2sec <- calc(stack, fun=f)

# 	# RENAME OUTPUT RASTERS
# 	names(summary_nmolm2sec) <- date_ls 

# 	# WRITE nmol OUTPUT 
# 	out_fname = paste0('pred_v03_nmolm2sec_em1_', summaryfcn, '.tif')
# 	writeRaster(summary_nmolm2sec,  filename=out_fname)


# 	# /---------------------------------------------------------------------#
# 	#/ Convert units for iLAMB (gC m-2 d-1 that are unscaled by wetland area)
# 	#  This unit conversion is simpler, and might run faster bc of built-in parallel of 'calc'
# 	#  https://www.r-bloggers.com/2019/01/are-you-parallelizing-your-raster-operations-you-should/

# 	nmolCH4m2sec.to.gCm2day <- function(x){ x *1e-9 *12.0107 *86400 }
# 	summary_gCm2day <- calc(summary_nmolm2sec, fun=nmolCH4m2sec.to.gCm2day)

# 	names(summary_gCm2day) <- date_ls

# 	# WRITE gC OUTPUT 
# 	out_fname = paste0('pred_v03_gCm2day_em1_', summaryfcn, '.tif')
# 	writeRaster(summary_gCm2day,  filename=out_fname)
# 	}

# parallel::stopCluster(cl)

#paste0(summaryfcn, '_', seq(1, nlayers(summary_nmolm2sec), 1))
# summary_nmolm2sec <- clusterR(stack, calc, args=list(fun=f), export=c('timestep_grp','summaryfcn'))
# foreach(s=1:length(summary_stats), .packages=c('raster'), .combine=stack, .init=outstack) %dopar% { 

# # THIS PARALLEL DOESNT WORK YET --- BUT CLOSE TO WORKING;  CURRENTLY NOT USED
# # CHECK EXPORT PART OF FUNCTION 
# # Get summary (min, mean, max) of RF models per timestep
# # https://www.gis-blog.com/increasing-the-speed-of-raster-processing-with-r-part-33-cluster/
# # https://stat.ethz.ch/pipermail/r-sig-geo/2013-November/019833.html
# summarize_stack_par <- function(stack, nummodels, summaryfcn, ncores){

# 	nlay <- length(names(stack))
# 	# Make list of group labels
# 	timestep_grp = groupn(nlay, nlay/nummodels )

# 	f = function(x){tapply(x, timestep_grp, summaryfcn, na.rm=TRUE)}

# 	beginCluster(ncores)
# 	summarizedstack <- clusterR(stack, calc, 
# 								args=list(fun=f), 
# 								export=c('timestep_grp','summaryfcn'))
# 	endCluster()

# 	return(summarizedstack)
# 	# writeRaster(summarizedstack, oufilename)  # paste0(modelname, '_min_unweighted_nmol.tif'))
# 	}
# # No need to  output all 100 iterations of every member for every month:
# # summarize mean, median, standard dev at 3 stages along the pipeline 
# # after applying wetland masks and the 2 unit conversions. 
# z02 <- summarize_stack_par(stack, nummodels=10, summaryfcn='mean', 1)

# #################################
# # summarized <- 
# # 	foreach(b=1:10, .packages=c('raster','ranger'), .combine=stack, .init=outstack) %dopar% { 
# timestep_grp = groupn(nlay, nlay/nummodels )

# beginCluster(1)
# f = function(x){tapply(x, timestep_grp, summaryfcn, na.rm=TRUE)}

# # Mean
# summaryfcn='mean'
# mean_nmolm2sec <- clusterR(stack, calc, args=list(fun=f), export=c('timestep_grp','summaryfcn'))

# endCluster()
# q1 <- calc(s, fun=function(x) quantile(x, .5, na.rm=TRUE))