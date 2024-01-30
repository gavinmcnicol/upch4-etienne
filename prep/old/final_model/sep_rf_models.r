#-----------------------------------------------------------------------------
#/     Get random forest model (list of 24 models)    # rf_model[[1]]$finalModel$xNames
rf_model <- readRDS('../data/random_forest/sep2020/201006_rf_mc.rds')

# Split models into indiv files
dir.create('../data/random_forest/sep2020/sep_model')

# Loop through bootstraps
for (b in c(1:n_bootstraps)){

	print(b)
	temp <- rf_model[[b]]

	out_file <- paste0('../data/random_forest/sep2020/sep_model/201006_rf_mc_', b, '.rds')

	saveRDS(temp, out_file)
	} 
