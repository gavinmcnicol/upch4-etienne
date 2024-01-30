#-----------------------------------------------------------------------------
#/     Get random forest model (list of models; 1 per bootstrat) 
rf_dir <- '../data/random_forest/may2021/'

rf_model <- readRDS(paste0(rf_dir, 'rf_2.rds'))


# Split models into indiv files
dir.create(paste0(rf_dir,'sep_model'))

# Loop through bootstraps
for (b in c(1:n_bootstraps)){

	print(b)

	# Subset 
	temp <- rf_model[[b]]

	out_file <- paste0(rf_dir, 'sep_model/rf_b', b, '.rds')

	saveRDS(temp, out_file)
	} 
