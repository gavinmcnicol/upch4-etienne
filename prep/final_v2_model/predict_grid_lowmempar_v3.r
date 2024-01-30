# /---------------------------------------------------------------------------#
#/  Initialize function predicting nmol fluxes globally with RF		-----------
#	This is the function that gets parallelized

# Function arguments of rf_pred:
# 	m = member index
#	t = timestep index
#	b = bootstrap index (this is the argument that gets run in parallel)

rf_pred <- function(m, t, b){

	# pad number with 0s so length is 3
	t3 <- sprintf("%03d", t)

	# Get predictor stack
	pred_name <- list.files(ensembledir, pattern=t3)
	predictor_stack <- stack(paste0(ensembledir, '/', pred_name))

	# Rename columns to match training set
	names(predictor_stack) <- layer_names
	
	model_filename <- paste0('../data/random_forest/may2021/sep_model/rf_b', b, '.rds')
	rf_model <- readRDS(model_filename)

	# Apply RF directly to stack of predictors (in namoles / m^2 / sec)
	r <- raster::predict( predictor_stack, rf_model, na.rm=TRUE)  # progress='text', 

	# write name of raster
	names(r) <- paste0('m', m, '_', 't', t, '_', 'b', b)

	return(r)
	}


# /---------------------------------------------------------------------------#
#/  PREP TO GET GLOBAL SUM OF EACH BOOTSTRAP 						-----------

# Initialize the bootstrap totals
boot_df <- data.frame()
boot_temp_df <- data.frame()

#   4-  For total emissions:     TgCH4 month-1    (scaled) & for global sums
#   1 nmol = mol 1e-9   ;   1molCH4 = 16.04246 g  ;    1g = 1e-12 Tg    ;  1 month =  2.592e+6  seconds
nmolCH4m2sec.to.TgCH4month <- function(x){ x * 1e-9 * 16.04246 * 1e-12 * 2.592e+6 }



# /---------------------------------------------------------------------------#
#/      Prep for random forest predictions of flux                  -----------

# names of predictors in rf
# to get names of predictors in RF:  rf_model[[1]]$finalModel$xNames  or rf_model$finalModel$xNames
layer_names <-  c("TA_mc", "TA_LAG2_mc", "EVI_LAG3_mc", "wc_mtdq_mc", "wc_pwtm_mc", "canopyht_mc")

# no_cores <- detectCores(3) #- 1  type='FORK',
library(doParallel)
cl <- makeCluster(n_cores, type='FORK', outfile='par_foreach_log_final_v2_model.txt')  
# cl <- parallel::makeForkCluster(1)
doParallel::registerDoParallel(cl)

outstack <- stack()  # Make empty stack to initialize

print('Starting prediction %dopar% loops')

summary_stats = c('mean', 'sd', 'var')

# Make list of dates; sequence of 216 months
date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = n_timesteps)

# beginCluster(n_cores, type='SOCK')


# /-----------------------------------------------------------------------------#
#/ Nested parallelized loops										-------------
# There can't be calculations between the foreach, so inputs are read at every loop

# Loop through members
for(m in c(start_members:n_members)) {

	# Read ensemble dir
	# ensembledir = paste0('../data/predictors/april2021/forcing/forcing_', m) 
	ensembledir <- '../data/predictors/may2021/forcing' 

	# (Re)Initiate the output stack 
	mean_stack <- stack()
	sd_stack   <- stack()
	var_stack  <- stack()

	# Loop time steps
	for(t in c(start_timestep:n_timesteps)){

		print(paste('m',m,' ','t',t))  # Print ticker

		pred_flux_stack <- 
		# Par-Loop bootstraps; This returns a stack of n_bootstraps
		foreach(b=1:n_bootstraps, .packages=c('raster','ranger'), .combine=stack, .init=outstack) %dopar% { 
			return( rf_pred(m, t, b))  }


		# /--------------------------------------------------------------------#
		#/ Get global total emissions per bootstraps				------------

		# crop to match extent of 
		pred_flux_stack <- crop(pred_flux_stack, com_ext)
		# Apply unit conversion & Aw scaling to nmol grid
		boot_TgCH4month <- calc(pred_flux_stack, fun=nmolCH4m2sec.to.TgCH4month)
		# Subset the wetland stack to t=t monthly raster 
		temp_Aw_m2 <- Aw_m2[[t]]  # <-- May2021 - Gavin: this is where I found the error. The index was m instead of t.
		# Scale all bootstrap rasters with same wetland extent 
		boot_TgCH4month <- overlay(boot_TgCH4month, temp_Aw_m2, fun=function(s, temp_Aw_m2) s * temp_Aw_m2)
		# Write global sums to df
		boot_temp_df <- data.frame(cellStats(boot_TgCH4month, 'sum', na.rm=T), row.names=NULL)
		# Rename col
		names(boot_temp_df) <- 'sum_TgCH4month'
		# Write column values to df
		boot_temp_df$b <- 1:n_bootstraps
		boot_temp_df$m <- m
		boot_temp_df$t <- t

		
		# Save mean, sd, var  individual monthyl rasters
		if(1){

			monthly_dir <- paste0('../output/results/grids/v04/m', m, '/monthly/')

			# MEAN 
			nmolm2sec_mean <- calc(pred_flux_stack, fun=mean)
			names(nmolm2sec_mean) <- paste0('m', m, '_t', t, '_', 'mean')
			out_fname = paste0(monthly_dir, 'upch4_v04_nmolm2sec_m', m, '_t', t, '_', 'mean', '.tif')
			writeRaster(nmolm2sec_mean,  filename=out_fname)
	
			# SD
			nmolm2sec_sd <- calc(pred_flux_stack, fun=sd)
			names(nmolm2sec_sd) <- paste0('m', m, '_t', t, '_', 'sd')
			out_fname = paste0(monthly_dir, 'upch4_v04_nmolm2sec_m', m, '_t', t, '_', 'sd', '.tif')
			writeRaster(nmolm2sec_sd,  filename=out_fname)
	
			# VAR
			nmolm2sec_var <- calc(pred_flux_stack, fun=var)
			names(nmolm2sec_var) <- paste0('m', m, '_t', t, '_', 'var')
			out_fname = paste0(monthly_dir, 'upch4_v04_nmolm2sec_m', m, '_t', t, '_', 'var', '.tif')
			writeRaster(nmolm2sec_var,  filename=out_fname)
	
			# Add rasters to their to stack
			# WHY IS THIS NOT BEING SAVED?
			# mean_stack <- stack(mean_stack, nmolm2sec_mean)
			# sd_stack   <- stack(sd_stack, nmolm2sec_sd)
			# var_stack  <- stack(var_stack, nmolm2sec_var)
			}

		# Bind the rows to df
		boot_df <- bind_rows(boot_df, boot_temp_df)

		# Save sums to csv - overwriting at every timestep, in case job doe not complete
		f <- paste0('../output/results/sums/v04/boot_sum_TgCH4month_m', m, '.csv')
		write.csv(boot_df, f)

		}
		
	}

# Stop parallel
parallel::stopCluster(cl)
endCluster()
