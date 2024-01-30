
# Steps:
# Loop through members
# 	|- Read the nmol predicted flux ncdf
# 	|- Convert units and apply Aw-scaling where appropriate

# Outputs:
# 4 versions of the upscaling produced:
# 1.  Raw predictions:       nmol m-2 sec-1      (unscaled)
# 2.  For iLAMB:             gC m-2 day-1        (unscaled)
# 3.  For Sanois-type map:   mgCH4 -m2 -day-1    (Aw scaled) & for comparison vs Peltola
# 4.  For total emissions:   Tg month-1          (Aw scaled)


beginCluster(n_cores, type='SOCK')

# Set common extent to crop with
com_ext <- extent(-180, 180, -56, 85)

stack_dir   <- paste0('../output/results/grids/v04/m', m, '/stack/')

# Loop through 8 ensembles
for (m in c(start_members:n_members)){

	print(paste0('m:', m))

	# 1.  READ INPUTS stack - upscaled in nmolCH4 m2 sec
	nc_filename  <- paste0(stack_dir, 'upch4_v04_m', m, '_nmolm2sec.nc')

	# Read the inputs
	mean_nmolm2sec <- stack(nc_filename, varname='mean_ch4')
	sd_nmolm2sec   <- stack(nc_filename, varname='sd_ch4')
	var_nmolm2sec  <- stack(nc_filename, varname='var_ch4')



	# /-----------------------------------------------------------------------------#
	#/  2 - For iLAMB: gC m-2 day-1  (unscaled)
	#   Read the nmol m-2 sec-1 inputs:  mean, sd, var

	# Convert to gCm2day
	nmolCH4m2sec.to.gCm2day <- function(x){ x *1e-9 *12.0107 *86400 }

	mean_gCm2day <- calc(mean_nmolm2sec,fun=nmolCH4m2sec.to.gCm2day)
	sd_gCm2day   <- calc(sd_nmolm2sec,  fun=nmolCH4m2sec.to.gCm2day)
	var_gCm2day  <- calc(var_nmolm2sec, fun=nmolCH4m2sec.to.gCm2day)
	
	# Save to ncdf
	nc_filename <- paste0(stack_dir, 'upch4_v04_m', m, '_gCm2day.nc')
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

	mean_mgCH4m2day<- run.nmolCH4m2sec.to.mgCH4m2day.and.scaling(mean_nmolm2sec)
	sd_mgCH4m2day  <- run.nmolCH4m2sec.to.mgCH4m2day.and.scaling(sd_nmolm2sec)
	var_mgCH4m2day <- run.nmolCH4m2sec.to.mgCH4m2day.and.scaling(var_nmolm2sec)

	# Save to ncdf
	nc_filename <- paste0(stack_dir, 'upch4_v04_m', m, '_mgCH4m2day_Aw.nc')
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

	mean_TgCH4month<- run.nmolCH4m2sec.to.TgCH4month.and.scaling(mean_nmolm2sec)
	sd_TgCH4month  <- run.nmolCH4m2sec.to.TgCH4month.and.scaling(sd_nmolm2sec)
	var_TgCH4month <- run.nmolCH4m2sec.to.TgCH4month.and.scaling(var_nmolm2sec)

	nc_filename <- paste0(stack_dir, 'upch4_v04_m', m, '_TgCH4month_Aw.nc')
	save.as.ncdf(nc_filename, 'TgCH4 month^-1 pixel^-1', mean_TgCH4month, sd_TgCH4month, var_TgCH4month)

	# Clean up workspace
	rm(mean_TgCH4month, sd_TgCH4month, var_TgCH4month)

	}

endCluster()

 
# Get summary (min, mean, max) of RF models per timestep
# https://www.gis-blog.com/increasing-the-speed-of-raster-processing-with-r-part-33-cluster/
# https://stat.ethz.ch/pipermail/r-sig-geo/2013-November/019833.html
