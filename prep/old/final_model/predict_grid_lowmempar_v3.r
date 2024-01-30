# /----------------------------------------------------------------------------------#
#/  function that predicts with RF                 						  -----------

rf_pred <- function(m, t, b){

	# pad number with 0s so length is 3
	t3 <- sprintf("%03d", t)

	# Print ticker
	# print(paste0('member:', m, ' - ', 'timestep:', t3, ' - ', 'bootstrap:', b))

	# Get predictor stack
	pred_name <- list.files(ensembledir, pattern=t3)
	predictor_stack <- stack(paste0(ensembledir, '/', pred_name))
	# predictor_stack <- stack(paste0(ensembledir, '/', 'FCH4_ALL_CFT_', t3, '.nc'))

	# Rename columns to match training set
	names(predictor_stack) <- layer_names
	
	model_filename <- paste0('../data/random_forest/sep2020/sep_model/201006_rf_mc_', b, '.rds')
	rf_model <- readRDS(model_filename)

	# Apply RF directly to stack of predictors (in namoles / m^2 / sec)
	r <- raster::predict( predictor_stack, rf_model, na.rm=TRUE)  # progress='text', 

	# write name of raster
	names(r) <- paste0('m', m, '_', 't', t, '_', 'b', b)

	return(r)
	}

# /---------------------------------------------------------
#/  PREP TO GET GLOBAL SUM OF EACH BOOTSTRAP

# Initialize the bootstrap totals
boot_df <- data.frame()
boot_temp_df <- data.frame()

#   4-  For total emissions:     TgCH4 month-1    (scaled) & for global sums
#   1 nmol = mol 1e-9   ;   1molCH4 = 16.04246 g  ;    1g = 1e-12 Tg    ;  1 month =  2.592e+6  seconds
nmolCH4m2sec.to.TgCH4month <- function(x){ x * 1e-9 * 16.04246 * 1e-12 * 2.592e+6 }


# /----------------------------------------------------------------------------------#
#/      Prep for random forest predictions of flux                        -----------

# names of predictors in rf
layer_names <-  c("wc_iso_mc", "wc_mtdq_mc", "wc_pwtq_mc", "canopyht_mc",
				  "EVI_min_mc", "LSTN_mean_mc","H_LAG1_mc", "LE_LAG4_mc", 
				  "LSWI_LAG2_mc", "PPFD_IN_LAG1_mc","TA_mc", "GPP_LEAD4_mc", "aet_LAG8_mc")


# no_cores <- detectCores(3) #- 1  type='FORK',
library(doParallel)
cl <- makeCluster(n_cores, type='FORK', outfile='par_foreach_log_finalmodel.txt')  
# cl <- parallel::makeForkCluster(1)
doParallel::registerDoParallel(cl)

outstack <- stack()  # Make empty stack to initialize

print('Starting prediction %dopar% loops')

summary_stats = c('mean', 'sd', 'var')

# NOTE: CHECK THE YEARS- MIGHT BE A MISMATCH BETWEEN FLUX & Fw
date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = n_timesteps)

# beginCluster(n_cores, type='SOCK')


#--------------------------------------------------------------------------------------
# Nested parallelized loops
# There can't be calculations between the foreach, so inputs are read at every loop
# Loop members
for(m in c(start_members:n_members)){

	# Read ensemble dir
	ensembledir = paste0('../data/predictors/sep2020/', m) 

	# (Re)Initiate the output stack 
	mean_stack <- stack()
	sd_stack   <- stack()
	var_stack  <- stack()

	# Loop time steps
	for(t in c(start_timestep:n_timesteps)){

		print(paste('m',m,' ','t',t))

		pred_flux_stack <- 
		# Par-Loop bootstraps
		foreach(b=1:n_bootstraps, .packages=c('raster','ranger'), .combine=stack, .init=outstack) %dopar% { 
			return( rf_pred(m, t, b))  }
		# This returns a stack of n_bootstraps


		# Get global total emissions  ======================================

		# crop to match extent of 
		pred_flux_stack <- crop(pred_flux_stack, com_ext)

		boot_TgCH4month <- calc(pred_flux_stack, fun=nmolCH4m2sec.to.TgCH4month)
		# Get the monthly raster 
		temp_Aw_m2 <- Aw_m2[[m]]
		# Scale all bootstrap rasters with same wetland extent 
		boot_TgCH4month <- overlay(boot_TgCH4month, temp_Aw_m2, fun=function(s, temp_Aw_m2) s * temp_Aw_m2)
		# Write global sums to df
		boot_temp_df <- data.frame(cellStats(boot_TgCH4month, 'sum', na.rm=T), row.names=NULL)
		names(boot_temp_df) <- 'sum_TgCH4month'
		boot_temp_df$b <- 1:n_bootstraps
		boot_temp_df$m <- m
		boot_temp_df$t <- t

		

		# Save mean, sd, var  stacks
		if(0){
			# MEAN 
			nmolm2sec_mean <- calc(pred_flux_stack, fun=mean)
			names(nmolm2sec_mean) <- paste0('m', m, '_t', t, '_', 'mean')
			out_fname = paste0('../output/results/grids/v03/m', m,'/pred_v03_nmolm2sec_m', m, '_t', t, '_', 'mean', '.tif')
			writeRaster(nmolm2sec_mean,  filename=out_fname)
	
			# SD
			nmolm2sec_sd <- calc(pred_flux_stack, fun=sd)
			names(nmolm2sec_sd) <- paste0('m', m, '_t', t, '_', 'sd')
			out_fname = paste0('../output/results/grids/v03/m', m,'/pred_v03_nmolm2sec_m', m, '_t', t, '_', 'sd', '.tif')
			writeRaster(nmolm2sec_sd,  filename=out_fname)
	
			# VAR
			nmolm2sec_var <- calc(pred_flux_stack, fun=var)
			names(nmolm2sec_var) <- paste0('m', m, '_t', t, '_', 'var')
			out_fname = paste0('../output/results/grids/v03/m', m,'/pred_v03_nmolm2sec_m', m, '_t', t, '_', 'var', '.tif')
			writeRaster(nmolm2sec_var,  filename=out_fname)
	
			# Add rasters to their to stack
			mean_stack <- stack(mean_stack, nmolm2sec_mean)
			sd_stack <- stack(sd_stack, nmolm2sec_sd)
			var_stack <- stack(var_stack, nmolm2sec_var)
			}

		# Bind the rows to df
		boot_df <- bind_rows(boot_df, boot_temp_df)

		}

		# SAVE ENTIRE STACKS
		# WRITE nmol MEAN OUTPUT 
		# out_fname = paste0('../output/results/grids/v03/m', m,'/pred_v03_nmolm2sec_m', m, '_', 'mean', '.tif')
		# writeRaster(mean_stack,  filename=out_fname)

		# # WRITE nmol SD OUTPUT 
		# out_fname = paste0('../output/results/grids/v03/m', m,'/pred_v03_nmolm2sec_m', m, '_', 'sd', '.tif')
		# writeRaster(sd_stack,  filename=out_fname)

		# # WRITE nmol VAR OUTPUT 
		# out_fname = paste0('../output/results/grids/v03/m', m,'/pred_v03_nmolm2sec_m', m, '_', 'var', '.tif')
		# writeRaster(var_stack,  filename=out_fname)
	}


# Save sums to csv
f <- paste0('../output/results/sums/v03/boot_sum_TgCH4month_m', m, '.csv')
write.csv(boot_df, f)


parallel::stopCluster(cl)
endCluster()

# parallel::stopCluster(cl)

# #  SUMMARY STATS PER TIMESTEP
# #  COULDN'T GET THE clusterR inside dopar  to work...
# for (s in 1:length(summary_stats)) { 

# # Get summary stat from string
# summaryfcn = summary_stats[s]
# print(summaryfcn)

# # RUN SUMMARY CALC - PARALLELIZED 
# summary_nmolm2sec <- calc(pred_flux_stack, fun=eval(as.symbol(summaryfcn)))

# # RENAME OUTPUT RASTERS
# names(summary_nmolm2sec) <- paste0('m', m, '_t', t, '_', summaryfcn) # date_ls 

# # WRITE nmol OUTPUT 
# out_fname = paste0('../output/results/grids/v03/pred_v03_nmolm2sec_m', m, '_t', t, '_', summaryfcn, '.tif')
# writeRaster(summary_nmolm2sec,  filename=out_fname)
# }


# WRITE OUTPUT - one file per member and timestep (8x180)
# print('writing .tif output')
# out_fname = paste0('../output/results/grids/v03/pred_v03_nmolm2sec_m', 
# 				 m, '_t', t, '_b', n_bootstraps, '.tif')
# writeRaster(pred_flux_stack,  filename=out_fname)
# # Loop members
# # foreach(m = 1:n_members, .packages=c('raster','ranger'), .combine=stack, .init=outstack)  %:%
# for(m in c(1:n_members)){
# 	ensembledir = paste0('../data/predictors/sep2020/', m) 
# 	# Loop time steps
# 	pred_flux_stack <- 
# 	foreach(t = 1:n_timesteps, .packages=c('raster','ranger'), .combine=stack, .init=outstack)  %:%
# 		# Loop bootstraps
# 		foreach(b=1:n_bootstraps, .packages=c('raster','ranger'), .combine=stack, .init=outstack) %dopar% { 

# 			return( rf_pred(m, t, b) )
# 			}
# 	# WRITE OUTPUT
# 	print('writing .tif output')
# 	out_fname = paste0('../output/results/grids/v03/pred_v03_nmolm2sec_m', 
# 					 n_members, '_t', n_timesteps, '_b', n_bootstraps, '.tif')
# 	writeRaster(pred_flux_stack,  filename=out_fname)
# }


