# Set working directory
setwd('../data/predictors/may2021')

# zipname = paste0(m, '.zip')
zipname = paste0('forcing_2', '.zip')

# dir.create(ensembledir)
unzip(zipname, exdir= '.') 


# n_members = 8

# for (m in c(1:8)){

# 	print(m)	
# 	# ensembledir = paste0('../data/predictors/sep2020/', m)

# 	zipname = paste0(m, '.zip')

# 	# dir.create(ensembledir)
# 	unzip(zipname, exdir= '.') 
# 	}

# unzip_member <- function(ensembledir){

# unzip(zipfile, files = NULL, list = FALSE, overwrite = TRUE,
#       junkpaths = FALSE, exdir = ".", unzip = "internal",
#       setTimes = FALSE)