#/     Get random forest model (list of 24 models)    # rf_model[[1]]$finalModel$xNames
rf_model <- readRDS('../data/random_forest/sep2020/201006_rf_mc.rds')

# names of predictors in rf
layer_names <-  c("wc_iso_mc", "wc_mtdq_mc", "wc_pwtq_mc", "canopyht_mc","EVI_min_mc", "LSTN_mean_mc", 
									"H_LAG1_mc", "LE_LAG4_mc", "LSWI_LAG2_mc", "PPFD_IN_LAG1_mc","TA_mc", "GPP_LEAD4_mc", "aet_LAG8_mc")

# ensembledir = '../data/predictors/sep2020/1' 

# /----------------------------------------------------------------------------------#
#/ Unzip predictor folder                                                  -----------
# Each members is up in predcitors > sep202 > 1.zip 
# zip names as 1-8


# /----------------------------------------------------------------------------------#
#/  function that predicts with RF                 -----------

rf_pred <- function(m, t, b){

	# pad number with 0s so length is 3
	t3 <- sprintf("%03d", t)

	# Print ticker
	print(paste0('member:', m, ' - ', 'timestep:', t3, ' - ', 'bootstrap:', b))

	# Get predictor stack
	predictor_stack <- stack(paste0(ensembledir, '/', 'FCH4_ALL_CFT_', t3, '.nc'))

	# Rename columns to match training set
	names(predictor_stack) <- layer_names
	
	#/    Apply RF directly to stack of predictors (in namoles / m^2 / sec)
	r <- raster::predict( predictor_stack, rf_model[[b]], na.rm=TRUE)  # progress='text', 

	# write name of raster
	names(r) <- paste0('m', m, '_', 't', t, '_', 'b', b)

	return(r)
	}



# /----------------------------------------------------------------------------------#
#/      Make random forest predictions of flux                             -----------
library(doParallel)  

# no_cores <- detectCores(3) #- 1  type='FORK',
cl <- makeCluster(n_cores, type='FORK', outfile='par_foreach_log_finalmodel.txt')  
registerDoParallel(cl)
# cl <- parallel::makeForkCluster(2)
# doParallel::registerDoParallel(cl)

outstack <- stack()  # Make empty stack to initialize

print('Starting prediction %dopar% loops')

# Nested parallelized loops
# There can't be calculations between the foreach, so inputs are read at every loop

# Loop members
for(m in c(1:n_members)){
	# Read ensemble dir
	ensembledir = paste0('../data/predictors/sep2020/', m) 
	# Loop time steps
	for(t in c(1:n_timesteps)){
		pred_flux_stack <- 
		# Par-Loop bootstraps
		foreach(b=1:n_bootstraps, .packages=c('raster','ranger'), .combine=stack, .init=outstack) %dopar% { 

			return( rf_pred(m, t, b) )
			}
		# WRITE OUTPUT
		print('writing .tif output')
		out_fname = paste0('../output/results/grids/v03/pred_v03_nmolm2sec_m', 
						 n_members, '_t', n_timesteps, '_b', n_bootstraps, '.tif')
		writeRaster(pred_flux_stack,  filename=out_fname)
}


parallel::stopCluster(cl)


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


# parallel::stopCluster(cl)